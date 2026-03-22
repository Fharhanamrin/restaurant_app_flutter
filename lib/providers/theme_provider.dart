import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/app_color.dart';
import '../core/models/app_font.dart';

export '../core/models/app_color.dart';
export '../core/models/app_font.dart';

class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'is_dark_mode';
  static const String _colorKey = 'seed_color_index';
  static const String _fontKey = 'font_index';

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

  late ThemeMode _themeMode;
  late Color _seedColor;
  late AppFont _selectedFont;

  ThemeProvider(this._prefs) {
    final isDark = _prefs.getBool(_themeKey);
    if (isDark == null) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }

    final colorIndex = _prefs.getInt(_colorKey) ?? 0;
    _seedColor =
        availableColors[colorIndex.clamp(0, availableColors.length - 1)].color;

    final fontIndex = _prefs.getInt(_fontKey) ?? 0;
    _selectedFont =
        availableFonts[fontIndex.clamp(0, availableFonts.length - 1)];
  }

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  AppFont get selectedFont => _selectedFont;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> toggle() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await _prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setColor(Color color) async {
    _seedColor = color;
    final index = availableColors.indexWhere((c) => c.color == color);
    if (index != -1) await _prefs.setInt(_colorKey, index);
    notifyListeners();
  }

  Future<void> setFont(AppFont font) async {
    _selectedFont = font;
    final index = availableFonts.indexOf(font);
    if (index != -1) await _prefs.setInt(_fontKey, index);
    notifyListeners();
  }
}
