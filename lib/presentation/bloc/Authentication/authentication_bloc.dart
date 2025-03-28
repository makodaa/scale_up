import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:scale_up/data/repositories/authentication/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required AuthenticationRepositoryImpl repository})
      : _repository = repository,
        super(AuthenticationState()) {
    on<AuthenticationEmailChanged>(_onEmailChanged);
    on<AuthenticationPasswordChanged>(_onPasswordChanged);
    on<AuthenticationFormSubmitted>(_onSubmitted);
    on<AuthenticationRevoked>((event, emit) {});
    on<AuthenticationFormSwiped>((event, emit) {});
    on<GoogleSignInButtonPressed>(_onGoogleSignIn);
    on<LogoutButtonPressed>(_onLogoutButtonPressed);
  }

  final AuthenticationRepositoryImpl _repository;

  void _onEmailChanged(AuthenticationEmailChanged event, Emitter emit) {
    final email = event.email;

    emit(state.copyWith(email: email));
  }

  void _onPasswordChanged(AuthenticationPasswordChanged event, Emitter emit) {
    final password = event.password;

    emit(state.copyWith(password: password));
  }

  void _onSubmitted(AuthenticationFormSubmitted event, Emitter emit) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      await _repository.loginEmailPassword(
        email: state.email,
        password: state.password,
      );

      emit(state.copyWith(
        isSubmitting: false,
        status: AuthenticationStatus.authenticated,
        email: state.email,
        password: state.password,
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        status: AuthenticationStatus.unauthenticated,
      ));

      if (kDebugMode) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }

  void _onGoogleSignIn(GoogleSignInButtonPressed event, Emitter emit) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      var creds = await _repository.loginGoogle();
      if (creds == null) {
        emit(state.copyWith(isSubmitting: false));
        return;
      }

      emit(state.copyWith(
        isSubmitting: false,
        status: AuthenticationStatus.authenticated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        status: AuthenticationStatus.unauthenticated,
      ));
      if (kDebugMode) {
        print("Google Sign-In Failed: $e");
      }
    }
  }

  void _onLogoutButtonPressed(LogoutButtonPressed event, Emitter emit) async {
    emit(state.copyWith(isSubmitting: true));

    try {
      await _repository.logOut();
      emit(state.copyWith(
        isSubmitting: false,
        status: AuthenticationStatus.unauthenticated,
        email: '',
        password: '',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        status: AuthenticationStatus.authenticated,
      ));

      if (kDebugMode) {
        print("Logout Failed: $e");
      }
    }
  }
}
