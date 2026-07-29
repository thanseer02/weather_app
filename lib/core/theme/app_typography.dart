import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme getTextTheme(BuildContext context) {
    return GoogleFonts.interTextTheme(Theme.of(context).textTheme);
  }
}
