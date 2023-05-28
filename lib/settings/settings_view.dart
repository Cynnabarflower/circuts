import 'package:circuts2/helper.dart';
import 'package:circuts2/settings/settings_controller.dart';
import 'package:f_logs/f_logs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:xterm/frontend/terminal_view.dart';

class SettingsView extends GetView<SettingsController> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: m.Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(right: 32, bottom: 16.0, top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: controller.formKey,
                        child: TextFormBox(
                          header: 'Python path',
                          placeholder: 'Path to python.exe',
                          controller: controller.pythonPathController,
                          onChanged: (v) async {
                            if (await Helper.setPythonPath(v)) {
                              controller.validatorMap[v] = true;
                            } else {
                              controller.validatorMap[v] = false;
                            }
                            controller.formKey.currentState?.validate();
                          },
                          validator: (v) {
                            return (controller.validatorMap[v] ?? false) ? null : 'Not a python path';
                          },
                          textInputAction: TextInputAction.next,
                          suffix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(FluentIcons.folder),
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                          initialDirectory: controller
                                              .pythonPathController.text,

                                      );
                                  if (result != null) {
                                    if (await Helper.setPythonPath(
                                        result.files.single.path!)) {
                                      controller.pythonPathController.text =
                                          Helper.pythonPath;
                                    } else {
                                      // controller.validatorMap[result.files.single.path!] = false;
                                      // controller.formKey.currentState?.validate();
                                      showPythonSnackbar(context);
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(FluentIcons.search),
                                onPressed: () {
                                  Helper.loadPythonPath(false).then((value) {
                                    if (value) {
                                      controller.pythonPathController.text = Helper.pythonPath;
                                      controller.validatorMap[Helper.pythonPath] = true;
                                      controller.formKey.currentState?.validate();
                                    } else {
                                      showSnackbar(context, Snackbar(content: Text('Python not found, you can install it by pressing the button below')));
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          // outsideSuffix:
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Button(
                  child: Obx(() => Text(controller.embeddedPythonInstalled.isTrue ? 'Reinstall python' : 'Install python')), onPressed: controller.installPython
              ),
              Obx(
                () => Visibility(
                  visible: controller.installationProgress.value > 0,
                  child: ProgressBar(
                    value: controller.installationProgress.value
                  ),
                ),
              ),
              Obx(
                  () => Visibility(
                      visible: controller.installationMessage.isNotEmpty,
                      child: Text(controller.installationMessage.value))
              ),
              Button(
                onPressed: () async {
                  var s = (await FLog.getAllLogs()).map((e) => e.text);
                  m.showDialog(context: context, builder: (c) {
                    return Center(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(40.0),
                              child: ListView(
                                children: [
                                  ...s.map((e) => Text(e ?? ''))
                                ],
                              ),
                            ),
                          ),
                          Button(
                            child: Text('ok'),
                            onPressed: () => Get.back(),
                          ),
                          Button(
                            child: Text('clear'),
                            onPressed: () => FLog.clearLogs(),
                          )
                        ],
                      ),
                    );
                  });
                },
                child: Text('Logs'),
              ),
              Expanded(
                  child: Obx(
                    () => controller.terminal.value == null ? Center(
                      child: Button(
                        child: const Text('Init terminal'),
                        onPressed: () {
                          controller.initTerm();
                        },
                      ),
                    ) : TerminalView(
                terminal: controller.terminal.value!,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void showPythonSnackbar(context) {
    showSnackbar(
        context,
        Snackbar(
          content: Text('Expected path to python.exe'),
        ));
  }
}
