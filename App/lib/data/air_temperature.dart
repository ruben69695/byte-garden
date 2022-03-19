import 'package:hive/hive.dart';

part 'air_temperature.g.dart';

@HiveType(typeId: 1)
class AirTemperature {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double value;

  AirTemperature(this.date, this.value);
}
