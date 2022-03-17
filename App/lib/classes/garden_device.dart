import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'device.dart';

class GardenDevice extends Device {
  BluetoothConnection connection;

  GardenDevice(String? name, String address, bool isConnected, bool isBonded,
      this.connection)
      : super(name, address, isConnected, isBonded);
}
