// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'air_temperature.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AirTemperatureAdapter extends TypeAdapter<AirTemperature> {
  @override
  final int typeId = 1;

  @override
  AirTemperature read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AirTemperature(
      fields[0] as DateTime,
      fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AirTemperature obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AirTemperatureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
