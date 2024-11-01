import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';

class DashboardHeader extends StatefulWidget implements PreferredSizeWidget {

  final String title;
  final StaffModel? staff;
  final String activePath;

  const DashboardHeader({
    super.key,
    this.title = '',
    this.staff,
    this.activePath = ''
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
  
  @override
  Size get preferredSize => const Size.fromHeight(40);
}

class _DashboardHeaderState extends State<DashboardHeader> {

  final syncRepo = SyncRepository();
  final box = Hive.box("storage");

  @override
  void initState() {
    super.initState();
    debugPrint("init dashboard header");
  }

  void handlerLogout(BuildContext context, VoidCallback close) {

    close();
    context.read<AuthBloc>().add(AuthLogout());
  }

  bool isActive(String path) {

    bool r = false;

    if (path == widget.activePath) {
      r = true;
    }

    return r;
  }

  @override
  void didUpdateWidget(covariant DashboardHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void handlerSync() async {

    final state = context.read<AuthBloc>().state;
    bool synced = await syncRepo.syncAll("${state.store?.id}");

    if (synced) {
      GoRouter.of(context).pushReplacement(widget.activePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: primaryColor,
        title: Text(
          widget.title, 
          style: const TextStyle(color: Colors.white, fontFamily: FontBold, fontSize: 18)
        ),
        shadowColor: Colors.black,
        centerTitle: false,
        elevation: .5,
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        leadingWidth: 40,
        leading: Container(
          margin: const EdgeInsets.only(left: 12, bottom: 4),
          child: Row(
            children: [
              TouchableOpacity(
                onPress: () {},
                child: Center(child: Image.asset(appIcons["IC_LOGO_WHITE"]!, width: 22, height: 22))
              )
            ]
          ),
        ),
        actions: [
          TouchableOpacity(
            onPress: handlerSync,
            child: Container(
              margin: const EdgeInsets.only(right: 12, bottom: 4),
              child: const Row(
                children: [
                  Icon(
                    Boxicons.bx_sync,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text("Singkronkan", style: TextStyle(color: Colors.white, fontSize: 12)),
                ]
              ),
            ), 
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, bottom: 4),
            constraints: const BoxConstraints(maxWidth: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopUpContent(
                  contentBuilder: (context, close) => Material(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        boxShadow: [
                          BoxShadow(color: Color.fromARGB(18, 0, 0, 0), blurRadius: 3, spreadRadius: 2, offset: Offset(1, 1))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TouchableOpacity(
                            onPress: () {
                              close();
                              if (!isActive(appRoutes.dashboard.path)) {
                                context.pushReplacementNamed(appRoutes.dashboard.name);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Boxicons.bx_home, 
                                  color: isActive(appRoutes.dashboard.path) ? primaryColor : blackColor, 
                                  size: 16
                                ),
                                const SizedBox(width: 10),
                                Text("Dasbor", style: TextStyle(color: isActive(appRoutes.dashboard.path) ? primaryColor : blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ), 
                          ),
                          const SizedBox(height: 12),
                          TouchableOpacity(
                            onPress: () {
                              close();
                              if (!isActive(appRoutes.sales.path)) {
                                context.pushReplacementNamed(appRoutes.sales.name);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Boxicons.bx_shopping_bag, 
                                  color: isActive(appRoutes.sales.path) ? primaryColor : blackColor, 
                                  size: 16
                                ),
                                const SizedBox(width: 10),
                                Text("Penjualan", style: TextStyle(color: isActive(appRoutes.sales.path) ? primaryColor :  blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ), 
                          ),
                          const SizedBox(height: 12),
                          TouchableOpacity(
                            onPress: () {
                              close();
                              if (!isActive(appRoutes.inventory.path)) {
                                context.pushReplacementNamed(appRoutes.inventory.name);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Boxicons.bx_data, 
                                  color: isActive(appRoutes.inventory.path) ? primaryColor : blackColor, 
                                  size: 16
                                ),
                                const SizedBox(width: 10),
                                Text("Inventory", style: TextStyle(color: isActive(appRoutes.inventory.path) ? primaryColor : blackColor, fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ), 
                          ),
                          const SizedBox(height: 12),
                          TouchableOpacity(
                            onPress: () => handlerLogout(context, close),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.logout, color: redColor, size: 16),
                                SizedBox(width: 10),
                                Text("Keluar", style: TextStyle(color: redColor, fontWeight: FontWeight.w500, fontSize: 14)),
                              ],
                            ), 
                          )
                        ],
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(114)),
                      color: Color.fromARGB(36, 0, 0, 0)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: white1Color,
                            border: Border.all(color: greySoftColor, width: .2),
                          ),
                          child: Image.asset(appImages["IMG_DEFAULT"]!, fit: BoxFit.cover),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 6, right: 8),
                          constraints: const BoxConstraints(maxWidth: 60),
                          child: Text("${widget.staff?.name}", style: const TextStyle(fontSize: 10, color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 1),
                        )
                      ]
                    ),
                  ),
                )
              ]
            ),
          )
        ],
      );
  }
}