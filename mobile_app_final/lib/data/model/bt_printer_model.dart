import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

class BluetoothPrinter {
  String deviceName;
  String address;
  String port;
  String vendorId;
  String productId;
  bool isBle;

  PrinterType typePrinter;
  bool state;

  BluetoothPrinter({
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() => {
        'deviceName': deviceName,
        'address': address,
        'port': port,
        'vendorId': vendorId,
        'productId': productId,
        'isBle': isBle,
        'typePrinter': typePrinter.toString(),
        'state': state,
      };

  // Create object from JSON
  factory BluetoothPrinter.fromJson(Map<String, dynamic> json) =>
      BluetoothPrinter(
        deviceName: json['deviceName'],
        address: json['address'],
        port: json['port'],
        vendorId: json['vendorId'],
        productId: json['productId'],
        isBle: json['isBle'],
        typePrinter: PrinterType.values
            .firstWhere((e) => e.toString() == json['typePrinter']),
        state: json['state'],
      );
}
