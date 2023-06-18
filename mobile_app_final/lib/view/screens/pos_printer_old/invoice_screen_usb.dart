import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';

import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:six_pos/controller/order_controller.dart';
import 'package:six_pos/controller/splash_controller.dart';

import '../order/widget/invoice_element_view.dart';

class InVoiceScreen extends StatefulWidget {
  final int orderId;
  const InVoiceScreen({Key key, this.orderId}) : super(key: key);

  @override
  State<InVoiceScreen> createState() => _InVoiceScreenState();
}

class _InVoiceScreenState extends State<InVoiceScreen> {
  List<Map<String, dynamic>> devices = [];
  FlutterUsbPrinter flutterUsbPrinter = FlutterUsbPrinter();
  bool connected = false;

  @override
  initState() {
    super.initState();
    _getDevicelist();
  }

  _getDevicelist() async {
    List<Map<String, dynamic>> results = [];
    results = await FlutterUsbPrinter.getUSBDeviceList();

    print(" length: ${results.length}");
    setState(() {
      devices = results;
    });
  }

  _connect(int vendorId, int productId) async {
    bool returned = false;
    try {
      returned = await flutterUsbPrinter.connect(vendorId, productId);
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
    if (returned != null) {
      setState(() {
        connected = true;
      });
    }
  }

  _print() async {
    try {
      var data = Uint8List.fromList(
          utf8.encode(" Hello world Testing ESC POS printer..."));
      await flutterUsbPrinter.write(data);
      // await FlutterUsbPrinter.printRawData("text");
      // await FlutterUsbPrinter.printText("Testing ESC POS printer...");
      var a;
      final invoiceController = Get.find<OrderController>();
      final shopController = Get.find<SplashController>();
      final PdfPageFormat pdfPageFormat = PdfPageFormat.roll57;

      _getbyte(List<String> N, List<double> C) async {}

      Navigator.pop(context);

      List<String> name = [];
      List<double> cost = [];
      final regexN = RegExp(r'selling_price":(\d+)');
      for (int i = 0; i < invoiceController.invoice.details.length; i++) {
        final inputString =
            invoiceController.invoice.details[i].productDetails.toString();
        print("-------------------------||=>");
        print(invoiceController.invoice.details[i].productDetails);
        final regex = RegExp(r'"selling_price":"(\d+)"');
        final regexN = RegExp(r'"name":"([^"]+)"');
        final matchN = regexN.firstMatch(inputString);
        final match = regex.firstMatch(inputString);
        var price = double.parse(match.group(1));
        cost.add(price);
        final product = matchN.group(1);
        name.add(product);
      }

      _getbyte(name, cost);
    } on PlatformException {
      //response = 'Failed to get platform version.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('USB PRINTER'),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.refresh),
                onPressed: () => _getDevicelist()),
            connected == true
                ? new IconButton(
                    icon: new Icon(Icons.print),
                    onPressed: () {
                      _print();
                    })
                : new Container(),
          ],
        ),
        body: devices.length > 0
            ? new ListView(
                scrollDirection: Axis.vertical,
                children: _buildList(devices),
              )
            : null,
      ),
    );
  }

  List<Widget> _buildList(List<Map<String, dynamic>> devices) {
    return devices
        .map((device) => new ListTile(
              onTap: () {
                _connect(int.parse(device['vendorId']),
                    int.parse(device['productId']));
              },
              leading: new Icon(Icons.usb),
              title: new Text(
                  device['manufacturer'] + " " + device['productName']),
              subtitle:
                  new Text(device['vendorId'] + " " + device['productId']),
            ))
        .toList();
  }
}
