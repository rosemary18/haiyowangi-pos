import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class StoresView extends StatefulWidget {
  const StoresView({super.key});

  @override
  State<StoresView> createState() => _StoresViewState();
}

class _StoresViewState extends State<StoresView> {

  final StoreRepository _storeRepo = StoreRepository();
  final AuthRepository _authRepo = AuthRepository();
  final SyncRepository _syncRepo = SyncRepository();
  final TextEditingController _searchController = TextEditingController();
  PersistentBottomSheetController? _sheetController;
  final List<StoreModel> _stores = [];
  final List<StoreModel> _searchStores = [];

  bool loading = true;
  StoreModel? _selectedStore;

  @override
  void initState() {
    super.initState();
    final id = context.read<AuthBloc>().state.user?.id;
    handlerGetStores("$id");
  }

  Future<void> handlerGetStores(String id) async {

    _stores.clear();
    final response = await _storeRepo.getStores(id);

    for (var item in response.data["data"]) {
      _stores.add(StoreModel.fromJson(item));
    }
    
    _searchController.clear();
    loading = false;
    setState(() {});
  }

  void handlerSearch(String v) {
    _searchStores.clear();
    if (v.isNotEmpty) {
      for (var item in _stores) {
        if (item.name!.toLowerCase().contains(v.toLowerCase())) {
          _searchStores.add(item);
        }
      }
    }
    setState(() {});
  }

