import 'package:color_studio/controller/language_cotroller.dart';
import 'package:color_studio/controller/theme_controller.dart';
import 'package:get_x_master/get_x_master.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.smartLazyPut(() => ThemeController());
    Get.smartLazyPut(() => LanguageController());
    // Get.lazyPut(() => ThemeController());
  }
}
