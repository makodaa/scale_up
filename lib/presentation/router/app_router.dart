import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:scale_up/presentation/views/authentication/login_page.dart';
import 'package:scale_up/presentation/views/authentication/sign_up_page.dart';
import 'package:scale_up/presentation/views/home/app_scaffold.dart';
import 'package:scale_up/presentation/views/home/courses_page.dart';
import 'package:scale_up/presentation/views/home/home_page.dart';
import 'package:scale_up/presentation/views/home/profile_page.dart';

class AppRoutes {
  static const String loginPath = '/login';
  static const String signUpPath = '/register';
  static const String homePath = '/home';
  static const String coursePath = '/courses';
  static const String profilePath = '/profile';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.homePath,
  routes: [
    GoRoute(
      path: AppRoutes.loginPath,
      name: 'login',
      builder: (context, state) => const LoginPage(),
      routes: [
        GoRoute(
          path: AppRoutes.signUpPath,
          name: 'signup',
          builder: (context, state) => const SignUpPage(),
        ),
      ],
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.homePath,
          name: 'home',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.coursePath,
          name: 'courses',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const CoursesPage(),
        ),
        GoRoute(
          path: AppRoutes.profilePath,
          name: 'profile',
          parentNavigatorKey: _shellNavigatorKey,
          builder: (context, state) => const ProfilePage(),
        )
      ],
    )
  ],
);
