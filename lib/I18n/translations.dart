
import 'package:get_x_master/get_x_master.dart';
import 'en_US.dart';
import 'fa_IR.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': EnUS.translations,
        'fa_IR': FaIR.translations,
      };
}
