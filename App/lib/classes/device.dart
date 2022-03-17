class Device {
  String? name;
  String address;
  bool isConnected;
  bool isBonded;
  Device(this.name, this.address, this.isConnected, this.isBonded);
  String getName() => name == null ? address : name.toString();
}
