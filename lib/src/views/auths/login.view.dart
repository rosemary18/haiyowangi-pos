import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {

    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state.isAuthenticated == null) context.read<AuthBloc>().add(AuthRefresh());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {

          if (state.isAuthenticated == null) {
            return Container(
              color: Colors.white,
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: LoadingAnimationWidget.threeArchedCircle(size: 50, color: primaryColor),
              ),
            );
          }

          return Container(
            color: Colors.white,
            height: double.infinity,
            width: double.infinity,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(ctx).size.width/4 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: max(MediaQuery.of(context).size.height * 0.2, 200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: AlignmentDirectional.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [.3, .9],
                            colors: [
                              Colors.white.withOpacity(.2),
                              const Color(0xFFF8C90F).withOpacity(.2),
                              // primaryColor.withOpacity(0.2),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            appImages["IMG_LOGO"]!,
                            width: 120,
                            height: 120,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Input(
                              controller: _emailController,
                              placeholder: "Email",
                              maxCharacter: 50,
                            ),
                            Input(
                              controller: _passwordController,
                              placeholder: "Password",
                              obscure: true,
                              maxCharacter: 16
                            ),
                            TouchableOpacity(
                              onPress: () {
                                if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Email dan Password harus diisi"),
                                      backgroundColor: Colors.red
                                    )
                                  );
                                }
                                context.read<AuthBloc>().add(AuthLogin(email: _emailController.text, password: _passwordController.text));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Masuk", 
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]
                        ),
                      )
                    ]
                  ),
                )
              )
            )
          );

        }
      )
    );
  }
}