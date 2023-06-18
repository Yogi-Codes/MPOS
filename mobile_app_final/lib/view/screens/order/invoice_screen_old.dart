import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:six_pos/util/images.dart';

import 'package:flutter/services.dart';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as im;

import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:six_pos/data/model/response/config_model.dart';
import 'package:six_pos/data/model/response/invoice_model.dart';

import 'package:six_pos/view/base/custom_app_bar.dart';
import 'package:six_pos/view/base/custom_drawer.dart';

import '../../../services/localdb_service.dart';
import 'package:six_pos/data/model/bt_printer_model.dart';

class InVoicePrintScreen extends StatefulWidget {
  final Invoice invoice;
  final ConfigModel configModel;
  final int orderId;
  final double discountProduct;
  final double total;
  final Uint8List printable_im;
  const InVoicePrintScreen(
      {Key key,
      this.invoice,
      this.configModel,
      this.orderId,
      this.discountProduct,
      this.total,
      this.printable_im})
      : super(key: key);

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {
  var defaultPrinterType = PrinterType.bluetooth;
  String _selectedPrinterType = 'USB';
  var _isBle = false;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice> _subscription;
  StreamSubscription<BTStatus> _subscriptionBtStatus;
  BTStatus _currentStatus = BTStatus.none;
  List<int> pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  BluetoothPrinter selectedPrinter;

  haha() async {
    await Future.delayed(Duration(seconds: 2));
    await Permission.bluetooth.request();
  }

  @override
  void initState() {
    haha();

    if (Platform.isAndroid) defaultPrinterType = PrinterType.usb;
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;

      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask);
          pendingTask = null;
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    devices.clear();
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      setState(() {});
    });
  }

  void setPort(String value) {
    if (value.isEmpty) value = '9100';
    _port = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void setIpAddress(String value) {
    _ipAddress = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void selectDevice(BluetoothPrinter device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter.address) ||
          (device.typePrinter == PrinterType.usb &&
              selectedPrinter.vendorId != device.vendorId)) {
        await PrinterManager.instance
            .disconnect(type: selectedPrinter.typePrinter);
      }
    }

    selectedPrinter = device;

    SharedPreferencesService ls = SharedPreferencesService();
    ls.storeBluetoothPrinter("anik", device);
  }

  Future _printReceiveTest() async {
    print("Printed");

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bytes += await generator.drawer(pin: PosDrawer.pin2);
    bytes += await generator.drawer(pin: PosDrawer.pin5);

    final ByteData logo = await rootBundle.load('assets/image/logo.png');
    final Uint8List log = logo.buffer.asUint8List();
    final im.Image img = im.decodeImage(log);

// Resize the image to fit within 58mm roll width
    final int targetWidth =
        192; // 58mm roll width in pixels (assuming 203dpi printer resolution)
    final int targetHeight = (targetWidth * img.height) ~/ img.width;
    final im.Image resizedImg =
        im.copyResize(img, width: targetWidth, height: targetHeight);

// Convert the resized image back to bytes
    final Uint8List resizedBytes = im.encodePng(resizedImg);

// Create an im.Image object from resized bytes
    final im.Image resizedImage = im.decodeImage(resizedBytes);

// Add the resized image to the bytes variable
    bytes += generator.image(resizedImage);

    im.Image imagi = im.decodeImage(widget.printable_im);
    int newHeight = (350 * imagi.height ~/ imagi.width);
    im.Image resizeImage = im.copyResize(imagi, width: 350, height: newHeight);

    bytes += generator.image(resizeImage);
//

//
//     bytes += generator.text('${widget.configModel.businessInfo.shopName}',
//         styles: const PosStyles(align: PosAlign.center, bold: true));
//
//     bytes += generator.text('${widget.configModel.businessInfo.shopAddress}',
//         styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('${widget.configModel.businessInfo.shopPhone}',
//         styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('${widget.configModel.businessInfo.shopEmail}',
//         styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('${widget.configModel.businessInfo.vat}',
//         styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('................................',
//         styles: const PosStyles(align: PosAlign.center));
//     bytes +=
//         generator.text(' ', styles: const PosStyles(align: PosAlign.center));
//
//     // Uint8List encThai =
//     //     await CharsetConverter.encode('TIS620', 'แกงจืดเต้าหู้หมูสับ แกงป่า');
//     final ByteData data = await rootBundle.load('assets/image/invoice_r.png');
//     final Uint8List kk = data.buffer.asUint8List();
//     final im.Image image = im.decodeImage(kk);
//     // generator.imageRaster(image, imageFn: PosImageFn.graphics);
//     // String textToPrint = "แกงจืดเต้าหู้หมูสับ แกงป่า";
//     bytes += generator.image(image, align: PosAlign.center);
//     bytes += generator.text('${widget.orderId}',
//         styles: PosStyles(align: PosAlign.center));
//     // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);
//     final ByteData data1 =
//         await rootBundle.load('assets/image/payment_method_r.png');
//     final Uint8List kk1 = data1.buffer.asUint8List();
//     final im.Image image1 = im.decodeImage(kk1);
//     bytes += generator.image(image1, align: PosAlign.center);
//
//     bytes += generator.text('${widget.invoice.account.account}',
//         styles: PosStyles(align: PosAlign.center));
//     bytes += generator.text('................................',
//         styles: const PosStyles(align: PosAlign.center));
//     final ByteData data2 = await rootBundle.load('assets/image/header1.png');
//     final Uint8List kk2 = data2.buffer.asUint8List();
//     final im.Image image2 = im.decodeImage(kk2);
//     bytes += generator.image(image2, align: PosAlign.center);
//     // bytes += generator.imageRaster(image2, imageFn: PosImageFn.bitImageRaster);
//
//     // bytes += generator.row([
//     //   PosColumn(
//     //     // text: '${'invoice'}#${widget.orderId}',
//     //
//     //     // textEncoded: encThai,
//     //     width: 6,
//     //     styles: PosStyles(
//     //         align: PosAlign.left, underline: true, fontType: PosFontType.fontB),
//     //   ),
//     //   PosColumn(
//     //     text: 'payment_method'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right, underline: true),
//     //   ),
//     // ]);
//
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'Today',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: 'Cash',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: '${'sl'.tr.toUpperCase()}',
//     //     width: 2,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: 'product_info'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: 'qty'.tr,
//     //     width: 1,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     //   PosColumn(
//     //     text: 'price'.tr,
//     //     width: 3,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//
//     bytes += generator.text('................................',
//         styles: const PosStyles(align: PosAlign.center));
//
//     for (int i = 0; i < widget.invoice.details.length; i++) {
//       bytes += generator.row([
//         PosColumn(
//           text: '${i + 1}',
//           width: 1,
//           styles: PosStyles(align: PosAlign.left),
//         ),
//         PosColumn(
//           text:
//               '${jsonDecode(widget.invoice.details[i].productDetails)['name']}',
//           width: 7,
//           styles: PosStyles(align: PosAlign.left),
//         ),
//         PosColumn(
//           text: '${widget.invoice.details[i].quantity.toString()}',
//           width: 1,
//           styles: PosStyles(align: PosAlign.right),
//         ),
//         PosColumn(
//           text: '${widget.invoice.details[i].price}',
//           width: 3,
//           styles: PosStyles(align: PosAlign.right),
//         ),
//       ]);
//     }
//
//     bytes += generator.text('................................',
//         styles: const PosStyles(align: PosAlign.center));
//
//     ByteData data4 = await rootBundle.load('assets/image/subtotal.png');
//     Uint8List kk4 = data4.buffer.asUint8List();
//     im.Image image4 = im.decodeImage(kk4);
//     bytes += generator.image(
//       image4,
//       align: PosAlign.left,
//     );
//
//     bytes += generator.text('${widget.invoice.orderAmount}',
//         styles: const PosStyles(align: PosAlign.left));
//     data4 = await rootBundle.load('assets/image/product_discount.png');
//     kk4 = data4.buffer.asUint8List();
//     image4 = im.decodeImage(kk4);
//     bytes += generator.image(
//       image4,
//       align: PosAlign.right,
//     );
//
//     bytes += generator.text('${widget.discountProduct}',
//         styles: const PosStyles(align: PosAlign.right));
//     data4 = await rootBundle.load('assets/image/coupon_discount.png');
//     kk4 = data4.buffer.asUint8List();
//     image4 = im.decodeImage(kk4);
//     bytes += generator.image(
//       image4,
//       align: PosAlign.left,
//     );
//
//     bytes += generator.text('${widget.invoice.couponDiscountAmount}',
//         styles: const PosStyles(align: PosAlign.left));
//
//     data4 = await rootBundle.load('assets/image/extra_discount.png');
//     kk4 = data4.buffer.asUint8List();
//     image4 = im.decodeImage(kk4);
//     bytes += generator.image(
//       image4,
//       align: PosAlign.right,
//     );
//
//     bytes += generator.text('${widget.invoice.extraDiscount}',
//         styles: const PosStyles(align: PosAlign.right));
//
//     data4 = await rootBundle.load('assets/image/tax.png');
//     kk4 = data4.buffer.asUint8List();
//     image4 = im.decodeImage(kk4);
//     bytes += generator.image(
//       image4,
//       align: PosAlign.left,
//     );
//
//     bytes += generator.text('${widget.invoice.totalTax}',
//         styles: const PosStyles(align: PosAlign.left));
//
//     data4 = await rootBundle.load('assets/image/total.png');
//     kk4 = data4.buffer.asUint8List();
//     image4 = im.decodeImage(kk4);
//     bytes += generator.image(
//       image4,
//       align: PosAlign.right,
//     );
//
//     bytes += generator.text('${widget.total - widget.discountProduct}',
//         styles: const PosStyles(align: PosAlign.right));
//
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'subtotal'.tr,
//     //     width: 6,
//     //     styles: PosStyles(
//     //       align: PosAlign.left,
//     //     ),
//     //   ),
//     //   PosColumn(
//     //     text: '${widget.invoice.orderAmount}',
//     //     width: 6,
//     //     styles: PosStyles(
//     //       align: PosAlign.right,
//     //     ),
//     //   ),
//     // ]);
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'product_discount'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: '${widget.discountProduct}',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//     //
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'coupon_discount'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: '${widget.invoice.couponDiscountAmount}',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'extra_discount'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: '${widget.invoice.extraDiscount}',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'tax'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: '${widget.invoice.totalTax}',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//     //
//     // bytes += generator.text('................................',
//     //     styles: const PosStyles(align: PosAlign.center));
//     //
//     // bytes += generator.row([
//     //   PosColumn(
//     //     text: 'total'.tr,
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.left),
//     //   ),
//     //   PosColumn(
//     //     text: '${widget.total - widget.discountProduct}',
//     //     width: 6,
//     //     styles: PosStyles(align: PosAlign.right),
//     //   ),
//     // ]);
//
//     bytes +=
//         generator.text(' ', styles: const PosStyles(align: PosAlign.center));
//     bytes += generator.text('................................',
//         styles: const PosStyles(align: PosAlign.center));
//     final ByteData data3 = await rootBundle.load('assets/image/terms.png');
//     final Uint8List kk3 = data3.buffer.asUint8List();
//     final im.Image image3 = im.decodeImage(kk3);
//     bytes += generator.image(image3, align: PosAlign.left);
//
//     // bytes += generator.text('terms_and_condition'.tr,
//     //     styles: const PosStyles(align: PosAlign.center));
//     // bytes += generator.text(
//     //   ' ',
//     // );
//     // bytes += generator.text('terms_and_condition_details'.tr,
//     //     styles: const PosStyles(align: PosAlign.center));
//     // bytes += generator.text(
//     //   ' ',
//     // );
//     // bytes += generator.text(
//     //     '${'powered_by'.tr} : ${widget.configModel.businessInfo.shopName}',
//     //     styles: const PosStyles(align: PosAlign.center));
//     // bytes += generator.text(
//     //     '${'shop_online'.tr} : ${widget.configModel.businessInfo.shopName}',
//     //     styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(
      ' ',
    );

    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
                name: bluetoothPrinter.deviceName,
                productId: bluetoothPrinter.productId,
                vendorId: bluetoothPrinter.vendorId));
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address,
                isBle: bluetoothPrinter.isBle ?? false));
        pendingTask = null;
        if (Platform.isIOS || Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address));
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Center(
        child: Container(
          height: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _selectedPrinterType,
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedPrinterType = newValue;
                      switch (_selectedPrinterType) {
                        case 'USB':
                          defaultPrinterType = PrinterType.usb;

                          break;
                        case 'Bluetooth':
                          defaultPrinterType = PrinterType.bluetooth;
                          break;
                        case 'Network':
                          defaultPrinterType = PrinterType.network;
                          break;
                        default:
                          defaultPrinterType = PrinterType.usb;
                      }
                      _scan();
                    });
                  },
                  items: <String>['USB', 'Bluetooth', 'Network']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.copyWith(
                                subtitle1: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                        ),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),

                ElevatedButton(
                    onPressed: () => {_printReceiveTest()},
                    child: Text("Print Default/USB".tr)),
                Column(
                    children: devices
                        .map(
                          (device) => ListTile(
                            title: Text('${device.deviceName}'),
                            subtitle: Platform.isAndroid &&
                                    defaultPrinterType == PrinterType.usb
                                ? null
                                : Visibility(
                                    visible: true
                                    // !Platform.isWindows
                                    ,
                                    child: Text("${device.address}")),
                            onTap: () {
                              selectDevice(device);
                              setState(() {});
                            },
                            leading: selectedPrinter != null &&
                                    ((device.typePrinter == PrinterType.usb

                                            // &&
                                            //         Platform.isWindows
                                            ? device.deviceName ==
                                                selectedPrinter.deviceName
                                            : device.vendorId != null &&
                                                selectedPrinter.vendorId ==
                                                    device.vendorId) ||
                                        (device.address != null &&
                                            selectedPrinter.address ==
                                                device.address))
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : null,
                            trailing: OutlinedButton(
                              onPressed: selectedPrinter == null ||
                                      device.deviceName !=
                                          selectedPrinter?.deviceName
                                  ? null
                                  : () async {
                                      _printReceiveTest();
                                    },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 20),
                                child: Text("print_invoice".tr,
                                    textAlign: TextAlign.center),
                              ),
                            ),
                          ),
                        )
                        .toList()),
                Visibility(
                  visible: true
                  // defaultPrinterType == PrinterType.network
                  //     &&
                  //     Platform.isWindows
                  ,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _ipController,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      decoration: const InputDecoration(
                        label: Text("Ip Address"),
                        prefixIcon: Icon(Icons.wifi, size: 24),
                      ),
                      onChanged: setIpAddress,
                    ),
                  ),
                ),
                Visibility(
                  visible: true
                  // defaultPrinterType == PrinterType.network &&
                  //     Platform.isWindows
                  ,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      controller: _portController,
                      keyboardType:
                          const TextInputType.numberWithOptions(signed: true),
                      decoration: const InputDecoration(
                        label: Text("Port"),
                        prefixIcon: Icon(Icons.numbers_outlined, size: 24),
                      ),
                      onChanged: setPort,
                    ),
                  ),
                ),
                Visibility(
                  visible: true
                  // defaultPrinterType == PrinterType.network &&
                  //     Platform.isWindows
                  ,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: OutlinedButton(
                      onPressed: () async {
                        if (_ipController.text.isNotEmpty)
                          setIpAddress(_ipController.text);
                        _printReceiveTest();
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                        child: Text("print_invoice".tr,
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ) //Lan Printer
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//
// class BluetoothPrinter {
//   int id;
//   String deviceName;
//   String address;
//   String port;
//   String vendorId;
//   String productId;
//   bool isBle;
//
//   PrinterType typePrinter;
//   bool state;
//
//   BluetoothPrinter(
//       {this.deviceName,
//       this.address,
//       this.port,
//       this.state,
//       this.vendorId,
//       this.productId,
//       this.typePrinter = PrinterType.bluetooth,
//       this.isBle = false});
// }
