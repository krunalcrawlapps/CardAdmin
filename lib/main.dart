import 'dart:async';

import 'package:card_app_admin/constant/app_constant.dart';
import 'package:card_app_admin/database/database_helper.dart';
import 'package:card_app_admin/provider/language_provider.dart';
import 'package:card_app_admin/screens/auth_screens/splash_screen.dart';
import 'package:card_app_admin/utils/in_app_translation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await DatabaseHelper.shared.initDatabase();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: StringConstant.app_name,
            theme: ThemeData(
              primarySwatch: Colors.orange,
            ),
            locale: Locale(languageProvider.locale),
            localizationsDelegates: [
              languageProvider.newLocaleDelegate,
              // Localization delegate...
              AppTranslationsDelegate(),
              // Provides localised strings
              GlobalMaterialLocalizations.delegate,
              // Provides RTL support
              GlobalWidgetsLocalizations.delegate,
            ],
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            supportedLocales: application.supportedLocales(),
            home: const SplashScreen(),
          ),
        ));
  }
}
