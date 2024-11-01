part of 'auth_bloc.dart';

final class AuthState {

  bool? isAuthenticated;
  String token;
  UserModel? user;
  StaffModel? staff;
  StoreModel? store;

  AuthState({
    this.isAuthenticated,
    this.token = "",
    this.user,
    this.staff,
    this.store,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    UserModel? user,
    StaffModel? staff,
    StoreModel? store
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
      store: store ?? this.store,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isAuthenticated": isAuthenticated,
      "token": token,
      "user": user?.toJson(),
      "store": store?.toJson(),
      "staff": staff?.toJson(),
    };
  }
}

final class AuthLoading extends AuthState {}
