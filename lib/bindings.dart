import 'package:circuts2/helper.dart';
import 'package:circuts2/lab1/lab1_controller.dart';
import 'package:circuts2/root/root_controller.dart';
import 'package:circuts2/settings/settings_controller.dart';
import 'package:get/get.dart';

import 'lab2/lab2_controller.dart';

class RootBindings extends Bindings {

  @override
  void dependencies() {
    Get.put(RootController());
    Get.put(SettingsController());
    Get.put(Lab1Controller());
    Get.put(Lab2Controller());
    Helper.loadPythonPath().then((value) {
      if (value) {
        Get.find<Lab1Controller>().updateData();
      }
    });
  }
}