import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';

import '../../cores/themes/styles/index.dart';
import '../buttons/button_opacity.dart';

class InputMultiplication extends StatefulWidget {
  
  final EdgeInsets margin;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final Function(String)? onChanged;
  final double width;
  final double? maxNumber;
  final double? minNumber;

  const InputMultiplication({
    super.key,
    this.margin = const EdgeInsets.only(bottom: 0),
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.width = 80,
    this.maxNumber,
    this.minNumber = 0
  });

  @override
  State<InputMultiplication> createState() => _InputMultiplicationState();
}

class _InputMultiplicationState extends State<InputMultiplication> {

  @override
  void initState() {
    super.initState();
    widget.controller?.text = (widget.controller!.text.isEmpty ? "${widget.minNumber ?? 0}" : widget.controller?.text)!;
  }

  void handlerMultiplication({bool plus = true}) async {

    String text = widget.controller!.text;
    if (text.isEmpty) {
      debugPrint('text is empty');
      widget.controller?.value = TextEditingValue(
        text: "${widget.minNumber ?? 0}",
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      double parsed = double.parse(text);
      double additional = ((parsed > 0 && parsed < 1) ? 0.1 : 1.0);
      double value = plus ? min(parsed + additional, widget.maxNumber ?? parsed + additional) : max(parsed - additional, widget.minNumber ?? parsed - additional);
      widget.controller?.text = value.toString();
    }

    setState(() {});
    widget.onChanged?.call(widget.controller!.text);
  }

  @override
  void didUpdateWidget(covariant InputMultiplication oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: widget.margin,
      width: widget.width,
      clipBehavior: Clip.none,
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          TouchableOpacity(
            onPress: () => handlerMultiplication(plus: false),
            disabled: (widget.minNumber != null && widget.minNumber == double.tryParse(widget.controller!.text)),
            child:  Icon(
              Boxicons.bx_minus_circle,
              color: (widget.minNumber != null && widget.minNumber == double.tryParse(widget.controller!.text)) ? greySoftColor : redColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 30,
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                cursorColor: const Color.fromARGB(255, 55, 98, 218),
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.transparent,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  counterStyle: TextStyle(fontSize: 0, height: 0),
                ),
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                expands: true,
                maxLines: null,
                minLines: null,
                style: const TextStyle(color: Color.fromARGB(255, 47, 47, 47), fontSize: 14)
              ),
            )
          ),
          const SizedBox(width: 8),
          TouchableOpacity(
            onPress: handlerMultiplication,
            disabled: (widget.maxNumber != null && widget.maxNumber == double.tryParse(widget.controller!.text)),
            child: Icon(
              Boxicons.bx_plus_circle,
              color: (widget.maxNumber != null && widget.maxNumber == double.tryParse(widget.controller!.text)) ? greySoftColor : primaryColor,
              size: 18,
            ),
          ),
        ],
      )
    );
  }
}
