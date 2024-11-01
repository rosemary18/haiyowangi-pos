import 'package:flutter/material.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';

import 'widgets/index.dart';

class IncomingStockView extends StatefulWidget {
  const IncomingStockView({super.key});

  @override
  State<IncomingStockView> createState() => _IncomingStockViewState();
}

class _IncomingStockViewState extends State<IncomingStockView> {

  final box = Hive.box("storage");

  List<IncomingStockModel> incomingStocks = [];
  IncomingStockModel? incomingStock;

  @override
  void initState() {
    super.initState();
    handlerGetIncomingStocks();
  }

  void handlerGetIncomingStocks() async {

    incomingStocks.clear();
    final incomingStocksSource = await box.get("incomingStocks");
    if (incomingStocksSource != null) {
      for (var item in incomingStocksSource) {
        incomingStocks.add(IncomingStockModel.fromJson(item));
      }
    }

    setState(() {});
  }

  void handlerDetailIncomingStock(dynamic item) async {
    
    if (item.code == incomingStock?.code) {
      incomingStock = null;
    } else if (item != null) {
      incomingStock = item as IncomingStockModel;
    } else {
      incomingStock = null;
    }

    setState(() {});
  }

  void handlerAddIncomingStock(dynamic newIncomingStock) async {

    if (newIncomingStock is IncomingStockModel) {

      final incomingStocksSource = box.get("incomingStocks");
      List<dynamic> newList = [newIncomingStock.toJson()];

      if (incomingStocksSource != null) {
        for (var item in incomingStocksSource) {
          newList.add(item);
        }
      }

      await box.put("incomingStocks", newList);
      handlerGetIncomingStocks();
    }
  }

  void handlerDeleteIncomingStock(dynamic data) async {

    final incomingStocksSource = await box.get("incomingStocks");
    List<dynamic> newList = [];

    if (incomingStocksSource != null) {
      for (var item in incomingStocksSource) {
        if (item["code"] != data?.code) {
          newList.add(item);
        }
      }
    }

    await box.put("incomingStocks", newList);
    handlerGetIncomingStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Row(
          children: [
            ListInventory(
              data: incomingStock,
              lists: incomingStocks,
              handlerDetailStock: handlerDetailIncomingStock,
              handlerDeleteStock: handlerDeleteIncomingStock,
            ),
            Container(
              width: 1,
              color: Colors.black12,
            ),
            Expanded(
              child: DetailInventory(
                data: incomingStock,
                handlerAddStock: handlerAddIncomingStock,
                handlerFormStock: handlerDetailIncomingStock,
              )
            )
          ],
        )
      )
    );
  }
}