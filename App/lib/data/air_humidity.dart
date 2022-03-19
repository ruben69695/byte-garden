import 'package:hive/hive.dart';

part 'air_humidity.g.dart';

@HiveType(typeId: 2)
class AirHumidity {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double value;

  AirHumidity(this.date, this.value);
}
