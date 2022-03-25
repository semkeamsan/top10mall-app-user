import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class App {
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width / 100;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height / 100;
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

Widget caNoResults(
    BuildContext context, String title, Color color, double fontSize) {
  return Container(
    padding: EdgeInsets.all(20),
    child: Center(
      child: Text(
        title,
        style: TextStyle(color: color, fontSize: fontSize, fontFamily: ""),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
