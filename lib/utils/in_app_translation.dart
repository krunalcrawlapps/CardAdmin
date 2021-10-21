import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class Application {
  static final Application _application = Application._internal();

  factory Application() {
    return _application;
  }

  Application._internal();

  //en = english, ar = arabic...
  final List<String> supportedLanguagesCodes = [
    "en",
    "ar",
  ];

  //returns the list of supported Locales
  Iterable<Locale> supportedLocales() =>
      supportedLanguagesCodes.map<Locale>((language) => Locale(language, ""));

  //function to be invoked when changing the language
  LocaleChangeCallback? onLocaleChanged;
}

//AppTranslations class for fetching your JSON files
class AppTranslations {
  static late Map<dynamic, dynamic> _localisedValues;

  Locale? locale;
  Locale? get getLocale => locale;

  static set setLocale(Locale locale) {
    locale = locale;
  }

  static AppTranslations? of(BuildContext context) {
    return Localizations.of<AppTranslations>(context, AppTranslations);
  }

  static Future<AppTranslations> load(Locale locale) async {
    AppTranslations appTranslations = AppTranslations();
    setLocale = locale;
    String jsonContent = await rootBundle
        .loadString("assets/locale/localization_${locale.languageCode}.json");
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  get currentLanguage => locale!.languageCode;

  String text(String key) {
    return _localisedValues[key] ?? "$key";
  }
}

//App Translation Delegate...
Application application = Application();

//Type alias for language change call back..
typedef void LocaleChangeCallback(String locale);

class AppTranslationsDelegate extends LocalizationsDelegate<AppTranslations> {
  final String newLocale;
  const AppTranslationsDelegate({this.newLocale = "en"});

  @override
  bool isSupported(Locale locale) {
    return application.supportedLanguagesCodes.contains(locale.languageCode);
  }

  @override
  Future<AppTranslations> load(Locale locale) {
    return AppTranslations.load(Locale(newLocale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppTranslations> old) {
    return true;
  }
}

class SuppotedLanguage {
  static const String english = "en";
  static const String arabic = "ar";
}
