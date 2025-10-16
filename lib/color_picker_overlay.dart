import 'dart:async';

import 'package:flutter/material.dart';

import 'color_picker_service.dart';

class ColorPickerOverlay extends StatefulWidget {
  final Function(Color) onColorPicked;
  final VoidCallback onCancel;

  const ColorPickerOverlay({
    super.key,
    required this.onColorPicked,
    required this.onCancel,
  });

  @override
  State<ColorPickerOverlay> createState() => _ColorPickerOverlayState();
}

class _ColorPickerOverlayState extends State<ColorPickerOverlay> {
  Color? _currentColor;
  Offset? _cursorPosition;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    // Update color every 50ms while hovering
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) {
        final color = ColorPickerService.getColorAtCursor();
        if (color != null && color != _currentColor) {
          setState(() {
            _currentColor = color;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (_currentColor != null) {
      widget.onColorPicked(_currentColor!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        onHover: (event) {
          setState(() {
            _cursorPosition = event.position;
          });
        },
        child: GestureDetector(
          onTap: _handleTap,
          onSecondaryTap: widget.onCancel,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Instructions
                Positioned(
                  top: 20,
                  left: 20,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🎨 انتخاب رنگ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'روی رنگ مورد نظر کلیک کنید',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'کلیک راست برای لغو',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          if (_currentColor != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: 100,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _currentColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '#${_currentColor!.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Magnifier near cursor
                if (_cursorPosition != null && _currentColor != null)
                  Positioned(
                    left: _cursorPosition!.dx + 25,
                    top: _cursorPosition!.dy + 25,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.black, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(46),
                          child: Stack(
                            children: [
                              Container(color: _currentColor),
                              // Center crosshair
                              Center(
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
