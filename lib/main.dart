import 'package:color_studio/bindings/app_bindings.dart';
import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';
import 'package:window_manager/window_manager.dart';

import 'I18n/translations.dart';
import 'screen/color_picker_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetXStorage.init();
  await windowManager.ensureInitialized();

  // Read saved theme and language BEFORE building the app to avoid flicker
  final storage = GetXStorage();
  final savedTheme = storage.read(key: 'theme') as String?;
  final savedLang = storage.read(key: 'language_code') as String?;

  final ThemeMode initialThemeMode = switch (savedTheme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.system,
  };

  final Locale initialLocale = switch (savedLang) {
    'fa_IR' => const Locale('fa', 'IR'),
    'en_US' => const Locale('en', 'US'),
    _ => const Locale('en', 'US'),
  };

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 900),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ColorStudioApp(
      initialThemeMode: initialThemeMode,
      initialLocale: initialLocale,
    ),
  );
}

class ColorStudioApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  final Locale initialLocale;
  const ColorStudioApp({
    super.key,
    required this.initialThemeMode,
    required this.initialLocale,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Color Studio - Flutter',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      themeMode: initialThemeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ColorPickerHome(),
    );
  }
}
