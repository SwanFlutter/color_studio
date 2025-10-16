import 'package:color_studio/controller/language_cotroller.dart';
import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';

class LangugeBottomSheet extends StatelessWidget {
  const LangugeBottomSheet({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() => ListTile(
            leading: const Icon(Icons.language),
            title: const Text('English'),
            trailing: languageController.currentLanguage.value == 'en_US'
                ? Icon(Icons.check, color: colorScheme.primary)
                : null,
            onTap: () {
              languageController.changeLanguage('en_US');
              Get.back();
            },
          )),
          const Divider(),
          Obx(() => ListTile(
            leading: const Icon(Icons.language),
            title: const Text('فارسی'),
            trailing: languageController.currentLanguage.value == 'fa_IR'
                ? Icon(Icons.check, color: colorScheme.primary)
                : null,
            onTap: () {
              languageController.changeLanguage('fa_IR');
              Get.back();
            },
          )),
        ],
      ),
    );
  }
}
