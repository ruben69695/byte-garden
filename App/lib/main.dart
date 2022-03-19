import 'package:bytegarden/data/air_humidity.dart';
import 'package:bytegarden/data/air_temperature.dart';
import 'package:bytegarden/data/ground_humidity.dart';
import 'package:bytegarden/pages/home_page.dart';
import 'package:bytegarden/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await initHive();
  runApp(const MyApp());
}

Future initHive() async {
  await Hive.initFlutter();
  registerHiveAdapters();
  await openHiveBoxes();
}

Future openHiveBoxes() async {
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox('air_humidity'),
    Hive.openBox('air_temperature'),
    Hive.openBox('ground_humidity')
  ]);
  // var box = await Hive.openBox('settings');
  // print(box.get('favorite_device'));
}

void registerHiveAdapters() {
  Hive.registerAdapter(AirHumidityAdapter());
  Hive.registerAdapter(AirTemperatureAdapter());
  Hive.registerAdapter(GroundHumidityAdapter());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Byte Garden',
      home: const MyHomePage(title: 'Byte Garden'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: customColor,
        scaffoldBackgroundColor: primaryColor,
        buttonTheme: const ButtonThemeData(
          buttonColor: buttonColor,
          textTheme: ButtonTextTheme.primary,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: buttonColor,
          foregroundColor: textPrimaryColor,
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: textPrimaryColor,
              displayColor: textPrimaryColor,
              fontFamily: 'ProximaNova',
            ),
      ),
    );
  }
}
