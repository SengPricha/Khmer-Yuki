import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('km'); 

  Locale get locale => _locale;

  void toggleLanguage() {
    if (_locale.languageCode == 'km') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('km');
    }
    notifyListeners();
  }
}