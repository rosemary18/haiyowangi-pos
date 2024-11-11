import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:haiyowangi_pos/src/index.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';


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

  bool printMode = false;
  bool isScanning = false;
  SaleModel data = SaleModel();
  BluetoothInfo? _device;
  List<BluetoothInfo> bluetooths = [];

  @override
  void initState() {

    super.initState();
    data = widget.data;
    printMode = widget.printMode;
    initPlatformState();
  }

  Future<void> initPlatformState() async {

    String platformVersion;
    int percentbatery = 0;
    
    try {
      platformVersion = await PrintBluetoothThermal.platformVersion;
      percentbatery = await PrintBluetoothThermal.batteryLevel;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    debugPrint("Bluetooth enabled: $result | Platform Version: $platformVersion | % Battery: $percentbatery");
  }

  Future<bool> handlerConnect() async {

    bool isConnected = await PrintBluetoothThermal.connectionStatus;

    if (isConnected || _device == null) {
      await PrintBluetoothThermal.disconnect;
    }

    if (_device != null) {
      await PrintBluetoothThermal.connect(macPrinterAddress: _device!.macAdress);
      return true;
    }

    return isConnected;
  }

  Future<void> handlerScan() async {

    if (!isScanning) {
      setState(() {
        isScanning = true;
        bluetooths = [];
      });

      final List<BluetoothInfo> lists = await PrintBluetoothThermal.pairedBluetooths;

      setState(() {
        bluetooths = lists;
        isScanning = false;
      });
    } else {
      setState(() {
        isScanning = false;
      });
    }
  }

  void handlerPickPrinter(BluetoothInfo d) async {

    if (_device == d) {
      _device = null;
    } else {
      _device = d;
    }

    handlerConnect();
    setState(() {});
  }

  void handlerPrint() async {

    if (!printMode) {
      setState(() {
        printMode = true;
      });
    } else {

      final state = context.read<AuthBloc>().state;

      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      bytes += generator.setGlobalFont(PosFontType.fontA);
      bytes += generator.reset();

      // DRAW RECEIPT

      bytes += generator.feed(2);
      bytes += generator.text('Haiyo Wangi', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(state.store!.name ?? "", styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text(formatDateFromString(data.createdAt.toString(), format: "EEEE, dd/MM/yyyy hh:mm"), styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(1);
      bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));

      for (var item in data.items) {
        int index = data.items.indexOf(item);
        if (item.packetId != null) {
          bytes += generator.text('${index+1}. x${item.qty} @ ${parseRupiahCurrency(item.packet!.price.toString())} ', styles: const PosStyles(align: PosAlign.left));
          bytes += generator.text("   ${item.packet!.name ?? ""}", styles: const PosStyles(align: PosAlign.left));
          for (var p in item.packet!.items) {
            bytes += generator.text('   - x${p.qty} ${p.product != null ? p.product!.name : p.variant!.name}', styles: const PosStyles(align: PosAlign.left));
          }
        } else {
          bytes += generator.text('${index+1}. x${item.qty} @ ${parseRupiahCurrency(item.product != null ? item.product!.price.toString() : item.variant!.price.toString())} ', styles: const PosStyles(align: PosAlign.left));
          bytes += generator.text('   ${item.product != null ? item.product!.name : item.variant!.name}', styles: const PosStyles(align: PosAlign.left));
        }
      }

      bytes += generator.text('--------------------------------', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(1);

      bytes += generator.text('Subtotal  : ${parseRupiahCurrency(data.invoice!.subTotal.toString())}', styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Diskon    : ${parseRupiahCurrency(data.invoice!.discount.toString())}', styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Total     : ${parseRupiahCurrency(data.invoice!.total.toString())}', styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Cash      : ${parseRupiahCurrency(data.invoice!.cash.toString())}', styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Kembalian : ${parseRupiahCurrency(data.invoice!.changeMoney.toString())}', styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text("Kasir     : ${data.staff!.name}", styles: const PosStyles(align: PosAlign.left));
      
      bytes += generator.feed(2);
      bytes += generator.text('Terima kasih telah berbelanja di Haiyo Wangi', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(2);

      await PrintBluetoothThermal.writeBytes(bytes);
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
              TouchableOpacity(
                onPress: handlerScan,
                child: Icon(
                  (isScanning) ? Boxicons.bx_stop_circle : Boxicons.bx_refresh,
                  color: (isScanning) ? redColor : primaryColor,
                  size: 24
                )
              ),
        ]
      ) : null,
      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      content: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(minHeight: 80),
        width: printMode ? MediaQuery.of(context).size.width*.75 : null,
        child: printMode ? SingleChildScrollView(
            child: Column(
              children: bluetooths.map((d) => ListTile(
                title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(d.macAdress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: greyTextColor)),
                contentPadding: const EdgeInsets.only(right: 16),
                onTap: () => handlerPickPrinter(d),
                trailing: _device != null && _device!.macAdress == d.macAdress ? const Icon(
                  Icons.check,
                  color: Colors.green,
                ) : null,
              )).toList(),
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