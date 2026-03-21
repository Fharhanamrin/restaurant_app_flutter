import 'package:flutter/material.dart';

class AppFont {
  final String label;
  final TextTheme Function([TextTheme?]) textTheme;

  const AppFont(this.label, this.textTheme);
}
