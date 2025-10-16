import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

// Windows API definitions
typedef GetCursorPosNative = Int32 Function(Pointer<POINT> lpPoint);
typedef GetCursorPosDart = int Function(Pointer<POINT> lpPoint);

typedef GetDCNative = IntPtr Function(IntPtr hWnd);
typedef GetDCDart = int Function(int hWnd);

typedef GetPixelNative = Uint32 Function(IntPtr hdc, Int32 x, Int32 y);
typedef GetPixelDart = int Function(int hdc, int x, int y);

typedef ReleaseDCNative = Int32 Function(IntPtr hWnd, IntPtr hDC);
typedef ReleaseDCDart = int Function(int hWnd, int hDC);

// POINT structure
final class POINT extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;
}

class ColorPickerService {
  static final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
  static final DynamicLibrary _gdi32 = DynamicLibrary.open('gdi32.dll');

  static final GetCursorPosDart _getCursorPos = _user32
      .lookup<NativeFunction<GetCursorPosNative>>('GetCursorPos')
      .asFunction();

  static final GetDCDart _getDC = _user32
      .lookup<NativeFunction<GetDCNative>>('GetDC')
      .asFunction();

  static final GetPixelDart _getPixel = _gdi32
      .lookup<NativeFunction<GetPixelNative>>('GetPixel')
      .asFunction();

  static final ReleaseDCDart _releaseDC = _user32
      .lookup<NativeFunction<ReleaseDCNative>>('ReleaseDC')
      .asFunction();

  /// Get color at current cursor position
  static Color? getColorAtCursor() {
    final point = calloc<POINT>();

    try {
      // Get cursor position
      final result = _getCursorPos(point);
      if (result == 0) {
        return null;
      }

      final x = point.ref.x;
      final y = point.ref.y;

      // Get device context for the entire screen
      final hdc = _getDC(0);
      if (hdc == 0) {
        return null;
      }

      try {
        // Get pixel color at cursor position
        final colorRef = _getPixel(hdc, x, y);

        // Windows COLORREF format is 0x00BBGGRR
        final r = colorRef & 0xFF;
        final g = (colorRef >> 8) & 0xFF;
        final b = (colorRef >> 16) & 0xFF;

        return Color.fromARGB(255, r, g, b);
      } finally {
        _releaseDC(0, hdc);
      }
    } finally {
      calloc.free(point);
    }
  }

  /// Get color at specific screen coordinates
  static Color? getColorAtPosition(int x, int y) {
    final hdc = _getDC(0);
    if (hdc == 0) {
      return null;
    }

    try {
      final colorRef = _getPixel(hdc, x, y);

      // Windows COLORREF format is 0x00BBGGRR
      final r = colorRef & 0xFF;
      final g = (colorRef >> 8) & 0xFF;
      final b = (colorRef >> 16) & 0xFF;

      return Color.fromARGB(255, r, g, b);
    } finally {
      _releaseDC(0, hdc);
    }
  }
}
