import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/models/app_color.dart';
import '../core/models/app_font.dart';

export '../core/models/app_color.dart';
export '../core/models/app_font.dart';

class ThemeProvider extends ChangeNotifier {
  static const List<AppColor> availableColors = [
    AppColor('Ungu', Color(0xFF6750A4)),
    AppColor('Biru', Color(0xFF1565C0)),
    AppColor('Hijau', Color(0xFF2E7D32)),
    AppColor('Merah', Color(0xFFC62828)),
    AppColor('Oranye', Color(0xFFE65100)),
    AppColor('Pink', Color(0xFFAD1457)),
    AppColor('Teal', Color(0xFF00695C)),
    AppColor('Indigo', Color(0xFF283593)),
    AppColor('Kuning', Color(0xFFF9A825)),
    AppColor('Abu-abu', Color(0xFF546E7A)),
  ];

  static final List<AppFont> availableFonts = [
    AppFont('Poppins', GoogleFonts.poppinsTextTheme),
    AppFont('Roboto', GoogleFonts.robotoTextTheme),
    AppFont('Lato', GoogleFonts.latoTextTheme),
    AppFont('Nunito', GoogleFonts.nunitoTextTheme),
    AppFont('Inter', GoogleFonts.interTextTheme),
    AppFont('Montserrat', GoogleFonts.montserratTextTheme),
    AppFont('Raleway', GoogleFonts.ralewayTextTheme),
    AppFont('Josefin Sans', GoogleFonts.josefinSansTextTheme),
  ];

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = availableColors.first.color;
  AppFont _selectedFont = availableFonts.first;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  AppFont get selectedFont => _selectedFont;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggle() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void setColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }

  void setFont(AppFont font) {
    _selectedFont = font;
    notifyListeners();
  }
}
