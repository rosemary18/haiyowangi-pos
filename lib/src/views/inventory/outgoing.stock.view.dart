import 'package:flutter/material.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';
import 'widgets/index.dart';

class OutgoingStockView extends StatefulWidget {
  const OutgoingStockView({super.key});

  @override
  State<OutgoingStockView> createState() => _OutgoingStockViewState();
}

class _OutgoingStockViewState extends State<OutgoingStockView> {

  final box = Hive.box("storage");
  List<OutgoingStockModel> outgoingStocks = [];
  OutgoingStockModel? outgoingStock;

  @override
  void initState() {
    super.initState();
    handlerGetOutgoingStocks();
  }

  void handlerGetOutgoingStocks() async {

    outgoingStocks.clear();
    final outgoingStocksSource = await box.get("outgoingStocks");
    if (outgoingStocksSource != null) {
      for (var item in outgoingStocksSource) {
        outgoingStocks.add(OutgoingStockModel.fromJson(item));
      }
    }

    setState(() {});
  }

  void handlerDetailOutgoingStock(dynamic item) async {
    
    if (item?.code == outgoingStock?.code) {
      outgoingStock = null;
    } else if (item != null) {
      outgoingStock = item as OutgoingStockModel;
    } else {
      outgoingStock = null;
    }

    setState(() {});
  }

  void handlerAddOutgoingStock(dynamic newOutgoingStock) async {

    if (newOutgoingStock is OutgoingStockModel) {

      final outgoingStocksSource = box.get("outgoingStocks");
      List<dynamic> newList = [newOutgoingStock.toJson()];

      if (outgoingStocksSource != null) {
        for (var item in outgoingStocksSource) {
          newList.add(item);
        }
      }

      await box.put("outgoingStocks", newList);
      handlerGetOutgoingStocks();
    }
  }

  void handlerDeleteIncomingStock(dynamic data) async {

    final outgoingStocksSource = await box.get("outgoingStocks");
    List<dynamic> newList = [];

    if (outgoingStocksSource != null) {
      for (var item in outgoingStocksSource) {
        if (item["code"] != data?.code) {
          newList.add(item);
        }
      }
    }

    await box.put("outgoingStocks", newList);
    handlerGetOutgoingStocks();
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
              data: outgoingStock,
              lists: outgoingStocks,
              stokOut: true,
              handlerDetailStock: handlerDetailOutgoingStock,
              handlerDeleteStock: handlerDeleteIncomingStock,
            ),
            Container(
              width: 1,
              color: Colors.black12,
            ),
            Expanded(
              child: DetailInventory(
                stokOut: true,
                data: outgoingStock,
                handlerAddStock: handlerAddOutgoingStock,
                handlerFormStock: handlerDetailOutgoingStock,
              )
            )
          ],
        )
      )
    );
  }
}