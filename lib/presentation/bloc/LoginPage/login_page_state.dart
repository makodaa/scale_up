const undefined = #undefined;

class LoginPageState {
  final String email;
  final String password;
  final int carouselPosition;

  const LoginPageState({
    this.email = "",
    this.password = "",
    this.carouselPosition = 0,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginPageState Function({
    String? email,
    String? password,
    int? carouselPosition,
  }) get copyWith => _copyWith;

  LoginPageState _copyWith({
    Object? email = undefined,
    Object? password = undefined,
    Object? carouselPosition = undefined,
  }) {
    return LoginPageState(
      email: email.or(this.email),
      password: password.or(this.password),
      carouselPosition: carouselPosition.or(this.carouselPosition),
    );
  }
}

extension on Object? {
  T or<T>(T value) => this == undefined ? value : this as T;
}
