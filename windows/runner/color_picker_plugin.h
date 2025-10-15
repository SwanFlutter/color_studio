#ifndef FLUTTER_PLUGIN_COLOR_PICKER_PLUGIN_H_
#define FLUTTER_PLUGIN_COLOR_PICKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/flutter_engine.h>
#include <memory>

namespace color_studio {

class ColorPickerPlugin {
 public:
  static void RegisterWithEngine(flutter::FlutterEngine* engine);

  ColorPickerPlugin();
  virtual ~ColorPickerPlugin();

  ColorPickerPlugin(const ColorPickerPlugin&) = delete;
  ColorPickerPlugin& operator=(const ColorPickerPlugin&) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void StartPicking();
  void StopPicking();
};

}  // namespace color_studio

#endif  // FLUTTER_PLUGIN_COLOR_PICKER_PLUGIN_H_
