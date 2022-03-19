import 'package:hive/hive.dart';

part 'ground_humidity.g.dart';

@HiveType(typeId: 3)
class GroundHumidity {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double value;

  GroundHumidity(this.date, this.value);
}
