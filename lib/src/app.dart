import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cores/index.dart';

class App extends StatelessWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderBlocs(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) => MaterialApp.router(
          scaffoldMessengerKey: scaffoldMessengerKey,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: themeApp(context)
        )
      )
    );
  }
}
