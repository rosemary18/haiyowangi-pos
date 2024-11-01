import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  
  final ctrlSearch = TextEditingController();
  List<SaleModel> sales = [];
  SaleModel? sale;

  final box = Hive.box("storage");

  @override
  void initState() {
    super.initState();
    handlerLoadSales();
  }

  Future<void> handlerLoadSales() async {

    sales.clear();
    final _sales = box.get("sales");

    if (_sales != null) {
      for (var item in _sales) {
        if (ctrlSearch.text.isNotEmpty) {
          if (
            item["code"].toString().toLowerCase().contains(ctrlSearch.text.toLowerCase()) || 
            item["staff"]["name"].toString().toLowerCase().contains(ctrlSearch.text.toLowerCase())
            ) {
            sales.add(SaleModel.fromJson(item));
          }
        } else {
          sales.add(SaleModel.fromJson(item));
        }
      }
    }

    setState(() {});
  }

  void handlerSelect(int i) {

    if (sale != null && sale!.code == sales[i].code) {
      sale = null;
    } else {
      sale = sales[i];
    }

    setState(() {});
  }

  void handlerDelete(int i) async {

    final _sales = box.get("sales");
    final _products = box.get("products");
    final _ingredients = box.get("ingredients");
    final salesCode = sales[i].code;

    List<SaleModel> newSales = [];
    List<ProductModel> newProducts = [];
    List<IngredientModel> newIngredients = [];

    if (_sales != null) {
      for (var item in _sales) {
        if (item["code"] != sales[i].code) {
          newSales.add(SaleModel.fromJson(item));
        }
      }
    }

    if (_products != null) {
      for (var item in _products) {
        if (item["code"] != sales[i].code) {
          newProducts.add(ProductModel.fromJson(item));
        }
      }
    }

    if (_ingredients != null) {
      for (var item in _ingredients) {
        if (item["code"] != sales[i].code) {
          newIngredients.add(IngredientModel.fromJson(item));
        }
      }
    }

    // Restore stocks

    if (sales[i].items.isNotEmpty) {
      for (var item in sales[i].items) {
        if (item.productId != null) {
          for (var p in newProducts) {
            if (p.id == item.productId) {
              if (p.ingredients.isNotEmpty) {
                for (var i in p.ingredients) {
                  for (var j in newIngredients) {
                    if (j.id == i.ingredientId) {
                      j.qty = (j.qty! + (i.qty!*item.qty!));
                    }
                  }
                }
              } else {
                p.qty = (p.qty! + item.qty!);
              }
            }
          }
        }
        if (item.variantId != null) {
          for (var p in newProducts) {
            if (p.hasVariants!) {
              for (var v in p.variants) {
                if (v.id == item.variantId) {
                  if (v.ingredients.isNotEmpty) {
                    for (var i in v.ingredients) {
                      for (var j in newIngredients) {
                        if (j.id == i.ingredientId) {
                          j.qty = (j.qty! + (i.qty!*item.qty!));
                        }
                      }
                    }
                  } else {
                    v.qty = (v.qty! + item.qty!);
                  }
                }
              }
            }
          }
        }
        if (item.packetId != null) {
          if (item.packet != null && item.packet!.items.isNotEmpty) {
            for (var p in item.packet!.items) {
              if (p.productId != null) {
                for (var pp in newProducts) {
                  if (pp.id == p.productId) {
                    if (pp.ingredients.isNotEmpty) {
                      for (var i in pp.ingredients) {
                        for (var j in newIngredients) {
                          if (j.id == i.ingredientId) {
                            j.qty = (j.qty! + (i.qty!*p.qty!));
                          }
                        }
                      }
                    } else {
                      pp.qty = (pp.qty! + p.qty!);
                    }
                  }
                }
              }
              if (p.variantId != null) {
                for (var pp in newProducts) {
                  if (pp.hasVariants!) {
                    for (var v in pp.variants) {
                      if (v.id == p.variantId) {
                        if (v.ingredients.isNotEmpty) {
                          for (var i in v.ingredients) {
                            for (var j in newIngredients) {
                              if (j.id == i.ingredientId) {
                                j.qty = (j.qty! + (i.qty!*p.qty!));
                              }
                            }
                          }
                        } else {
                          v.qty = (v.qty! + p.qty!);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    await box.put("sales", newSales.map((e) => e.toJson()).toList());
    await box.put("products", newProducts.map((e) => e.toJson()).toList());
    await box.put("ingredients", newIngredients.map((e) => e.toJson()).toList());

    if (salesCode == sale?.code) {
      sale = null;
    }

    handlerLoadSales();
  }

  // Views

  void viewDeleteConfirm(int i) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: Text("Apakah anda yakin ingin menghapus penjualan #${sales[i].code}?"),
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
                handlerDelete(i);
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

  void handlerPrint() {

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return ModalPrinter(data: sale!, printMode: true);
      }
    );
  }

  Widget viewCard(BuildContext context, int index) {

    final state = context.read<AuthBloc>().state;

    if (sales.isEmpty)  {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text("Penjualan tidak ditemukan!", style: TextStyle(color: greyTextColor, fontSize: 12)),
        ),
      );
    } 

    return TouchableOpacity(
      onPress: () => handlerSelect(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (sale != null && sale!.code == sales[index].code) ? greenLightColor : Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "#${sales[index].code!.isNotEmpty ? sales[index].code : "-"}", 
                        style: const TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis
                      ),
                      Text(formatDateFromString(sales[index].createdAt!, format: 'EEEE, dd/MM/yyyy'), style: const TextStyle(fontSize: 8, color: greyTextColor)),
                    ],
                  )
                ),
                if (state.staff?.id == sales[index].staffId) TouchableOpacity(
                  child: const Icon(
                    Boxicons.bxs_trash,
                    color: redColor,
                    size: 14
                  ), 
                  onPress: () => viewDeleteConfirm(index),
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
                      const Text("Status", style: TextStyle(fontSize: 8)),
                      Text(
                        sales[index].status == 0 ? "Pending" : sales[index].status == 1 ? "Selesai" : "Dibatalkan", 
                        style: TextStyle(fontSize: 8, color: sales[index].status == 0 ? blackColor : sales[index].status == 1 ? Colors.green : redColor)
                      )
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total", style: TextStyle(fontSize: 8)),
                      Text(parseRupiahCurrency("${sales[index].total ?? 0}"), style: const TextStyle(fontSize: 8))
                    ],
                  ),
                  const Divider(color: greyLightColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dijual oleh", style: TextStyle(fontSize: 8)),
                      Text("${sales[index].staff != null ? sales[index].staff!.name : "Pemilik"}", style: TextStyle(fontSize: 8, color: sales[index].staff != null ? blackColor : blueColor))
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

  TableRow buildRow(SaleItemModel data) {

    int selectedIndex = sale!.items.indexOf(data);

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            '${selectedIndex + 1}.',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        if (data.packetId == null) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "${data.productId != null ? data.product!.name : data.variant!.name}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        if (data.packetId != null) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                data.packet!.name ?? "",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 2),
              if (data.packet!.items.isNotEmpty) ...data.packet!.items.map((e) => Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                child: Text("• ${e.qty}x ${e.product?.name ?? e.variant?.name}", style: const TextStyle(fontSize: 8)),
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Text(
            'x${data.qty}',
            style: const TextStyle(fontSize: 12),
          ),
        )
      ]
    );
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
            Container(
              height: double.infinity,
              width: max(300, MediaQuery.of(context).size.width * .3),
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InputSearch(
                    controller: ctrlSearch,
                    onChanged: (v) => handlerLoadSales()
                  ),
                  const SizedBox(height: 8),
                  Text("Daftar Penjualan ${sales.isNotEmpty ? "(${sales.length})" : ""}", style: const TextStyle(color: blackColor, fontSize: 12)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: handlerLoadSales,
                      child: ListView.builder(
                        itemCount: sales.isNotEmpty ? sales.length : 1,
                        itemBuilder: viewCard,
                        physics: const AlwaysScrollableScrollPhysics(),
                      ), 
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: 1,
              color: Colors.black12,
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 0),
                width: double.infinity,
                child: sale != null ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text("#${sale!.code}", style: const TextStyle(color: blackColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        TouchableOpacity(
                          onPress: handlerPrint,
                          child: const Icon(
                            Boxicons.bxs_printer,
                            color: primaryColor,
                            size: 24
                          ), 
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Divider(color: greyLightColor, thickness: 1.2),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Daftar item", style: TextStyle(color: blackColor, fontSize: 14, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Table(
                                        border: TableBorder.all(
                                          borderRadius: BorderRadius.circular(4),
                                          color: greyLightColor
                                        ),
                                        defaultVerticalAlignment: TableCellVerticalAlignment.top,
                                        columnWidths: const <int, TableColumnWidth>{
                                          0: FixedColumnWidth(56.0),
                                          1: FlexColumnWidth(2),
                                          2: FixedColumnWidth(120.0),
                                        },
                                        children: [
                                          const TableRow(
                                            decoration: BoxDecoration(color: white1Color), // Row header
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                child: Text(
                                                  'No',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                child: Text(
                                                  'Item',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                child: Text(
                                                  'Jumlah',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (sale!.items.isNotEmpty) ...sale!.items.map(buildRow),
                                          if (sale!.items.isEmpty) const TableRow(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                child: Text(
                                                  '1.',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                child: Text(
                                                  '...',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                child: Text(
                                                  '...',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ]
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 340,
                              height: double.infinity,
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Faktur", style: TextStyle(color: blackColor, fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: const [
                                          BoxShadow(color: Color.fromARGB(25, 0, 0, 0), blurRadius: 1, spreadRadius: 1, offset: Offset(1, 1))
                                        ]
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: Text("Subtotal", style: TextStyle(fontSize: 12)),
                                              ),
                                              Text(parseRupiahCurrency(sale!.invoice!.subTotal.toString()), style: const TextStyle(fontSize: 12))
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: Text("Diskon", style: TextStyle(fontSize: 12)),
                                              ),
                                              Text(parseRupiahCurrency(sale!.invoice!.discount.toString()), style: const TextStyle(fontSize: 12, color: redColor))
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          const Divider(color: greyLightColor),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: Text("Total", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              ),
                                              Text(parseRupiahCurrency(sale!.invoice!.total.toString()), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          const Divider(color: greyLightColor),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Expanded(
                                                child: Text("Metode Pembayaran", style: TextStyle(fontSize: 12)),
                                              ),
                                              Text(sale!.paymentType!.name ?? "", style: const TextStyle(fontSize: 12))
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          if (sale!.paymentType!.name?.toLowerCase() == "cash") Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Tunai", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(parseRupiahCurrency(sale!.invoice!.cash.toString()), style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Kembalian", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(parseRupiahCurrency(sale!.invoice!.changeMoney.toString()), style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (sale!.paymentType!.name?.toLowerCase() != "cash") Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Bank Pengirim", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.accountBank ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Akun Bank Pengirim", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.accountNumber ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Bank Penerima", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.receiverAccountBank ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Akun Bank Penerima", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.receiverAccountNumber ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Akun Bank Penerima", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.receiverAccountNumber ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Akun Bank Penerima", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.receiverAccountNumber ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text("Akun Bank Penerima", style: TextStyle(fontSize: 12)),
                                                  ),
                                                  Text(sale!.invoice!.payment!.receiverAccountNumber ?? "", style: const TextStyle(fontSize: 12))
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              const Divider(color: greyLightColor),
                                              const SizedBox(height: 6),
                                              const Text("Bukti Transfer: ", style: TextStyle(fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Container(
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: white1Color
                                                ),
                                                child: Image.file(
                                                  File(sale!.invoice!.payment!.img ?? ""), 
                                                  width: 340, 
                                                  height: 300,
                                                  fit: BoxFit.cover
                                                )
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ]
                                ),
                              )
                            )
                          ]
                        ),
                      )
                    )
                  ],
                ) : null,
              )
            )
          ],
        )
      )
    );
  }
}