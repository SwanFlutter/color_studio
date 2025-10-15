#include "color_picker_plugin.h"
#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <string>

namespace color_studio {

static HHOOK mouseHook = NULL;
static flutter::MethodChannel<flutter::EncodableValue>* methodChannel = nullptr;
static bool isPickingColor = false;
static std::unique_ptr<ColorPickerPlugin> pluginInstance = nullptr;

// Mouse hook callback
LRESULT CALLBACK MouseHookProc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode >= 0 && isPickingColor) {
        if (wParam == WM_LBUTTONDOWN) {
            // Get cursor position
            POINT pt;
            GetCursorPos(&pt);
            
            // Get pixel color
            HDC hdc = GetDC(NULL);
            COLORREF color = GetPixel(hdc, pt.x, pt.y);
            ReleaseDC(NULL, hdc);
            
            // Extract RGB
            int r = GetRValue(color);
            int g = GetGValue(color);
            int b = GetBValue(color);
            
            // Send to Flutter
            if (methodChannel) {
                flutter::EncodableMap args;
                args[flutter::EncodableValue("r")] = flutter::EncodableValue(r);
                args[flutter::EncodableValue("g")] = flutter::EncodableValue(g);
                args[flutter::EncodableValue("b")] = flutter::EncodableValue(b);
                
                methodChannel->InvokeMethod("onColorPicked", 
                    std::make_unique<flutter::EncodableValue>(args));
            }
            
            isPickingColor = false;
            return 1; // Block the click
        }
        else if (wParam == WM_RBUTTONDOWN) {
            // Cancel picking
            if (methodChannel) {
                methodChannel->InvokeMethod("onPickingCancelled", nullptr);
            }
            isPickingColor = false;
            return 1;
        }
    }
    
    return CallNextHookEx(mouseHook, nCode, wParam, lParam);
}

static std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channelInstance = nullptr;

void ColorPickerPlugin::RegisterWithEngine(flutter::FlutterEngine* engine) {
    channelInstance = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        engine->messenger(), "color_studio/color_picker",
        &flutter::StandardMethodCodec::GetInstance());
    
    methodChannel = channelInstance.get();
    
    pluginInstance = std::make_unique<ColorPickerPlugin>();
    
    channelInstance->SetMethodCallHandler(
        [](const auto& call, auto result) {
            if (pluginInstance) {
                pluginInstance->HandleMethodCall(call, std::move(result));
            }
        });
}

ColorPickerPlugin::ColorPickerPlugin() {}
ColorPickerPlugin::~ColorPickerPlugin() {
    StopPicking();
}

void ColorPickerPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    
    if (method_call.method_name() == "startPicking") {
        StartPicking();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_call.method_name() == "stopPicking") {
        StopPicking();
        result->Success(flutter::EncodableValue(true));
    }
    else if (method_call.method_name() == "getColorAtCursor") {
        POINT pt;
        GetCursorPos(&pt);
        
        HDC hdc = GetDC(NULL);
        COLORREF color = GetPixel(hdc, pt.x, pt.y);
        ReleaseDC(NULL, hdc);
        
        flutter::EncodableMap colorMap;
        colorMap[flutter::EncodableValue("r")] = flutter::EncodableValue(GetRValue(color));
        colorMap[flutter::EncodableValue("g")] = flutter::EncodableValue(GetGValue(color));
        colorMap[flutter::EncodableValue("b")] = flutter::EncodableValue(GetBValue(color));
        
        result->Success(flutter::EncodableValue(colorMap));
    }
    else {
        result->NotImplemented();
    }
}

void ColorPickerPlugin::StartPicking() {
    if (mouseHook == NULL) {
        isPickingColor = true;
        mouseHook = SetWindowsHookEx(WH_MOUSE_LL, MouseHookProc, NULL, 0);
    }
}

void ColorPickerPlugin::StopPicking() {
    if (mouseHook != NULL) {
        UnhookWindowsHookEx(mouseHook);
        mouseHook = NULL;
        isPickingColor = false;
    }
}

}  // namespace color_studio
