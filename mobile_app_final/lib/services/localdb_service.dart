import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:six_pos/data/model/bt_printer_model.dart';

class SharedPreferencesService {
  final _instance = SharedPreferences.getInstance();

  // Store a BluetoothPrinter object in shared preferences
  Future<void> storeBluetoothPrinter(
      String key, BluetoothPrinter printer) async {
    // Convert the BluetoothPrinter object to a JSON string
    String printerJson = jsonEncode(printer.toJson());

    // Store the JSON string in shared preferences
    await _instance.then((value) => value.setString(key, printerJson));
  }

  // Retrieve a BluetoothPrinter object from shared preferences
  Future<BluetoothPrinter> retrieveBluetoothPrinter(String key) async {
    // Read the stored JSON string from shared preferences
    String printerJson;
    await _instance.then((value) {
      printerJson = value.getString(key);
    });

    // If the stored JSON string is null, return null
    if (printerJson == null) {
      return null;
    }

    // Convert the JSON string to a Map
    Map<String, dynamic> printerMap = jsonDecode(printerJson);

    // Create a BluetoothPrinter object from the Map
    BluetoothPrinter printer = BluetoothPrinter.fromJson(printerMap);

    return printer;
  }
}
