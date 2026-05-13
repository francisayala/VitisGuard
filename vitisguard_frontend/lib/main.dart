import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'screens/dashboard_screen.dart'; // O como se llame tu pantalla principal

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que Flutter esté listo antes de cualquier operación

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; // Inicializa SQLite para escritorio
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ESTE ES EL CEREBRO DEL IDIOMA. Comienza en Español ('es')
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(
    const Locale('es'),
  );

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder "escucha" si el idioma cambia y redibuja TODA la app
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, child) {
        return MaterialApp(
          title: 'VitisGuard',
          debugShowCheckedModeBanner: false,

          // --- CONFIGURACIÓN DE IDIOMAS ---
          locale: currentLocale, // El idioma actual
          localizationsDelegates: const [
            AppLocalizations.delegate, // Tus diccionarios generados
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en'), Locale('ru')],

          // --------------------------------
          theme: ThemeData.dark(), // Tu tema oscuro base
          home: const DashboardScreen(),
        );
      },
    );
  }
}
