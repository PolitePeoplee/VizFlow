import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? ThemeData.dark() : ThemeData.light();
}
