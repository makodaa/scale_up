import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:provider/provider.dart";
import "package:scale_up/data/repositories/authentication/authentication_repository.dart";
import "package:scale_up/data/repositories/lessons/lesson_repository.dart";
import "package:scale_up/presentation/bloc/Authentication/authentication_bloc.dart";
import "package:scale_up/presentation/router/app_router.dart";

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthenticationRepository _authenticationRepository;
  late final LessonRepository _lessonRepository;
  late final AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();

    _authenticationRepository = AuthenticationRepository();
    _lessonRepository = LessonRepository();
    _authenticationBloc = AuthenticationBloc(repository: _authenticationRepository);
    unawaited(_lessonRepository.initialize());

    print("Started");
  }

  @override
  void dispose() {
    _authenticationBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _lessonRepository),
        BlocProvider.value(value: _authenticationBloc),
      ],
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        bloc: _authenticationBloc,
        listener: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            // Navigate to the home screen
            router.go("/home");
          } else if (state.status == AuthenticationStatus.unauthenticated) {
            // Navigate to the login screen
            router.go("/login");
          }
        },
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
