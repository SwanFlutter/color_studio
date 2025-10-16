// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';

class LanguageController extends GetXController {
  static const String _languageKey = 'language_code';
  final GetXStorage _storage = GetXStorage();

  final RxString currentLanguage = 'en_US'.obs;
  @override
  void onInit() {
    super.onInit();
    // مقدار اولیه زبان را از حافظه بخوان، بدون تغییر locale
    final savedLanguage = _storage.read(key: _languageKey);
    if (savedLanguage is String) {
      currentLanguage.value = savedLanguage;
    }
  }
  void changeLanguage(String localeCode) {
    currentLanguage.value = localeCode;

    Locale locale;
    if (localeCode == 'fa_IR') {
      locale = const Locale('fa', 'IR');
    } else {
      locale = const Locale('en', 'US');
    }

    Get.updateLocale(locale);
    _storage.write(key: _languageKey, value: localeCode);

    bool isRtl = localeCode == 'fa_IR';
    saveTextDirection(textDirection: isRtl);

    update();
  }

  void defaultLanguage() {
    // نسخه سبک: فقط مقدار داخلی را ست می‌کند
    var savedLanguage = _storage.read(key: _languageKey);
    currentLanguage.value = savedLanguage is String ? savedLanguage : 'en_US';
  }

  void saveTextDirection({required bool textDirection}) async {
    debugPrint("Saving text direction as: $textDirection");
    await _storage.write(key: 'textDirection', value: textDirection);
    update();
  }

  void saveFont({required String font}) async {
    await _storage.write(key: 'font', value: font);
    update();
  }

  TextDirection getStoredDirection() {
    var direction = _storage.read(key: 'textDirection');
    bool isTextDirectionRtl = direction is bool
        ? direction
        : false; // Default to LTR

    return isTextDirectionRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  String getStoredFont() {
    var font = _storage.read(key: 'font');
    return font is String ? font : 'Michroma'; // Default to Michroma
  }

  void clearStoredSettings() {
    _storage.remove(key: 'textDirection');
    _storage.remove(key: 'font');
    _storage.remove(key: _languageKey);
    debugPrint("Cleared stored settings");
  }
}
