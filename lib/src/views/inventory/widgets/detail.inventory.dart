import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';

import 'stock.item.widget.dart';

class DetailInventory extends StatefulWidget {

  final dynamic data;
  final bool stokOut;
  final Function(dynamic) handlerAddStock;
  final Function(dynamic)? handlerFormStock;

  const DetailInventory({
    super.key,
    this.data,
    this.stokOut = false,
    required this.handlerAddStock,
    this.handlerFormStock
  });

  @override
  State<DetailInventory> createState() => _DetailInventoryState();
}

class _DetailInventoryState extends State<DetailInventory> {

  final _controllerDesc = TextEditingController();

  List<dynamic> items = [];
  Timer? timeId;

  @override
  void initState() {
    super.initState();
  }

  void handlerSearchProduct() async {

    var x = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      barrierColor: Colors.transparent,
      clipBehavior: Clip.none,
      isScrollControlled: false,
      scrollControlDisabledMaxHeightRatio: .85,
      builder: (context) => const SearchProduct(multiple: true, showIngredient: true),
    );

    if (x != null) {

      List<dynamic> newItems = [];

      for (var item in x) {

        bool exist = false;

        if (items.isNotEmpty) {
          for (var e in items) {
            if (
              ((item.runtimeType == ProductModel) && (e.productId == item.id)) 
              || 
              ((item.runtimeType == VariantModel) && (e.variantId == item.id))
              ||
              ((item.runtimeType == IngredientModel) && (e.ingredientId == item.id))
              ) {
              exist = true;
              break;
            }
          }
        }

        if (!exist) {

          if (item.runtimeType == ProductModel) {
            if (widget.stokOut) {

            } else {
              
            }
          }

          newItems.add(
            widget.stokOut ? OutgoingStockItemModel(
              productId: (item.runtimeType == ProductModel) ? item.id : null,
              product: (item.runtimeType == ProductModel) ? item : null,
              variantId: (item.runtimeType == VariantModel) ? item.id : null,
              variant: (item.runtimeType == VariantModel) ? item : null,
              ingredientId: (item.runtimeType == IngredientModel) ? item.id : null,
              ingredient: (item.runtimeType == IngredientModel) ? item : null,
              createdAt: DateTime.now().toIso8601String(),
              qty: 1
            ) : IncomingStockItemModel(
              productId: (item.runtimeType == ProductModel) ? item.id : null,
              product: (item.runtimeType == ProductModel) ? item : null,
              variantId: (item.runtimeType == VariantModel) ? item.id : null,
              variant: (item.runtimeType == VariantModel) ? item : null,
              ingredientId: (item.runtimeType == IngredientModel) ? item.id : null,
              ingredient: (item.runtimeType == IngredientModel) ? item : null,
              createdAt: DateTime.now().toIso8601String(),
              qty: 1
            )
          );
        }
      }

      if (newItems.isNotEmpty) {
        items.addAll(newItems);
        setState(() {});      
      }
    }
  }

  void handlerDeleteItem(dynamic data) async {
    items.remove(data);
    setState(() {});
  }

  void handlerAddStock() {

    final staff = context.read<AuthBloc>().state.staff;

    if (widget.stokOut) {

      final List<OutgoingStockItemModel> _items = items.map((item) => item as OutgoingStockItemModel).toList();
      
      final newOutgoingStock = OutgoingStockModel(
        code: "OS${DateTime.now().toUtc().millisecondsSinceEpoch}",
        name: "Stok Keluar Oleh - Staff - ${staff!.name}",
        description: _controllerDesc.text,
        createdAt: DateTime.now().toIso8601String(),
        outgoingStockItems: _items
      );

      widget.handlerAddStock(newOutgoingStock);

    } else {
      
      final List<IncomingStockItemModel> _items = items.map((item) => item as IncomingStockItemModel).toList();
      
      final newIncomingStock = IncomingStockModel(
        code: "IS${DateTime.now().toUtc().millisecondsSinceEpoch}",
        name: "Stok Masuk Oleh - Staff - ${staff!.name}",
        description: _controllerDesc.text,
        createdAt: DateTime.now().toIso8601String(),
        incomingStockItems: _items
      );

      widget.handlerAddStock(newIncomingStock);
    }

    Timer(const Duration(milliseconds: 500), () {
      _controllerDesc.text = "";
      items = [];
      setState(() {});
    });
  }

  // Views

  void viewConfirmDeleteItem(dynamic data) {

    var name = "";

    if (data.productId != null) {
      name = data.product!.name;
    }

    if (data.variantId != null) {
      name = data.variant!.name!;
    }

    if (data.ingredientId != null) {
      name = data.ingredient!.name!;
    }
    
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus item $name dari stok masuk ini?"),
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
                handlerDeleteItem(data);
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

  Widget buildItem(dynamic data) {

    dynamic pdata;

    if (data.productId != null) {
      pdata = data.product;
    }

    if (data.variantId != null) {
      pdata = data.variant;
    }

    if (data.ingredientId != null) {
      pdata = data.ingredient;
    }

    return StockItem(
      isEdit: widget.data == null,
      data: {
        "qty": data.qty,
        "data": pdata
      },
      onChange: (d) {
        if (timeId?.isActive ?? false) timeId!.cancel();
        timeId = Timer(const Duration(milliseconds: 500), () {
            
        });
      },
      onDelete: (d) {
        viewConfirmDeleteItem(data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          if (widget.data == null) Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text("Form Stok ${widget.stokOut ? "Keluar" : "Masuk"}", style: const TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Input(
                          controller: _controllerDesc,
                          title: "Deskripsi",
                          placeholder: "Deskripsi",
                          maxCharacter: 50,
                          maxLines: 10,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Items (${items.length})", style: const TextStyle(fontSize: 14, fontFamily: FontBold)),
                            TouchableOpacity(
                              onPress: handlerSearchProduct,
                              child: const Icon(
                                Boxicons.bx_plus,
                                color: primaryColor,
                                size: 22,
                              ), 
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...items.map((e) => buildItem(e))
                      ],
                    ),
                  )
                )
              ),
              if (items.isNotEmpty) ButtonOpacity(
                text: "Simpan",
                margin: const EdgeInsets.all(12),
                backgroundColor: primaryColor,
                onPress: handlerAddStock,
              )
            ],
          ),
          if (widget.data != null) Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text("#${widget.data!.code}", style: const TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text("Nama", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                        const SizedBox(height: 2),
                        Text(widget.data!.name.toString(), style: const TextStyle(fontSize: 12, color: greyTextColor)),
                        const SizedBox(height: 12),
                        const Text("Deskripsi", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                        const SizedBox(height: 2),
                        Text("${widget.data!.description!.isNotEmpty ? widget.data!.description : "-"}", style: const TextStyle(fontSize: 12, color: greyTextColor)),
                        const SizedBox(height: 12),
                        const Text("Tanggal diubah", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                        const SizedBox(height: 2),
                        Text(widget.data!.updatedAt.isNotEmpty ? formatDateFromString(widget.data!.updatedAt.toString()) : "-", style: const TextStyle(fontSize: 12, color: greyTextColor)),
                        const SizedBox(height: 12),
                        const Text("Tanggal dibuat", style: TextStyle(fontSize: 14, fontFamily: FontBold)),
                        const SizedBox(height: 2),
                        Text(formatDateFromString(widget.data!.createdAt.toString()), style: const TextStyle(fontSize: 12, color: greyTextColor)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Items (${ widget.data is IncomingStockModel ? widget.data!.incomingStockItems.length : widget.data!.outgoingStockItems.length})", style: const TextStyle(fontSize: 14, fontFamily: FontBold))
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (widget.data is IncomingStockModel && widget.data!.incomingStockItems.isNotEmpty) ...widget.data!.incomingStockItems.map(buildItem),
                        if (widget.data is OutgoingStockModel && widget.data!.outgoingStockItems.isNotEmpty) ...widget.data!.outgoingStockItems.map(buildItem),
                      ],
                    ),
                  )
                )
              ),
              if (items.isNotEmpty) ButtonOpacity(
                text: "Simpan",
                margin: const EdgeInsets.all(12),
                backgroundColor: primaryColor,
                onPress: handlerAddStock,
              )
            ],
          ),
          if (widget.data != null) Positioned(
            bottom: 12,
            right: 12,
            child: TouchableOpacity(
            onPress: () => widget.handlerFormStock!(null),
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(100)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 1, offset: Offset(0, 1))
                ]
              ),
              child: const Icon(CupertinoIcons.plus, color: Colors.white, size: 20),
            ),
          ),
          )
        ],
      ),
    );
  }
}