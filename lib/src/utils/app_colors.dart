import 'package:flutter/material.dart';

class AppColors {
  // Feminine soft
  static const Color feminine1 = Color(0xFFFFD0D0); // #FFD0D0
  static const Color feminine2 = Color(0xFFE1ACAC); // #E1ACAC
  static const Color feminine3 = Color(0xFFE5989B); // #E5989B
  static const Color feminine4 = Color(0xFFB5828C); // #B5828C

  // Brown / leather
  static const Color leather1 = Color(0xFF8D7B68); // #8D7B68
  static const Color leather2 = Color(0xFFA4907C); // #A4907C
  static const Color leather3 = Color(0xFFC8B6A6); // #C8B6A6
  static const Color leather4 = Color(0xFFF1DEC9); // #F1DEC9

  // Basics
  static const Color white = Color(0xFFFFFFFF); // #FFFFFF
  static const Color black = Color(0xFF000000); // #000000

  // Sports / accent
  static const Color sport1 = Color(0xFF4FC3F7); // #4FC3F7
  static const Color sport2 = Color(0xFF0288D1); // #0288D1

  // Rose gold (use feminine2 as rose-gold accent)
  static const Color roseGold = feminine2;

  // Usage defaults
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = feminine1;
  static const Color primary = black;
  static const Color accent = leather2;
}
