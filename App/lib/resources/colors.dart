import 'package:flutter/material.dart';

const Color primaryColor = Color.fromRGBO(26, 34, 45, 1.0);
const Color secondaryColor = Color.fromRGBO(41, 50, 64, 1.0);
const Color textPrimaryColor = Colors.white;
const Color buttonColor = Color.fromRGBO(73, 139, 223, 1.0);

const Map<int, Color> colors = {
  50: primaryColor,
  100: primaryColor,
  200: primaryColor,
  300: primaryColor,
  400: primaryColor,
  500: primaryColor,
  600: primaryColor,
  700: primaryColor,
  800: primaryColor,
  900: primaryColor,
};

MaterialColor customColor = MaterialColor(primaryColor.value, colors);
