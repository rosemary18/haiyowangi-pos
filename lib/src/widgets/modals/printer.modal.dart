import 'dart:async';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';

class ModalPrinter extends StatefulWidget {

  final SaleModel data;
  final bool printMode;
  
  const ModalPrinter({
    super.key,
    required this.data,
    this.printMode = false
  });

  @override
  State<ModalPrinter> createState() => _ModalPrinterState();
}

class _ModalPrinterState extends State<ModalPrinter> {

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool printMode = false;
  BluetoothDevice? _device;
  SaleModel data = SaleModel();

  @override
  void initState() {

    super.initState();
    data = widget.data;
    printMode = widget.printMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  Future<void> initBluetooth() async {

    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
  }

  Future<bool> handlerConnect() async {

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    if (isConnected) {
      await bluetoothPrint.disconnect();
    }

    if ((_device != null && _device!.address != null)) {
      await bluetoothPrint.connect(_device!);
      return true;
    }

    return isConnected;
  }

  void handlerPickPrinter(BluetoothDevice d) async {

    if (_device == d) {
      _device = null;
    } else {
      _device = d;
      handlerConnect();
    }

    setState(() {});
  }

  void handlerPrint() async {

    if (!printMode) {
      setState(() {
        printMode = true;
      });
    } else {

      final state = context.read<AuthBloc>().state;

      Map<String, dynamic> config = {};
      config['gap'] = 0;

      List<LineText> list = [];

      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Haiyo Wangi', weight: 1, align: LineText.ALIGN_CENTER, fontZoom: 4, linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: state.store!.name, weight: 1, align: LineText.ALIGN_CENTER, linefeed: 1));
      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: formatDateFromString(data.createdAt.toString(), format: "EEEE, dd/MM/yyyy hh:mm"), align: LineText.ALIGN_LEFT, linefeed: 1));
      
      list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', linefeed: 1));

      for (var item in data.items) {
        int index = data.items.indexOf(item);
        if (item.packetId != null) {
          list.add(LineText(type: LineText.TYPE_TEXT, content: '${index+1}. x${item.qty} @ ${parseRupiahCurrency(item.packet!.price.toString())} ', align: LineText.ALIGN_LEFT, linefeed: 1));
          list.add(LineText(type: LineText.TYPE_TEXT, content: item.packet!.name, align: LineText.ALIGN_LEFT, x: 34, linefeed: 1));
          for (var p in item.packet!.items) {
            list.add(LineText(type: LineText.TYPE_TEXT, content: '- x${p.qty} ${p.product != null ? p.product!.name : p.variant!.name}', align: LineText.ALIGN_LEFT, x: 34, linefeed: 1));
          }          
        } else {
          list.add(LineText(type: LineText.TYPE_TEXT, content: '${index+1}. x${item.qty} @ ${parseRupiahCurrency(item.product != null ? item.product!.price.toString() : item.variant!.price.toString())} ', align: LineText.ALIGN_LEFT, linefeed: 1));
          list.add(LineText(type: LineText.TYPE_TEXT, content: '${item.product != null ? item.product!.name : item.variant!.name}', align: LineText.ALIGN_LEFT, x: 34, linefeed: 1));
        }
      }

      list.add(LineText(type: LineText.TYPE_TEXT, content: '--------------------------------', linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Subtotal  : ${parseRupiahCurrency(data.invoice!.subTotal.toString())}', align: LineText.ALIGN_LEFT, linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Diskon    : ${parseRupiahCurrency(data.invoice!.discount.toString())}', align: LineText.ALIGN_LEFT, linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Total     : ${parseRupiahCurrency(data.invoice!.total.toString())}', align: LineText.ALIGN_LEFT, linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Cash      : ${parseRupiahCurrency(data.invoice!.cash.toString())}', align: LineText.ALIGN_LEFT, linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: 'Kembalian : ${parseRupiahCurrency(data.invoice!.changeMoney.toString())}', align: LineText.ALIGN_LEFT, linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: "Kasir: ${data.staff!.name}", align: LineText.ALIGN_LEFT, linefeed: 1));

      list.add(LineText(linefeed: 1));
      list.add(LineText(type: LineText.TYPE_TEXT, content: "Terima kasih telah berbelanja di Haiyo Wangi", align: LineText.ALIGN_CENTER, linefeed: 1));
      list.add(LineText(linefeed: 1));

      await bluetoothPrint.printReceipt(config, list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: printMode ? Row(
        children: [
          const Expanded(
            child: Text('Pilih printer', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))
          ),
          const SizedBox(width: 8),
          StreamBuilder<bool>(
            stream: bluetoothPrint.isScanning,
            initialData: false,
            builder: (c, snapshot) {
              if (snapshot.data == true) {
                return TouchableOpacity(
                  onPress: () => bluetoothPrint.stopScan(),
                  child: const Icon(
                    Boxicons.bx_stop_circle,
                    color: redColor,
                    size: 24
                  )
                );
              } else {
                return TouchableOpacity(
                  onPress: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
                  child: const Icon(
                    Boxicons.bx_refresh,
                    color: primaryColor,
                    size: 24
                  )
                );
              }
            },
          ),
        ]
      ) : null,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      content: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: printMode ? MediaQuery.of(context).size.width*.75 : null,
        child: printMode ? RefreshIndicator(
          onRefresh: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!.map((d) => ListTile(
                      title: Text(d.name??'', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(d.address??'', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: greyTextColor)),
                      contentPadding: const EdgeInsets.only(right: 16),
                      onTap: () => handlerPickPrinter(d),
                      trailing: _device != null && _device!.address == d.address ? const Icon(
                        Icons.check,
                        color: Colors.green,
                      ) : null,
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ) : const Padding(
          padding: EdgeInsets.only(top: 48, bottom: 24, left: 24, right: 24),
          child: Center(
            child: Text("Penjualan baru telah disimpan!\n🫡", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      scrollable: true,
      shadowColor: primaryColor.withOpacity(0.2),
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? MediaQuery.of(context).size.width/4 : 16),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      actionsAlignment: printMode ? MainAxisAlignment.end : MainAxisAlignment.center,
      actions: [
        TouchableOpacity(
          onPress: () async {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              border: Border.all(color: greyLightColor),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: const Text(
              'Selesai', 
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold
              )
            ),
          ), 
        ),
        TouchableOpacity(
          onPress: ((_device == null) && printMode) ? null : handlerPrint,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              border: Border.all(color: ((_device == null) && printMode) ? greyLightColor : primaryColor),
              color: ((_device == null) && printMode) ? greyLightColor : primaryColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: const Text(
              'Cetak', 
              style: TextStyle(
                color: Colors.white, 
                fontSize: 14,
                fontWeight: FontWeight.bold
              )
            ),
          ), 
        ),
      ],
    );
  }
}