import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';

class LoginStaffView extends StatefulWidget {
  const LoginStaffView({super.key});

  @override
  State<LoginStaffView> createState() => _LoginStaffViewState();
}

class _LoginStaffViewState extends State<LoginStaffView> {

  final syncRepo = SyncRepository();
  final TextEditingController _staffCodeController = TextEditingController();
  final TextEditingController _passcodeController = TextEditingController();

  final box = Hive.box("storage");
  List<StaffModel> staffs = [];

  @override
  void initState() {
    super.initState();
    handlerLoadStaffs();
  }

  // Handlers

  void handlerLoadStaffs() async {
    final xstaffs = box.get("staffs");
    if (xstaffs != null) {
      for (var item in xstaffs) {
        staffs.add(StaffModel.fromJson(item));
      }
    }
  }

  bool checkRemainingUpdate() {

    bool r = false;

    final sales = box.get("new_sales");
    final incomingStocks = box.get("incomingStocks");
    final outgoingStocks = box.get("outgoingStocks");

    if ( (sales != null) || (incomingStocks != null) || (outgoingStocks != null) ) {
      r = true;
    }

    return r;
  }

  void handlerLogin() {

    if (_staffCodeController.text.isEmpty) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text("Kode staff tidak boleh kosong!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (_passcodeController.text.isEmpty) {
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text("Kode pass staff tidak boleh kosong!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    StaffModel? existStaff;

    for (var item in staffs) {
      if (item.code!.toLowerCase() == _staffCodeController.text.toLowerCase() && item.posPasscode == _passcodeController.text && item.status == 1) {
        existStaff = item;
        break;
      }
    }

    if (existStaff != null) {
      final state = context.read<AuthBloc>().state;
      state.staff = existStaff;
      context.read<AuthBloc>().add(AuthUpdateState(state: state));
      context.goNamed(appRoutes.dashboard.name);
    } else {
      scaffoldMessengerKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text("Staff tidak ditemukan!"),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  void handlerResync() async {

    final state = context.read<AuthBloc>().state;

    Response sync = await syncRepo.sync("${state.store?.id}", syncStaff: true);
    
    if (sync.statusCode == 200) {

      final _store = StoreModel.fromJson(sync.data["data"]["store"]);
      state.store = _store;
      context.read<AuthBloc>().add(AuthUpdateState(state: state));
      handlerLoadStaffs();

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(sync.data["message"]!),
          backgroundColor: Colors.green,
        )
      );
    }
  }

  // Views

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (c, s) {},
        builder: (c, s) {
          return Container(
            color: white1Color,
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          appImages["IMG_LOGO"]!,
                          width: 80,
                          height: 80,
                        ),
                        Text("${s.store!.name}", style: const TextStyle(fontSize: 20, fontFamily: FontBold)),
                        const SizedBox(height: 20),
                        Input(
                          controller: _staffCodeController,
                          placeholder: "Kode Staff ...",
                          maxCharacter: 16,
                          onChanged: (v) => setState(() {}),
                          width: max(100, MediaQuery.of(context).size.width * .18),
                        ),
                        Input(
                          controller: _passcodeController,
                          placeholder: "Kode Pass Staff ...",
                          obscure: true,
                          maxCharacter: 16,
                          onChanged: (v) => setState(() {}),
                          onSubmitted: (v) => handlerLogin(),
                          width: max(100, MediaQuery.of(context).size.width * .18),
                        ),
                        const SizedBox(height: 20),
                        TouchableOpacity(
                          onPress: handlerLogin,
                          disabled: (_passcodeController.text.isEmpty && _passcodeController.text.isEmpty),
                          child: Icon(
                            Boxicons.bx_log_in_circle,
                            color: (_passcodeController.text.isEmpty && _passcodeController.text.isEmpty) ? greySoftColor : primaryColor,
                          ) 
                        )
                      ],
                    ),
                  ),
                ),
                if (!checkRemainingUpdate()) Positioned(
                  bottom: 12,
                  left: 12,
                  child: TouchableOpacity(
                    onPress: () => context.pushNamed(appRoutes.login.name),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Boxicons.bx_left_arrow_circle,
                          color: primaryColor,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text("Ganti Toko", style: TextStyle(color: greyTextColor, fontSize: 14))
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: TouchableOpacity(
                    onPress: handlerResync,
                    child: const Icon(
                      Boxicons.bx_sync,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                )
              ],
            )
          );
        }, 
      )
    );
  }
}