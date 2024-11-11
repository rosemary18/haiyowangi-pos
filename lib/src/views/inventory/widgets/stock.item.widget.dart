
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';

class StockItem extends StatefulWidget {

  final bool isEdit;
  final dynamic data;
  final Function(dynamic)? onChange;
  final Function(dynamic)? onDelete;

  const StockItem({
    super.key, 
    this.isEdit = true,
    this.data,
    this.onChange,
    this.onDelete
  });

  @override
  State<StockItem> createState() => _StockItemState();
}

class _StockItemState extends State<StockItem> {
  
  final ctrlQty = TextEditingController();
  Directory? appDir;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      ctrlQty.text = widget.data["qty"].toString();
    }
    ctrlQty.addListener(() {
      if (widget.data["qty"].toString() != ctrlQty.text.toString()) {
        widget.data["qty"] = double.tryParse(ctrlQty.text);
        widget.onChange!(widget.data);
      }
    });
  }

  @override
  void didUpdateWidget(covariant StockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data["qty"].toString() != oldWidget.data["qty"].toString()) {
      ctrlQty.text = widget.data["qty"].toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
    ctrlQty.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: white1Color
                ),
                clipBehavior: Clip.hardEdge,
                child: ((widget.data["data"]?.img != null) && (getImagePath(appDir, widget.data["data"]?.img?.split("/images/")!.last).isNotEmpty)) ? Image.file(File(getImagePath(appDir, widget.data["data"]?.img?.split("/images/")?.last)), height: 40, fit: BoxFit.cover) : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.data["data"]?.name}", 
                      style: const TextStyle(color: blackColor, fontSize: 14, fontFamily: FontMedium), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    if (widget.data["data"].runtimeType != IngredientModel) Text(
                      parseRupiahCurrency("${widget.data["data"]?.price}"),
                      style: const TextStyle(color: greyTextColor, fontSize: 8), 
                    ),
                    if (widget.data["data"].runtimeType == IngredientModel) Text(
                      "${widget.data["data"]?.uom?.name}",
                      style: const TextStyle(color: greyTextColor, fontSize: 8), 
                    ),
                    if (!widget.isEdit) Text(
                      "${widget.data["qty"]} ${widget.data["data"]?.uom != null ? "${widget.data["data"]?.uom?.name}" : ""}",
                      style: const TextStyle(color: greyTextColor, fontSize: 8), 
                    ), 
                  ],
                ),
              ),
              if (widget.isEdit) TouchableOpacity(
                onPress: () => widget.onDelete!(widget.data),
                child: const Icon(
                  Boxicons.bxs_trash,
                  color: redColor,
                  size: 16,
                ) 
              )
            ],
          ),
          if (widget.isEdit) Input(
            controller: ctrlQty,
            multiplication: true,
            margin: const EdgeInsets.only(top: 8),
          )
        ],
      )
    );
  }
}