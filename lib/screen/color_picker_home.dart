// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:color_studio/widget/languge_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:window_manager/window_manager.dart';

import '../controller/theme_controller.dart';
import '../native_color_picker.dart';

class ColorPickerHome extends StatefulWidget {
  const ColorPickerHome({super.key});

  @override
  State<ColorPickerHome> createState() => _ColorPickerHomeState();
}

class _ColorPickerHomeState extends State<ColorPickerHome> {
  Color _selectedColor = Colors.blue;
  bool _isPicking = false;
  Timer? _colorUpdateTimer;
  Color? _hoverColor;

  @override
  void dispose() {
    _colorUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickColorFromScreen() async {
    setState(() {
      _isPicking = true;
    });

    try {
      // Minimize window to allow clicking anywhere
      await windowManager.minimize();

      // Wait a bit for window to minimize
      await Future.delayed(const Duration(milliseconds: 500));

      // Use native color picker with Windows hooks
      final pickedColor = await NativeColorPicker.pickColor(
        onColorUpdate: (color) {
          if (mounted) {
            setState(() {
              _hoverColor = color;
            });
          }
        },
      );

      // Restore window
      await windowManager.restore();
      await windowManager.focus();

      if (pickedColor != null && mounted) {
        setState(() {
          _selectedColor = pickedColor;
          _isPicking = false;
          _hoverColor = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('color_selected_success'.tr),
            duration: const Duration(seconds: 1),
          ),
        );
      } else if (mounted) {
        setState(() {
          _isPicking = false;
          _hoverColor = null;
        });
      }
    } catch (e) {
      await windowManager.restore();
      await windowManager.focus();

      if (mounted) {
        setState(() {
          _isPicking = false;
          _hoverColor = null;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    }
  }

  void _copyToClipboard(String text, String formatName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$formatName ${'color_copied'.tr}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textTheme = context.theme.textTheme;
  final themeController = Get.smartFind<ThemeController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        centerTitle: true,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              Get.bottomSheet(LangugeBottomSheet(colorScheme: colorScheme));
            },
          ).paddingOnly(right: 16),
          Obx(() => IconButton(
            icon: Icon(
              themeController.appThemeMode.value == AvailableTheme.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              themeController.toggleTheme();
            },
            tooltip: themeController.appThemeMode.value == AvailableTheme.dark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          )),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Color Display Card
              Card(
                elevation: 8,
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'selected_color'.tr,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isPicking ? null : _pickColorFromScreen,
                        icon: _isPicking
                            ? const Icon(
                                Icons.mouse,
                              ) // تغییر آیکون به موس هنگام انتخاب رنگ
                            : const Icon(Icons.colorize),
                        label: Text(
                          _isPicking
                              ? 'picking_color'.tr
                              : 'pick_color_from_screen'.tr,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Color Formats Card
              Card(
                elevation: 4,
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'color_formats'.tr,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      // Hex Format
                      _buildColorFormatRow(
                        'HEX',
                        '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                      ),
                      const SizedBox(height: 12),

                      // Color(0xFF...) Format
                      _buildColorFormatRow(
                        'Color (0xFF)',
                        'Color(0x${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()})',
                      ),
                      const SizedBox(height: 12),

                      // Color.fromARGB Format
                      _buildColorFormatRow(
                        'Color.fromARGB',
                        'Color.fromARGB(${_selectedColor.alpha}, ${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue})',
                      ),
                      const SizedBox(height: 12),

                      // Color.fromRGBO Format
                      _buildColorFormatRow(
                        'Color.fromRGBO',
                        'Color.fromRGBO(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}, ${(_selectedColor.alpha / 255).toStringAsFixed(2)})',
                      ),
                      const SizedBox(height: 12),

                      // RGB Format
                      _buildColorFormatRow(
                        'RGB',
                        'rgb(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue})',
                      ),
                      const SizedBox(height: 12),

                      // RGBA Format
                      _buildColorFormatRow(
                        'RGBA',
                        'rgba(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue}, ${(_selectedColor.alpha / 255).toStringAsFixed(2)})',
                      ),
                      const SizedBox(height: 12),

                      // HSL Format
                      _buildColorFormatRow(
                        'HSL',
                        _getHSLString(_selectedColor),
                      ),
                      const SizedBox(height: 12),

                      // Integer Value
                      _buildColorFormatRow(
                        'Integer',
                        '${_selectedColor.value}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorFormatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'copy'.tr,
            onPressed: () => _copyToClipboard(value, label),
          ),
        ],
      ),
    );
  }

  String _getHSLString(Color color) {
    final r = color.red / 255;
    final g = color.green / 255;
    final b = color.blue / 255;

    final max = [r, g, b].reduce((a, b) => a > b ? a : b);
    final min = [r, g, b].reduce((a, b) => a < b ? a : b);
    final delta = max - min;

    double h = 0;
    double s = 0;
    final l = (max + min) / 2;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      if (max == r) {
        h = ((g - b) / delta + (g < b ? 6 : 0)) / 6;
      } else if (max == g) {
        h = ((b - r) / delta + 2) / 6;
      } else {
        h = ((r - g) / delta + 4) / 6;
      }
    }

    return 'hsl(${(h * 360).round()}°, ${(s * 100).round()}%, ${(l * 100).round()}%)';
  }
}
