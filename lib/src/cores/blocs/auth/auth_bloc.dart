import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../index.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final StoreRepository storeRepository = StoreRepository();
  final NotificationRepository notificationRepository = NotificationRepository();

  AuthBloc() : super(AuthState()) {

    on<AuthUpdateState>((event, emit) async {
      emit(event.state);
    });

    on<AuthLogin>((event, emit) async {
      if (event.email.isEmpty || event.password.isEmpty) {
        return;
      }
      final _store = state.store;
      emit(AuthLoading());
      await authRepository.login(email: event.email, password: event.password).then((value) {
        state.isAuthenticated = false;
        if (value.statusCode == 200) {
          final data = value.data["data"];
          emit(
            state.copyWith(
              isAuthenticated: true, 
              token: data["token"], 
              user: UserModel.fromJson(data),
              store: _store
            )
          );
          dio.interceptors.add(
            InterceptorsWrapper(
              onRequest: (options, handler) {
                final String? token = data["token"];
                if (token != null && token.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $token';
                }
                return handler.next(options);
              },
            ),
          );
          GoRouter.of(rootNavigatorKey.currentContext!).goNamed(appRoutes.stores.name);
        }
      }).whenComplete(() => emit(state.copyWith()));
    });

    on<AuthRefresh>((event, emit) async {

      final box = Hive.box("storage");
      final store = box.get("store");

      if (store != null) {
        emit(
          state.copyWith(
            isAuthenticated: true,
            store: StoreModel.fromJson(store)
          )
        );
        GoRouter.of(rootNavigatorKey.currentContext!).goNamed(appRoutes.loginStaff.name);
      } else {
        emit(
          state.copyWith(
            isAuthenticated: false,
          )
        );
      }
    });

    on<AuthLogout>((event, emit) async {
      
      showModalLoader();
      await Future.delayed(const Duration(seconds: 1));
      rootNavigatorKey.currentState?.pop();
      GoRouter.of(rootNavigatorKey.currentContext!).goNamed(appRoutes.loginStaff.name);
    });
  }
}
