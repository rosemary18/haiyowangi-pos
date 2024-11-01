import 'dart:io';
import 'dart:math';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {

  final box = Hive.box("storage");
  final ctrlSearch = TextEditingController();
  final ctrlCash = TextEditingController();
  final ctrlNominal = TextEditingController();
  final bankAccController = TextEditingController();
  final bankAccNumController = TextEditingController();
  final bankRecAccController = TextEditingController();
  final bankRecAccNumController = TextEditingController();
  final ctrlPaymentType = SingleSelectController<Object?>(null);
  final ctrlDiscount = SingleSelectController<Object?>(null);
  Directory? appDir;

  bool showProduct = true;
  bool showVariant = true;
  bool showPacket = true;
  bool collapseProduct = true;
  bool collapseVariant = true;
  bool collapsePacket = true;

  List<ProductModel> productsSource_ = [];
  List<ProductModel> productsSource = [];
  List<VariantModel> variantsSource = [];
  List<PacketModel> packetsSource = [];
  List<IngredientModel> ingredients = [];
  List<ProductModel> products = [];
  List<VariantModel> variants = [];
  List<PacketModel> packets = [];
  List<PaymentTypeModel> paymentTypes = [];
  List<DiscountModel> discounts = [];

  List<Map<String, dynamic>> items = [];
  File? img;

  @override
  void initState() {

    super.initState();

    handlerGetData();
    handlerGetDir();
  }

  void handlerGetData() async {

    productsSource_.clear();
    productsSource.clear();
    variantsSource.clear();
    packetsSource.clear();
    products.clear();
    variants.clear();
    packets.clear();
    ingredients.clear();
    paymentTypes.clear();
    discounts.clear();
    
    final xproducts = box.get("products");
    if (xproducts != null) {
      for (var item in xproducts) {
        final xitem = ProductModel.fromJson(item);
        if (xitem.hasVariants!) {
          for (var variant in xitem.variants) {
            if (ctrlSearch.text.isNotEmpty) {
              if (variant.name!.toLowerCase().contains(ctrlSearch.text.toLowerCase())) {
                variantsSource.add(variant);
              }
            } else {
              variantsSource.add(variant);
            }
          }
        } else {
          if (ctrlSearch.text.isNotEmpty) {
            if (xitem.name.toLowerCase().contains(ctrlSearch.text.toLowerCase())) {
              productsSource.add(xitem);
            }
          } else {
            productsSource.add(xitem);
          }
        }
        productsSource_.add(xitem);
      }
    }

    final xpackets = box.get("packets");
    if (xpackets != null) {
      for (var item in xpackets) {
        if (ctrlSearch.text.isNotEmpty) {
          if (item["name"]!.toLowerCase().contains(ctrlSearch.text.toLowerCase())) {
            packetsSource.add(PacketModel.fromJson(item));
          }
        } else {
          packetsSource.add(PacketModel.fromJson(item));
        }
      }
    }
    
    if (showProduct) {
      for (var item in productsSource) {
        products.add(item);
      }
    } 
    if (showVariant) {
      for (var item in variantsSource) {
        variants.add(item);
      }
    }
    if (showPacket) {
      for (var item in packetsSource) {
        packets.add(item);
      }
    }

    final ingredientsSource = box.get("ingredients");
    if (ingredientsSource != null) {
      for (var item in ingredientsSource) {
        ingredients.add(IngredientModel.fromJson(item));
      }
    }

    final paymentTypesSource = box.get("paymenttypes");
    if (paymentTypesSource != null) {
      for (var item in paymentTypesSource) {
        paymentTypes.add(PaymentTypeModel.fromJson(item));
      }
    }

    final discountsSource = box.get("discounts");
    if (discountsSource != null) {
      for (var item in discountsSource) {
        if (
          item["special_for_product_id"] == null && 
          item["special_for_variant_id"] == null && 
          item["special_for_packet_id"] == null
          ) {
          discounts.add(DiscountModel.fromJson(item));
        }
      }
    }

    setState(() {});
  }

  dynamic handlerCalculateStageQty(dynamic data) {

    if (data.runtimeType == ProductModel) {
      for (var it in productsSource) {
        if (it.id == data.id) {
          data = ProductModel.fromJson(it.toJson());
        }
      }
    }
    if (data.runtimeType == VariantModel) {
      for (var it in variantsSource) {
        if (it.id == data.id) {
          data = VariantModel.fromJson(it.toJson());
        }
      }
    }

    List<IngredientModel> stageIngredients = [];

    for (var s in ingredients) {

      IngredientModel item = IngredientModel.fromJson(s.toJson());

      for (var i in items) {
        if (i["data"].runtimeType == PacketModel) {
          if (i["data"].items?.isNotEmpty ?? false) {
            for (var x in i["data"].items) {
              List<IngredientItemModel>  iItems = x.productId != null ? x.product.ingredients : x.variant.ingredients;
              if (iItems.isNotEmpty) {
                for (var y in iItems) {
                  if (y.ingredientId == item.id) {
                    double usedQty = 0.0;
                    usedQty = i["qty"] * (x.qty * y.qty);
                    item.qty = (item.qty! - usedQty);
                  }
                }
              }
            }
          }
        } else if (i["data"].ingredients?.isNotEmpty ?? false) {
          for (var x in i["data"].ingredients) {
            if (x.ingredientId == item.id) {
              double usedQty = 0.0;
              usedQty = i["qty"] * x.qty;
              item.qty = (item.qty! - usedQty);
            }
          }
        }
      }

      stageIngredients.add(item);
    }

    if (data.runtimeType == PacketModel) {
      if (data.items?.isNotEmpty ?? false) {
        double qty = 0.0;
        List<double> possibleItemUsed = [];
        for (var item in data.items) {
          double qty = 0.0;
          List<double> possibleUsed = [];
          List<IngredientItemModel>  iItems = item.productId != null ? item.product.ingredients : item.variant.ingredients;
          if (iItems.isNotEmpty) {
            for (var y in iItems) {
              for (var i in stageIngredients) {
                if (i.id == y.ingredientId) {
                  possibleUsed.add(i.qty!/y.qty!);
                }
              }
            }
            if (possibleUsed.isNotEmpty) {
              qty = possibleUsed.reduce((v, e) => min(v, e));
            }
            possibleItemUsed.add(qty < item.qty! ? 0.0 : qty/item.qty!);
          } else {
            // Already have specific product in packet
            double usedQty = 0.0;
            if (items.isNotEmpty) {
              for (var i in items) {
                if (i["data"].runtimeType == PacketModel) {
                  if (i["data"].items?.isNotEmpty ?? false) {
                    for (var x in i["data"].items) {
                      if (
                        ((item.productId != null && x.productId != null) && x.productId == item.productId) ||
                        ((item.variantId != null && x.variantId != null) && x.variantId == item.variantId)
                        ) {
                        usedQty += i["qty"]*x.qty;
                      }
                    }
                  }
                } else if (i["data"].ingredients?.isEmpty ?? false) {
                  if (
                    ((i["data"].runtimeType == ProductModel) && (item.productId != null) && (i["data"].id == item.productId)) 
                    || 
                    ((i["data"].runtimeType == VariantModel) && (item.variantId != null) && (i["data"].id == item.variantId))
                  ) {
                    usedQty += i["qty"];
                  }
                }
              }
            }
            double actualQty = (item.productId != null ? item.product?.qty! : item.variant?.qty!);
            double restQty = actualQty-usedQty;
            possibleItemUsed.add(item.qty > restQty ? 0 : restQty/item.qty!);
          }
        }
        if (possibleItemUsed.isNotEmpty) {
          qty = possibleItemUsed.reduce((v, e) => min(v, e)).floor().toDouble();
        }
        data.qty = qty;
      }
    } else if (data.ingredients?.isNotEmpty ?? false) {
      double qty = 0.0;
      List<double> possibleUsed = [];
      for (var item in data.ingredients) {
        for (var i in stageIngredients) {
          if (i.id == item.ingredientId) {
            possibleUsed.add(i.qty!/item.qty!);
          }
        }
      }
      if (possibleUsed.isNotEmpty) {
        qty = possibleUsed.reduce((v, e) => min(v, e));
      }
      data.qty = qty;
    } else if (items.isNotEmpty) {
      for (var item in items) {
        if ((item["data"].runtimeType == PacketModel) && item["data"].items?.isNotEmpty) {
          for (var it in item["data"].items) {
            if (
              ((data.runtimeType == ProductModel) && (it.productId == data.id)) ||
              ((data.runtimeType == VariantModel) && (it.variantId == data.id))
            ) {
              data.qty = data.qty-(item["qty"]*it.qty);
            }
          }
        } else if (data.runtimeType == item["data"].runtimeType && item["data"].id == data.id) {
          data.qty = data.qty-item["qty"];
        } 
      }
    }

    return data;
  }

  void handlerGetDir() async {
    appDir = await getApplicationDocumentsDirectory();
    setState(() {});
  }

  void handlerSearch(String query) async {

    handlerGetData();
  }

  void handlerShowData(String type) {

    if (type == "product") {
      showProduct = !showProduct;
    } else if (type == "variant") {
      showVariant = !showVariant;
    } else if (type == "packet") {
      showPacket = !showPacket;
    }

    handlerGetData();
    setState(() {});
  }

  void handlerCollapseData(String type) {

    if (type == "product") {
      collapseProduct = !collapseProduct;
    } else if (type == "variant") {
      collapseVariant = !collapseVariant;
    } else if (type == "packet") {
      collapsePacket = !collapsePacket;
    } 
    
    setState(() {});
  }

  void handlerSelectProduct(dynamic item) {

    int? existIndex;
    for (var e in items) {
      if (e["data"]?.runtimeType == item.runtimeType && e["data"]?.id == item?.id) {
        existIndex = items.indexOf(e);
        break;
      }
    }

    if (existIndex != null) {
      items.remove(items[existIndex]);
    } else if (item.qty > 0) {
      double qty = min(1, item.qty ?? 1);
      items.add({
        "qty": qty,
        "data": item
      });
    }

    if (items.isEmpty) {
      ctrlPaymentType.clear();
      ctrlDiscount.clear();
    }

    setState(() {});
  }

  Map<String, dynamic> handlerCalculateInvoice() {

    Map<String, dynamic> data = {
      "qty": 0.0,
      "subtotal": 0.0,
      "product_discount": 0.0,
      "total_discount": 0.0,
      "total": 0.0,
    };

    double totalQty = 0.0;

    if (items.isNotEmpty) {

      double subtotal = 0.0;
      double disc_total = 0.0;

      for (var item in items) {

        subtotal += (item["data"]?.price ?? 0.0) * item["qty"];
        totalQty += item["qty"];

        // Check if there are discounts
        if (item["data"]?.discounts?.isNotEmpty ?? false) {
          for (var discount in item["data"]?.discounts) {
            // Check if the discount is valid
            if (discount.validUntil != null && discount.dateValid != null) {  
              
              final validUntilDate = DateTime.tryParse(discount.validUntil!);
              final dateValidDate = DateTime.tryParse(discount.dateValid!);

              // Check if the parsed dates are valid
              if (validUntilDate != null && dateValidDate != null) {
                // Get the current date
                final currentDate = DateTime.now();
                // Compare dates
                if (isSameOrBeforeIgnoringTime(currentDate, validUntilDate) && isSameOrAfterIgnoringTime(currentDate, dateValidDate)) {
                  // Discount calculation
                  if (item["qty"] >= (discount.minItemsQty ?? 0)) {
                    double disc =  discount.nominal!;
                    double price = (item["data"]?.price ?? 0.0)*1.0;
                    if (discount.isPercentage) {
                      disc = (price/100)*discount.percentage!;
                    }
                    double total = disc*min(item["qty"], discount.maxItemsQty! > 0 ? discount.maxItemsQty! : item["qty"]);                    
                    disc_total += total;
                  }
                }
              }
            }
          }
        }
      }

      data["qty"] = totalQty;
      data["product_discount"] = disc_total;
      data["subtotal"] = subtotal;

      if (ctrlDiscount.value.toString().isNotEmpty) {

        for (var discount in discounts) {
          if (discount.name == ctrlDiscount.value.toString()) {
            if (discount.validUntil != null && discount.dateValid != null) {  
              
              final validUntilDate = DateTime.tryParse(discount.validUntil!);
              final dateValidDate = DateTime.tryParse(discount.dateValid!);

              // Check if the parsed dates are valid
              if (validUntilDate != null && dateValidDate != null) {
                // Get the current date
                final currentDate = DateTime.now();
                // Compare dates
                if (currentDate.isBefore(validUntilDate) && currentDate.isAfter(dateValidDate)) {
                  // Discount calculation
                  if (totalQty >= (discount.minItemsQty ?? 0)) {
                    double disc =  discount.nominal!;
                    if (discount.isPercentage) {
                      disc = ((subtotal - disc_total)/100)*discount.percentage!;
                    }                  
                    disc_total += disc;
                  }
                }
              }
            }
          }
        }
      }

      data["total_discount"] = disc_total;
      data["total"] = subtotal - disc_total;

    }

    return data;
  }

  void handlerCancelOrder() {

    items.clear();
    ctrlPaymentType.clear();
    ctrlDiscount.clear();
    setState(() {});
  }

  void handlerSetImage(File? x) async {

    setState(() {
      img = x;
    });
  }

  Future<void> handlerPayment() async {

    Map<String, dynamic> inv = handlerCalculateInvoice();
    final state = context.read<AuthBloc>().state;

    PaymentTypeModel paymentType = PaymentTypeModel();
    DiscountModel? discount;
    SaleModel sale = SaleModel();
    PaymentModel payment = PaymentModel();
    InvoiceModel invoice = InvoiceModel();
    List<SaleItemModel> saleItems = [];
    List<IngredientModel> stageIngredients = [];
    List<ProductModel> stageProducts = [];

    for (var item in paymentTypes) {
      if (item.name == ctrlPaymentType.value.toString()) {
        paymentType = item;
        break;
      }
    }

    if (ctrlDiscount.value.toString() != "null") {
      for (var item in discounts) {
        if (item.name == ctrlDiscount.value.toString()) {
          discount = item;
          break;
        }
      }
    }

    for (var item in items) {
      if (item["data"].runtimeType == PacketModel) {
        saleItems.add(SaleItemModel(
          qty: item["qty"],
          packetId: item["data"].id,
          packet: item["data"],
          createdAt: DateTime.now().toIso8601String(),
        ));
      }
      if (item["data"].runtimeType == ProductModel) {
        saleItems.add(SaleItemModel(
          qty: item["qty"],
          productId: item["data"].id,
          product: item["data"],
          createdAt: DateTime.now().toIso8601String(),
        ));
      }
      if (item["data"].runtimeType == VariantModel) {
        saleItems.add(SaleItemModel(
          qty: item["qty"],
          variantId: item["data"].id,
          variant: item["data"],
          createdAt: DateTime.now().toIso8601String(),
        ));
      }
    }

    // Set payment info

    if (ctrlPaymentType.value.toString().toLowerCase() != "cash") {
      payment.accountBank = bankAccController.text;
      payment.accountNumber = bankAccNumController.text;
      payment.receiverAccountBank = bankRecAccController.text;
      payment.receiverAccountNumber = bankRecAccNumController.text;

      if (img != null) {
        // Tentukan path tujuan di dalam direktori aplikasi
        String newPath = '${appDir!.path}/${DateTime.now().millisecondsSinceEpoch}.${img!.path.split(".").last}';
        // Menyalin file ke direktori aplikasi
        await img?.copy(newPath);
        payment.img = newPath;
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("Foto bukti transfer harus di sertakan!"),
          )
        );
        return;
      }
    }
    
    payment.code = "PY${DateTime.now().millisecondsSinceEpoch}";
    payment.nominal = double.parse(parsePriceFromInput(ctrlCash.text)).floor();
    payment.updatedAt = formatDateTimeLocale();
    payment.createdAt = formatDateTimeLocale();

    // Set invoice

    invoice.code = "INV${DateTime.now().millisecondsSinceEpoch}";
    invoice.subTotal = inv["subtotal"]?.floor();
    invoice.total = inv["total"]?.floor();
    invoice.cash = double.parse(parsePriceFromInput(ctrlCash.text)).floor();
    invoice.changeMoney = invoice.cash! - invoice.total!;
    invoice.discount = inv["total_discount"]?.floor();
    invoice.paymentId = paymentType.id;
    invoice.status = 1;
    invoice.payment = payment;
    invoice.createdAt = formatDateTimeLocale();
    invoice.updatedAt = formatDateTimeLocale();

    // Set sales

    sale.code = "SO${DateTime.now().millisecondsSinceEpoch}";
    sale.items = saleItems;
    sale.paymentTypeId = paymentType.id;
    sale.paymentType = paymentType;
    sale.discountId = discount?.id;
    sale.discount = discount;
    sale.status = 1;
    sale.items = saleItems;
    sale.invoice = invoice;
    sale.total = inv["total"];
    sale.staff = state.staff;
    sale.staffId = state.staff!.id;
    sale.storeId = state.store!.id;
    sale.updatedAt = formatDateTimeLocale();
    sale.createdAt = formatDateTimeLocale();
    
    // Calculate remaining stock

    for (var s in ingredients) {

      IngredientModel item = IngredientModel.fromJson(s.toJson());

      for (var i in items) {
        if (i["data"].runtimeType == PacketModel) {
          if (i["data"].items?.isNotEmpty ?? false) {
            for (var x in i["data"].items) {
              List<IngredientItemModel>  iItems = x.productId != null ? x.product.ingredients : x.variant.ingredients;
              if (iItems.isNotEmpty) {
                for (var y in iItems) {
                  if (y.ingredientId == item.id) {
                    double usedQty = 0.0;
                    usedQty = i["qty"] * (x.qty * y.qty);
                    item.qty = (item.qty! - usedQty);
                  }
                }
              }
            }
          }
        } else if (i["data"].ingredients?.isNotEmpty ?? false) {
          for (var x in i["data"].ingredients) {
            if (x.ingredientId == item.id) {
              double usedQty = 0.0;
              usedQty = i["qty"] * x.qty;
              item.qty = (item.qty! - usedQty);
            }
          }
        }
      }

      stageIngredients.add(item);
    }

    for (var s in productsSource_) {

      ProductModel item = ProductModel.fromJson(s.toJson());

      for (var i in items) {
        if (i["data"].runtimeType == ProductModel && i["data"].id == item.id) {
          if (i["data"].ingredients?.isEmpty ?? false) {
            item.qty = (item.qty! - i["qty"]);
          }
        }
        if (i["data"].runtimeType == PacketModel) {
          if (i["data"].items?.isNotEmpty ?? false) {
            for (var x in i["data"].items) {
              if (x.productId != null && x.productId == item.id) {
                item.qty = (item.qty! - (i["qty"]*x.qty));
              }
            }
          }
        }
      }

      if (item.hasVariants!) {
        for (var v in item.variants) {
          int index = item.variants.indexOf(v);
          for (var i in items) {
            if (i["data"].runtimeType == VariantModel && i["data"].id == v.id) {
              if (i["data"].ingredients?.isEmpty ?? false) {
                item.variants[index].qty = (v.qty! - i["qty"]);
              }
            }
            if (i["data"].runtimeType == PacketModel) {
              if (i["data"].items?.isNotEmpty ?? false) {
                for (var x in i["data"].items) {
                  if (x.variantId != null && x.variantId == v.id) {
                    item.variants[index].qty = (v.qty! - (i["qty"]*x.qty));
                  }
                }
              }
            }
          }
        }
      }

      stageProducts.add(item);
    }

    // Saving
    
    List<SaleModel> newSales = [sale];
    final sales = box.get("sales");
    if (sales != null) {
      for (var s in sales) {
        newSales.add(SaleModel.fromJson(s));
      }
    }
    
    try {

      await box.put("sales", newSales.map((e) => e.toJson()).toList());
      await box.put("products", stageProducts.map((e) => e.toJson()).toList());
      await box.put("ingredients", stageIngredients.map((e) => e.toJson()).toList());

      items.clear();
      ctrlCash.clear();
      ctrlNominal.clear();
      ctrlDiscount.clear();
      ctrlPaymentType.clear();
      bankAccController.clear();
      bankAccNumController.clear();
      bankRecAccController.clear();
      bankRecAccNumController.clear();
      img = null;

      scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(content: Text("Penjualan baru telah berhasil ditambahkan!"), backgroundColor: Colors.green));
    } catch (e) {
      debugPrint(e.toString());
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }

    handlerGetData();
    Future.delayed(const Duration(milliseconds: 500), () => viewSuccessOrder(sale));
  }

  void handlerProcessPayment() async {

    Map<String, dynamic> inv = handlerCalculateInvoice();
    ctrlCash.text = "${inv["total"]?.floor() ?? "0"}";
    ctrlNominal.text = "${inv["total"]?.floor() ?? "0"}";
    img = null;

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selesaikan Pembayaran', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          content: SizedBox(
            width: MediaQuery.of(context).size.width*.75,
            child: Column(
              children: ctrlPaymentType.value.toString().toLowerCase() == "cash" ? [
                Input(
                  controller: ctrlCash,
                  isCurrency: true,
                  title: "Uang Tunai",
                )
              ] : [
                PickerImage(
                  img: img,
                  onSelected: handlerSetImage,
                ),
                const SizedBox(height: 12),
                Input(
                  controller: bankAccController,
                  placeholder: "Contoh: BRI/ANDI",
                  title: "Akun Bank",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: bankAccNumController,
                  placeholder: "Contoh: 0331089675567",
                  title: "Nomor Akun Bank",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: bankRecAccController,
                  placeholder: "Contoh: BRI/ANDI",
                  title: "Akun Bank Penerima",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: bankRecAccNumController,
                  placeholder: "Contoh: 0331089675567",
                  title: "Nomor Akun Bank Penerima",
                ),
                const SizedBox(height: 8),
                Input(
                  controller: ctrlNominal,
                  enabled: false,
                  readOnly: true,
                  isCurrency: true,
                  title: "Nominal",
                )
              ],
            ),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          scrollable: true,
          shadowColor: primaryColor.withOpacity(0.2),
          insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            TouchableOpacity(
              onPress: () async {
                Navigator.pop(context);
                handlerPayment();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(left: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'Bayar', 
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

  Map<String, dynamic>? handlerCalculateDiscountProduct({List<DiscountModel> discounts = const [], double qty = 0, double price = 0}) {

    Map<String, dynamic>? res = {};
    List<String> appliedDiscounts = [];

    if (discounts.isNotEmpty) {

      bool hasActiveDiscount = false;

      for (var discount in discounts) {
        if (discount.validUntil != null && discount.dateValid != null) {  
          
          final validUntilDate = DateTime.tryParse(discount.validUntil!);
          final dateValidDate = DateTime.tryParse(discount.dateValid!);


          // Check if the parsed dates are valid
          if (validUntilDate != null && dateValidDate != null) {

            // Get the current date
            final currentDate = DateTime.now();

            // Compare dates
            if (isSameOrBeforeIgnoringTime(currentDate, validUntilDate) && isSameOrAfterIgnoringTime(currentDate, dateValidDate)) {
              
              hasActiveDiscount = true;

              // Discount calculation
              if (qty > 0 && price > 0 && (qty >= (discount.minItemsQty ?? 0))) {
                double disc =  discount.nominal!;
                if (discount.isPercentage) {
                  disc = (price/100)*discount.percentage!;
                }
                double total = disc*min(qty, discount.maxItemsQty! > 0 ? discount.maxItemsQty! : qty);
                String t = "[#${discount.code}]: ${parseRupiahCurrency(total.toString())}";
                if (discount.isPercentage) {
                  t = "$t (${discount.percentage}%)";
                }
                appliedDiscounts.add(t);
              }
            }
          }
        }
      }

      if (!hasActiveDiscount) {
        return null;
      }

      res = {
        "discounts": appliedDiscounts
      };

      return res;
    }
    
    return null;
  }

  void viewSuccessOrder(SaleModel data) {

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return ModalPrinter(data: data);
      }
    );
  }

  // Views

  Widget buildFilterData(String t, Function() onPress) {

    bool active = false;
    if (t == "Produk") {
      active = showProduct;
    } else if (t == "Varian") {
      active = showVariant;
    } else if (t == "Paket") {
      active = showPacket;
    }

    return TouchableOpacity(
      onPress: onPress,
      child: Container(
        constraints: const BoxConstraints(minWidth: 70, maxWidth: 120),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: active ? primaryColor : greyLightColor),
        ),
        child: Text(t, textAlign: TextAlign.center, style: TextStyle(color: active ? primaryColor : greyTextColor)),
      )
    );
  }

  Widget buildDivider(String t, Function() onPress) {

    bool active = false;
    if (t.contains("Produk")) {
      active = collapseProduct;
    } else if (t.contains("Varian")) {
      active = collapseVariant;
    } else if (t.contains("Paket")) {
      active = collapsePacket;
    }

    return TouchableOpacity(
      onPress: onPress,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: white1Color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t, style: const TextStyle(color: greyTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
            Icon(
              active ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
              color: blackColor,
              size: 12,
            )
          ],
        ),
      ),
    );
  }

  Widget buildCard(dynamic source) {

    dynamic data = handlerCalculateStageQty(source);
    int? selectedIndex;
    Map<String, dynamic>? discount = handlerCalculateDiscountProduct(discounts: source.discounts);

    for (var item in items) {
      if (item["data"]?.runtimeType == data.runtimeType && item["data"]?.id == data?.id) {
        selectedIndex = items.indexOf(item);
        break;
      }
    }

    if (data.runtimeType == PacketModel) {
      return TouchableOpacity(
        onPress: () => handlerSelectProduct(data),
        child: Container(
          width: 88,
          constraints: const BoxConstraints(minHeight: 88),
          decoration: BoxDecoration(
            color: selectedIndex != null ? greenLightColor : !(data.qty > 0) ? white1Color : Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(.4, .4),
              ),
            ]
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data?.name, 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 2),
                    Text(
                      parseRupiahCurrency("${data.price}"), 
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 6),
                    const Text("Item:", style: TextStyle(fontSize: 8, color: greyTextColor)),
                    const SizedBox(height: 4),
                    if (data?.items?.isNotEmpty) ...data?.items?.map((e) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      child: Text("• ${e.qty}x ${e?.product?.name ?? e?.variant?.name}", style: const TextStyle(fontSize: 8)),
                    )).toList()
                  ],
                ),
              ),
              if (discount != null) Positioned(
                top: 0,
                right: 0,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: const BoxDecoration(
                    color: redColor,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
                  ),
                  child: const Icon(
                    Boxicons.bxs_discount,
                    color: white1Color,
                    size: 12,
                  )
                ),
              ),
            ],
          ),
        ),
      );
    }

    return TouchableOpacity(
      onPress: () => handlerSelectProduct(data),
      child: Container(
        width: 88,
        constraints: const BoxConstraints(minHeight: 88),
        decoration: BoxDecoration(
          color: selectedIndex != null ? greenLightColor : !(data.qty > 0) ? white1Color : Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(.4, .4),
            ),
          ]
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    width: double.infinity,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: greyColor,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: (data?.img?.isNotEmpty && (getImagePath(appDir, data!.img?.split("/images/")!.last).isNotEmpty)) ? Image.file(File(getImagePath(appDir, data!.img?.split("/images/")?.last)), fit: BoxFit.fill) : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data?.name, 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${data!.qty.toString()} ${data!.uom!.name}", 
                    style: const TextStyle(fontSize: 8, color: greyTextColor, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 2),
                  Text(
                    parseRupiahCurrency("${data.price}"), 
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
            ),
            if (discount != null) Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  color: redColor,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
                ),
                child: const Icon(
                  Boxicons.bxs_discount,
                  color: white1Color,
                  size: 12,
                )
              ),
            ),
          ]
        )
      ),
    );
  }

  TableRow buildRow(dynamic data) {

    final ctrlQty = TextEditingController();
    int selectedIndex = items.indexOf(data);

    data["data"] = handlerCalculateStageQty(data["data"]);
    ctrlQty.text = data["qty"].toString();
    double maxQty = 0.0;

    maxQty = (data["data"]?.qty ?? 0.0) + data["qty"];

    Map<String, dynamic>? discount = handlerCalculateDiscountProduct(discounts: data["data"].discounts, qty: data["qty"]*1.0, price: data["data"].price*1.0);

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TouchableOpacity(
                onPress: () => handlerSelectProduct(data["data"]),
                child: const Icon(
                  Boxicons.bx_x_circle,
                  color: redColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${items.indexOf(data) + 1}.',
                style: const TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        if (data["data"]?.runtimeType != PacketModel) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                data["data"]?.name,
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "@ ${parseRupiahCurrency("${data["data"]?.price}")}",
                style: const TextStyle(fontSize: 8, color: blackColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              if (discount != null && discount["discounts"]?.isNotEmpty) ...discount["discounts"]?.map((e) => Text(
                e.toString(),
                style: const TextStyle(fontSize: 8, color: redColor),
              )),
            ],
          ),
        ),
        if (data["data"]?.runtimeType == PacketModel) Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                data["data"]?.name,
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "@ ${parseRupiahCurrency("${data["data"]?.price}")}",
                style: const TextStyle(fontSize: 8, color: blackColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              if (discount != null && discount["discounts"]?.isNotEmpty) ...discount["discounts"]?.map((e) => Text(
                e.toString(),
                style: const TextStyle(fontSize: 8, color: redColor),
              )),
              const SizedBox(height: 2),
              if (data["data"]?.items?.isNotEmpty) ...data["data"]?.items?.map((e) => Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                child: Text("• ${e.qty}x ${e?.product?.name ?? e?.variant?.name}", style: const TextStyle(fontSize: 8)),
              )).toList()
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: InputMultiplication(
            controller: ctrlQty, 
            minNumber: 0.1,
            maxNumber: maxQty,
            onChanged: (v) {
              items[selectedIndex]["qty"] = double.parse(v);
              setState(() {});
            },
          ),
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> inv = {};
    DiscountModel? discount;

    inv = handlerCalculateInvoice();
    if (ctrlDiscount.value.toString().isNotEmpty) {
      for (var e in discounts) {
        if (e.name == ctrlDiscount.value.toString()) {
          discount = e;
        }
      }
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (c, s) {

      },
      builder: (c, s) {
        return Scaffold(
          body: Container(
            color: white1Color,
            height: double.infinity,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(
                                child: Text("Produk", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                              ),
                              SizedBox(
                                width: 350,
                                child: InputSearch(
                                  controller: ctrlSearch,
                                  onChanged: handlerSearch,
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildFilterData("Produk", () => handlerShowData("product")),
                                buildFilterData("Varian", () => handlerShowData("variant")),
                                buildFilterData("Paket", () => handlerShowData("packet")),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (showProduct) buildDivider("Produk (${products.length})", () => handlerCollapseData("product")),
                                  if (showProduct &&collapseProduct && products.isNotEmpty) Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: products.map(buildCard).toList(),
                                    ),
                                  ),
                                  if (showVariant) buildDivider("Varian (${variants.length})", () => handlerCollapseData("variant")),
                                  if (showVariant && collapseVariant && variants.isNotEmpty) Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: variants.map(buildCard).toList(),
                                    ),
                                  ),
                                  if (showPacket) buildDivider("Paket (${packets.length})", () => handlerCollapseData("packet")),
                                  if (showPacket && collapsePacket && packets.isNotEmpty) Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: packets.map(buildCard).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        )
                      ]
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: max(300, MediaQuery.of(context).size.width*.33),
                  height: double.infinity,
                  constraints: const BoxConstraints(minHeight: 300),
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(minHeight: 250),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text("Pesanan ${items.isNotEmpty ? "(${items.length})" : ""}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                                    ),
                                    const TimeDisplay()
                                  ],
                                ),
                                const SizedBox(height: 12),
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
                                    ...items.map(buildRow),
                                    if (items.isEmpty) const TableRow(
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
                                ),
                                const SizedBox(height: 12),
                                const Divider(thickness: 1, color: greyLightColor),const SizedBox(height: 6),
                                const SizedBox(height: 6),
                                InputDropDown(
                                  controller: ctrlPaymentType,
                                  list: paymentTypes.map((e) => "${e.name}").toList(),
                                  title: "Metode Pembayaran",
                                  placeholder: "Pilih",
                                  onChanged: (value) {
                                    setState(() {});
                                  }
                                ),
                                const SizedBox(height: 6),
                                InputDropDown(
                                  controller: ctrlDiscount,
                                  list: discounts.map((e) => "${e.name}").toList(),
                                  title: "Diskon",
                                  placeholder: "Pilih",
                                  onChanged: (value) {
                                    setState(() {});
                                  }
                                ),
                                if (discount != null) const SizedBox(height: 4),
                                if (discount != null && (discount.minItemsQty! > 0)) Text("* Min. qty pemesanan ${discount.minItemsQty}", style: const TextStyle(fontSize: 9, color: greyTextColor)),
                                if (discount != null && (discount.isPercentage)) Text("* Diskon sebesar ${discount.percentage}%", style: const TextStyle(fontSize: 9, color: greyTextColor)),
                                if (discount != null && (!discount.isPercentage)) Text("* Diskon sebesar ${parseRupiahCurrency(discount.nominal.toString())}", style: const TextStyle(fontSize: 9, color: greyTextColor)),
                                const SizedBox(height: 12),
                                const Divider(thickness: 1, color: greyLightColor),const SizedBox(height: 6),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text("Subtotal", style: TextStyle(fontSize: 12)),
                                    ),
                                    Text(parseRupiahCurrency(inv["subtotal"].toString()), style: const TextStyle(fontSize: 12))
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text("Diskon", style: TextStyle(fontSize: 12)),
                                    ),
                                    Text(
                                      (inv["product_discount"] > 0 && inv["product_discount"] < inv["total_discount"]) ? 
                                      "${parseRupiahCurrency(inv["product_discount"].toString())} + ${parseRupiahCurrency((inv["total_discount"] - inv["product_discount"]).toString())}" 
                                      : parseRupiahCurrency(inv["total_discount"].toString()), 
                                      style: const TextStyle(fontSize: 12, color: redColor)
                                    )
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text("Total", style: TextStyle(fontSize: 12)),
                                    ),
                                    Text(parseRupiahCurrency(inv["total"].toString()), style: const TextStyle(fontSize: 12))
                                  ],
                                ),
                                const SizedBox(height: 24),
                                ButtonOpacity(
                                  text: "Bayar Pesananan",
                                  onPress: handlerProcessPayment,
                                  backgroundColor: primaryColor,
                                  disabled: ctrlPaymentType.value.toString() == "null" || items.isEmpty,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ButtonOpacity(
                            text: "Batalkan",
                            onPress: handlerCancelOrder,
                            backgroundColor: redLightColor,
                            textColor: redColor,
                            disabled: items.isEmpty,
                          )
                        ],
                      ),
                    )
                  ),
                ),
              ]
            )
          ),
        );
      }, 
    );
  }
}