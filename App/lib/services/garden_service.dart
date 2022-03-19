// ignore_for_file: avoid_print

import 'package:event/event.dart';
import 'package:bytegarden/classes/device.dart';
import 'package:bytegarden/classes/garden_device.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GardenFactory {
  static GardenService? _gardenService;

  static GardenService? getGardenService() {
    if (_gardenService == null) {
      _gardenService = GardenService();
      return _gardenService;
    } else {
      return _gardenService;
    }
  }
}

class ChangedStateArgs extends EventArgs {
  bool state;

  ChangedStateArgs(this.state);
}

class GardenService {
  GardenDevice? device;
  bool isEnabled = false;
  bool isLoaded = false;
  final onStateChange = Event<ChangedStateArgs>();
  List<Device> _bondedCache = [];

  Future<void> load() async {
    if (!isLoaded) {
      isLoaded = true;
      isEnabled = (await FlutterBluetoothSerial.instance.isEnabled)!;
      if (isEnabled) {
        _bondedCache = await getDevices();
      }
      FlutterBluetoothSerial.instance
          .onStateChanged()
          .listen((state) => onStateChanged(state));
    }
  }

  void onStateChanged(BluetoothState state) {
    isEnabled = state.isEnabled;
    onStateChange.broadcast(ChangedStateArgs(state.isEnabled));
  }

  Future<bool> enable() async {
    var userConfirmation =
        await FlutterBluetoothSerial.instance.requestEnable();
    var isEnabled = false;

    if (userConfirmation != null) {
      isEnabled = userConfirmation;
      if (isEnabled) {
        _bondedCache = await getDevices();
      }
    }

    return isEnabled;
  }

  Future<bool> disable() async {
    var userConfirmation =
        await FlutterBluetoothSerial.instance.requestDisable();
    var isDisabled = false;

    if (userConfirmation != null) {
      isDisabled = userConfirmation;
    }

    return isDisabled;
  }

  Future<bool> connect(Device device) async {
    var result = false;
    try {
      var connection = await BluetoothConnection.toAddress(device.address);
      this.device = GardenDevice(device.name, device.address,
          connection.isConnected, device.isBonded, connection);
      result = true;
    } catch (e) {
      print('Error connecting to device - $e');
    }
    return result;
  }

  Future<bool> disconnect() async {
    var result = false;
    if (device != null && device!.isConnected) {
      try {
        await device!.connection.finish();
        result = true;
      } catch (e) {
        print('Error disconnecting to device - $e');
      }
    }
    return result;
  }

  List<Device> getCachedDevices() {
    return _bondedCache;
  }

  Future<List<Device>> getDevices() async {
    if (isEnabled) {
      return (await FlutterBluetoothSerial.instance.getBondedDevices())
          .map((e) => Device(e.name, e.address, e.isConnected, e.isBonded))
          .toList();
    }
    return [];
  }
}
