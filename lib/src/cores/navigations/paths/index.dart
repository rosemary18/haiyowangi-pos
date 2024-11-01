import 'base_interface.dart';

class AppRoutes {
  
  final Route login;
  final Route loginStaff;
  final Route register;
  final Route registerStore;
  final Route stores;

  final Route dashboard;
  final Route inventory;
  final Route sales;

  const AppRoutes({

    this.login = const Route(name: "login", path: "/"),
    this.loginStaff = const Route(name: "login/staff", path: "/login/staff"),
    this.register = const Route(name: "register", path: "/register"),
    this.registerStore = const Route(name: "register/store", path: "/register/store"),
    this.stores = const Route(name: "stores", path: "/stores"),
    this.dashboard = const Route(name: "dashboard", path: "/dashboard"),
    this.inventory = const Route(name: "inventory", path: "/inventory"),
    this.sales = const Route(name: "sales", path: "/sales"),

  });
}

const appRoutes = AppRoutes();
