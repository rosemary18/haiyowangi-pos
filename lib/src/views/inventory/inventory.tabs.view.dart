import 'package:flutter/material.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'incoming.stock.view.dart';
import 'outgoing.stock.view.dart';

class InventoryTabsView extends StatefulWidget {
  const InventoryTabsView({super.key});

  @override
  State<InventoryTabsView> createState() => _InventoryTabsViewState();
}

class _InventoryTabsViewState extends State<InventoryTabsView> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  int tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {
        tabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: greyTextColor,
              indicatorColor: primaryColor,
              dividerColor: greyColor,
              indicatorSize: TabBarIndicatorSize.label,
              overlayColor: WidgetStateProperty.all(primaryColor),
              automaticIndicatorColorAdjustment: true,
              tabs: const [
                Tab(
                  child: Text("Stok Masuk", style: TextStyle(fontFamily: FontMedium)),
                ),
                Tab(
                  child: Text("Stok Keluar", style: TextStyle(fontFamily: FontMedium)),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  IncomingStockView(),
                  OutgoingStockView()
                ]
              )
            )
          ],
        ),
      )
    );
  }
}