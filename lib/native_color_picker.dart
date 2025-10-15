import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NativeColorPicker {
  static const MethodChannel _channel = MethodChannel('color_studio/color_picker');
  
  static StreamController<Color>? _colorPickedController;
  static StreamController<void>? _cancelledController;

  static void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onColorPicked') {
        final args = call.arguments as Map;
        final r = args['r'] as int;
        final g = args['g'] as int;
        final b = args['b'] as int;
        
        final color = Color.fromARGB(255, r, g, b);
        _colorPickedController?.add(color);
      } else if (call.method == 'onPickingCancelled') {
        _cancelledController?.add(null);
      }
    });
  }

  /// Start picking color with native Windows hook
  static Future<Color?> pickColor({
    required Function(Color) onColorUpdate,
  }) async {
    _setupMethodCallHandler();
    
    final completer = Completer<Color?>();
    
    _colorPickedController = StreamController<Color>.broadcast();
    _cancelledController = StreamController<void>.broadcast();
    
    _colorPickedController!.stream.listen((color) {
      if (!completer.isCompleted) {
        completer.complete(color);
      }
    });
    
    _cancelledController!.stream.listen((_) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    // Start the native color picking
    try {
      await _channel.invokeMethod('startPicking');
      
      // Update color in real-time
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }
        
        _getColorAtCursor().then((color) {
          if (color != null) {
            onColorUpdate(color);
          }
        });
      });
      
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }
    
    final result = await completer.future;
    
    // Cleanup
    await stopPicking();
    await _colorPickedController?.close();
    await _cancelledController?.close();
    _colorPickedController = null;
    _cancelledController = null;
    
    return result;
  }

  /// Get color at current cursor position
  static Future<Color?> _getColorAtCursor() async {
    try {
      final result = await _channel.invokeMethod('getColorAtCursor');
      if (result is Map) {
        final r = result['r'] as int;
        final g = result['g'] as int;
        final b = result['b'] as int;
        return Color.fromARGB(255, r, g, b);
      }
    } catch (e) {
      // Ignore errors during cursor tracking
    }
    return null;
  }

  /// Stop color picking
  static Future<void> stopPicking() async {
    try {
      await _channel.invokeMethod('stopPicking');
    } catch (e) {
      // Ignore
    }
  }
}