  void handlerSelectStore(StoreModel store, BuildContext ctx) {
    _selectedStore = _selectedStore == store ? null :  store;
    if (_selectedStore != null) {
      if (_sheetController == null) {
        _sheetController = showBottomSheet(
          context: ctx,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .65),
          clipBehavior: Clip.none,
          builder: (context) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              boxShadow: [
                BoxShadow(color: Color.fromARGB(22, 0, 0, 0), blurRadius: 10, spreadRadius: 2.5)
              ]
            ),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width * .25 : 0,),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: double.infinity,
                        child: Center(
                          child: Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: greyLightColor,
                              borderRadius: BorderRadius.circular(4)
                            ),
                          )
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            height: 56,
                            width: 56,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              color: white1Color,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: _selectedStore!.storeImage!.isEmpty ? 
                              Center(
                                child: Text(_selectedStore!.name!.substring(0, 1).toUpperCase(), style: const TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.w600)),
                              ) : Image.network(_selectedStore!.storeImage!, fit: BoxFit.cover),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  _selectedStore!.name!, 
                                  style: const TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.w600)
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Terakhir sinkronasi: ${store.lastSync!.isEmpty ? "-" : formatDateFromString(store.lastSync!)}",
                                  style: const TextStyle(color: greyTextColor, fontSize: 11, fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text("Alamat: ", style: TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(_selectedStore!.address!.isEmpty ? "-" : _selectedStore!.address!, style: const TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Dibuat: ", style: TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(_selectedStore!.createdAt!.isEmpty ? "-" : DateFormat('yyyy/MM/dd, kk:mm').format(DateTime.parse(_selectedStore!.createdAt!)), style: const TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Terakhir diupdate: ", style: TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(_selectedStore!.updatedAt!.isEmpty ? "-" : DateFormat('yyyy/MM/dd, kk:mm').format(DateTime.parse(_selectedStore!.updatedAt!)), style: const TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ]
                  ),
                ),
                Positioned(
                  height: 48,
                  bottom: MediaQuery.of(ctx).viewPadding.bottom + 8,
                  right: isTablet ? MediaQuery.of(context).size.width * .25 : 0,
                  left: isTablet ? MediaQuery.of(context).size.width * .25 : 0,
                  child: ButtonOpacity(
                    onPress: () => handlerSignInStore(_selectedStore!),
                    text: "Masuk",
                    backgroundColor: primaryColor,
                    fontSize: 16,
                  )
                )
              ],
            )
          )
        );
        _sheetController!.closed.whenComplete(() {
          Timer(const Duration(milliseconds: 350), () {
            _selectedStore = null;
            _sheetController = null;
            setState(() {});
          });
        });
      } else {
        _sheetController!.setState!(() {});
      }
    } else if (_selectedStore == null) {
      _sheetController?.close();
      _sheetController = null;
    }

    setState(() {});
  }

  void handlerSignInStore(StoreModel? store) async {

    if (store != null) {

      _sheetController?.close();
      _sheetController = null;

      final state = context.read<AuthBloc>().state;
      if (state.store != null) {
        await handlerSignOutStore();
      }

      Response res = await _authRepo.loginStorePOS(storeId: "${store.id}", deviceId: androidDeviceInfo!.id);

      if (res.statusCode == 200) {
        final box = Hive.box("storage");
        await box.put("store", store.toJson());

        Response sync = await _syncRepo.sync("${store.id}");

        if (sync.statusCode == 200) {

          final _store = StoreModel.fromJson(sync.data["data"]["store"]);
          state.store = _store;
          context.read<AuthBloc>().add(AuthUpdateState(state: state));

          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(sync.data["message"]!),
              backgroundColor: Colors.green,
            )
          );
          context.goNamed(appRoutes.loginStaff.name);        
        }
      }

    }
  }

  Future<void> handlerSignOutStore() async {

    final state = context.read<AuthBloc>().state;
    Response res = await _authRepo.logoutStorePOS(storeId: "${state.store?.id}", deviceId: androidDeviceInfo!.id);

    if (res.statusCode == 200) {
      final box = Hive.box("storage");
      await box.delete("store");
      state.store = null;
      context.read<AuthBloc>().add(AuthUpdateState(state: state));     
    }
  }

  Future<void> handlerCreateStore() async {
    final id = context.read<AuthBloc>().state.user?.id;
    final result = await context.pushNamed<bool>(appRoutes.registerStore.name);
    if (result != null && result == true) {
      setState(() { loading = true; });
      handlerGetStores("$id");
    }
  }

  // Views

  Widget viewHeader(BuildContext context, state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Toko Kamu (${_stores.length})", style: const TextStyle(color: blackColor, fontSize: 16, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: InputSearch(
                    controller: _searchController,
                    onChanged: handlerSearch,
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget viewStoreCard(BuildContext context, StoreModel store) {
    return TouchableOpacity(
      onPress: () => handlerSelectStore(store, context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: _selectedStore == store ? blueLightColor :  Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          boxShadow: const [
            BoxShadow(color: Color.fromARGB(16, 0, 0, 0), spreadRadius: 1, blurRadius: 1, offset: Offset(0, 1))
          ]
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              height: 38,
              width: 38,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: white1Color,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
              child: store.storeImage!.isEmpty ? 
                Center(
                  child: Text(store.name!.substring(0, 1).toUpperCase()),
                ) : Image.network(store.storeImage!, fit: BoxFit.cover),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name!.isEmpty ? "-" : store.name!,
                    style: const TextStyle(color: blackColor, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Terakhir sinkronasi: ${store.lastSync!.isEmpty ? "-" : formatDateFromString(store.lastSync!)}",
                    style: const TextStyle(color: greyTextColor, fontSize: 11, fontWeight: FontWeight.w500),
                  )
                ],
              )
            ),
            TouchableOpacity(
              onPress: () => handlerSignInStore(store),
              child: Container(
                margin: const EdgeInsets.only(right: 4, left: 12),
                child: const Icon(Icons.login, color: primaryColor, size: 20),
              ),
            )
          ],
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width * .25 : 0,),
          color: white1Color,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                viewHeader(context, state),
                Expanded(
                  child: (_stores.isEmpty && !loading) ? const Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text("Kamu belum memiliki toko!", style: TextStyle(color: greyDarkColor, fontSize: 12)),
                        ),
                      )
                    ],
                  ) : loading ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: LoadingAnimationWidget.threeArchedCircle(size: 24, color: greyDarkColor),
                    )
                  ],
                ) : RefreshIndicator(
                  onRefresh: () async => handlerGetStores("${state.user?.id}"),
                  child: (_searchController.text.isNotEmpty) ? ListView.builder(
                    itemCount: _searchStores.length,
                    itemBuilder: (c, i) => viewStoreCard(c, _searchStores[i]),
                    physics: const AlwaysScrollableScrollPhysics(),
                  ) : ListView.builder(
                    itemCount: _stores.length,
                    itemBuilder: (c, i) => viewStoreCard(c, _stores[i]),
                    physics: const AlwaysScrollableScrollPhysics(),
                  ), 
                )
                )
              ],
            )
          ),
        ),
      )
    );
  }
}