import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';

class ListInventory extends StatefulWidget {

  final dynamic data;
  final List<dynamic> lists;
  final bool stokOut;
  final Function(dynamic)? handlerDetailStock;
  final Function(dynamic)? handlerDeleteStock;

  const ListInventory({
    super.key,
    this.data,
    this.lists = const [],
    this.stokOut = false,
    this.handlerDetailStock,
    this.handlerDeleteStock
  });

  @override
  State<ListInventory> createState() => _ListInventoryState();
}

class _ListInventoryState extends State<ListInventory> {

  List<dynamic> lists = [];

  @override
  void initState() {
    super.initState();
    lists = widget.lists;
  }

  // Views

  void viewDeleteConfirm(int i) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus stok ${lists[i]?.code}?"),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: greyColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Batal', 
                  style: TextStyle(
                    color: Color.fromARGB(192, 0, 0, 0), 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            ),
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                widget.handlerDeleteStock!(lists[i]);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: redColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Hapus', 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 14,
                    fontWeight: FontWeight.bold
                  )
                ),
              ), 
            )
          ],
        );
      }
    );
  }

  Widget viewCard(BuildContext context, int index) {

    if (lists.isEmpty)  {
      return SizedBox(
        height: 40,
        child: Center(
          child: Text("Stok ${widget.stokOut ? "keluar" : "masuk"} tidak ditemukan!", style: const TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    return TouchableOpacity(
      onPress: () => widget.handlerDetailStock!(lists[index]),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ((widget.data != null) && (widget.data?.code == lists[index]?.code)) ? greenLightColor : Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("#${lists[index].code ?? "-"}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(formatDateFromString("${lists[index].createdAt}", format: "EEEE, dd/MM/yyyy, HH:mm"), style: const TextStyle(fontSize: 8, color: greyTextColor)),
                  ],
                ),
                if (!(widget.data != null && (widget.data?.code == lists[index]?.code))) TouchableOpacity(
                  child: const Icon(
                    Boxicons.bxs_trash,
                    color: redColor,
                    size: 14
                  ), 
                  onPress: () => viewDeleteConfirm(index)
                )
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: white1Color,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Nama", style: TextStyle(fontSize: 8)),
                      Text(lists[index].name ?? "-", style: const TextStyle(fontSize: 8))
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Jumlah", style: TextStyle(fontSize: 8)),
                      Text(
                        "${lists[index] is IncomingStockModel ? lists[index]?.incomingStockItems?.length : lists[index]?.outgoingStockItems?.length} Item", 
                        style: const TextStyle(fontSize: 8)
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: max(300, MediaQuery.of(context).size.width * .3),
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const InputSearch(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: lists.isEmpty ? 1 : lists.length,
              itemBuilder: (context, index) => viewCard(context, index),
            ),
          )
        ],
      ),
    );
  }
}