import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'native_color_picker.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

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

  runApp(const ColorStudioApp());
}

class ColorStudioApp extends StatelessWidget {
  const ColorStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Studio - Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ColorPickerHome(),
    );
  }
}

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
          const SnackBar(
            content: Text('رنگ با موفقیت انتخاب شد! ✓'),
            duration: Duration(seconds: 1),
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
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e')),
        );
      }
    }
  }


  void _copyToClipboard(String text, String formatName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$formatName کپی شد'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Studio - Flutter'),
        centerTitle: true,
        elevation: 0,
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
                        'رنگ انتخاب شده',
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
                              color: _selectedColor.withOpacity(0.4),
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
                            ? const Icon(Icons.mouse) // تغییر آیکون به موس هنگام انتخاب رنگ
                            : const Icon(Icons.colorize),
                        label: Text(_isPicking ? 'در حال انتخاب رنگ... (کلیک کنید)' : 'انتخاب رنگ از صفحه'),
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
                        'فرمت‌های Flutter',
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: 'کپی',
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
