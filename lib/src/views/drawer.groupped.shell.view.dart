import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:haiyowangi_pos/src/index.dart';
class DrawerGroupedShell extends StatefulWidget {

  final Widget child;
  final GoRouterState state;

  const DrawerGroupedShell({super.key, required this.child, required this.state});

  @override
  State<DrawerGroupedShell> createState() => _DrawerGroupedShellState();
}

class _DrawerGroupedShellState extends State<DrawerGroupedShell> {

  String title = "";

  @override
  void initState() {
    super.initState();
    setState(setTitle);
  }

  @override
  void didUpdateWidget(covariant DrawerGroupedShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(setTitle);
  }

  void setTitle() {
    
    var state = context.read<AuthBloc>().state;
    if (widget.state.fullPath == appRoutes.dashboard.path) {
      title = "POS: ${state.store?.name ?? ""}";
    } else if (widget.state.fullPath == appRoutes.sales.path) {
      title = "Penjualan";
    } else if (widget.state.fullPath == appRoutes.inventory.path) {
      title = "Inventory";
    }
  }

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (c, s) {},
      builder: (c, s) {
        return Scaffold(
          appBar: DashboardHeader(title: title, staff: s.staff, activePath: GoRouter.of(context).routeInformationProvider.value.uri.toString()),
          body: Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                color: const Color(0xFF0D0D0D),
                child: widget.child,
              ),
            ],
          )
        );
      }, 
    );
  }
}