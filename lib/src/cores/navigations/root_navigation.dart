import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'animations/index.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellDrawerNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'drawerGrouppedShell');
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: "/",
  debugLogDiagnostics: true,
  routes: [

    GoRoute(path: appRoutes.login.path, name: appRoutes.login.name, builder: (c, s) => const LoginView()),
    GoRoute(path: appRoutes.loginStaff.path, name: appRoutes.loginStaff.name, builder: (c, s) => const LoginStaffView()),
    GoRoute(path: appRoutes.register.path, name: appRoutes.register.name, builder: (c, s) => const RegisterView()),
    GoRoute(path: appRoutes.registerStore.path, name: appRoutes.registerStore.name, builder: (c, s) => const RegisterStoreView()),
    GoRoute(path: appRoutes.stores.path, name: appRoutes.stores.name, builder: (c, s) => const StoresView()),

    ShellRoute(
      navigatorKey: shellDrawerNavigatorKey,
      builder: (ctx, s, c) => DrawerGroupedShell(state: s, child: c),
      routes: [
          GoRoute(
            path: appRoutes.dashboard.path,
            name: appRoutes.dashboard.name,
            pageBuilder: renderFadeTransition(const DashboardView())
          ),
          GoRoute(
            path: appRoutes.sales.path,
            name: appRoutes.sales.name,
            pageBuilder: renderFadeTransition(const SalesView())
          ),
          GoRoute(
            path: appRoutes.inventory.path, 
            name: appRoutes.inventory.name, 
            pageBuilder: renderFadeTransition(const InventoryTabsView()),
          ),
        ],
    ),


    // GoRoute(
    //   path: appRoutes.formProduct.path, 
    //   name: appRoutes.formProduct.name, 
    //   pageBuilder: renderSlideTransition(const FormProductView()),
    // ),
    // GoRoute(
    //   path: appRoutes.detailProduct.path, 
    //   name: appRoutes.detailProduct.name, 
    //   pageBuilder: (context, state) {
    //     return renderSlideTransition(
    //       DetailProductView(data: state.extra.toString()),
    //     )(context, state);
    //   },
    // ),

  ]
);
