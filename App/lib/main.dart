import 'package:bytegarden/pages/home_page.dart';
import 'package:bytegarden/resources/colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
