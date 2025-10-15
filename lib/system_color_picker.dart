import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

// Windows API definitions for mouse hook
typedef SetWindowsHookExNative = IntPtr Function(Int32 idHook, Pointer<NativeFunction<HookProc>> lpfn, IntPtr hMod, Int32 dwThreadId);
typedef SetWindowsHookExDart = int Function(int idHook, Pointer<NativeFunction<HookProc>> lpfn, int hMod, int dwThreadId);

typedef CallNextHookExNative = IntPtr Function(IntPtr hhk, Int32 nCode, IntPtr wParam, IntPtr lParam);
typedef CallNextHookExDart = int Function(int hhk, int nCode, int wParam, int lParam);

typedef UnhookWindowsHookExNative = Int32 Function(IntPtr hhk);
typedef UnhookWindowsHookExDart = int Function(int hhk);

typedef GetMessageNative = Int32 Function(Pointer<MSG> lpMsg, IntPtr hWnd, Uint32 wMsgFilterMin, Uint32 wMsgFilterMax);
typedef GetMessageDart = int Function(Pointer<MSG> lpMsg, int hWnd, int wMsgFilterMin, int wMsgFilterMax);

typedef HookProc = IntPtr Function(Int32 nCode, IntPtr wParam, IntPtr lParam);

typedef GetCursorPosNative = Int32 Function(Pointer<POINT> lpPoint);
typedef GetCursorPosDart = int Function(Pointer<POINT> lpPoint);

typedef GetDCNative = IntPtr Function(IntPtr hWnd);
typedef GetDCDart = int Function(int hWnd);

typedef GetPixelNative = Uint32 Function(IntPtr hdc, Int32 x, Int32 y);
typedef GetPixelDart = int Function(int hdc, int x, int y);

typedef ReleaseDCNative = Int32 Function(IntPtr hWnd, IntPtr hDC);
typedef ReleaseDCDart = int Function(int hWnd, int hDC);

// Structures
final class POINT extends Struct {
  @Int32()
  external int x;
  
  @Int32()
  external int y;
}

final class MSG extends Struct {
  @IntPtr()
  external int hwnd;
  
  @Uint32()
  external int message;
  
  @IntPtr()
  external int wParam;
  
  @IntPtr()
  external int lParam;
  
  @Uint32()
  external int time;
  
  external POINT pt;
}

class SystemColorPicker {
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

  /// Get color at current mouse position (works anywhere on screen)
  static Color? getColorAtCursor() {
    final point = calloc<POINT>();
    
    try {
      final result = _getCursorPos(point);
      if (result == 0) {
        return null;
      }

      final x = point.ref.x;
      final y = point.ref.y;

      final hdc = _getDC(0); // Get DC for entire screen
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
    } finally {
      calloc.free(point);
    }
  }

  /// Get current cursor position
  static Offset? getCursorPosition() {
    final point = calloc<POINT>();
    
    try {
      final result = _getCursorPos(point);
      if (result == 0) {
        return null;
      }

      return Offset(point.ref.x.toDouble(), point.ref.y.toDouble());
    } finally {
      calloc.free(point);
    }
  }
}
