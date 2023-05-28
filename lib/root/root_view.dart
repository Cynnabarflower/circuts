import 'package:circuts2/root/root_controller.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootView extends GetView<RootController> {

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationView(
        content: NavigationBody.builder(
          index: controller.index,
          itemBuilder: (context, index) {
            return controller.pages[index]();
          },
        ),
        pane: NavigationPane(
            displayMode: PaneDisplayMode.auto,
            selected: controller.index,
            size: NavigationPaneSize(
              openMaxWidth: 120
            ),
            onChanged: (v) => controller.index = v,
            footerItems: [
              PaneItem(
                  icon: Icon(FluentIcons.settings),
                title: Text('Settings')
              ),
            ],
            items: [
              PaneItem(
                  icon: Icon(FluentIcons.reading_mode),
                  title: Text("Lab 1")
              ),
              PaneItem(
                  icon: Icon(FluentIcons.reading_mode),
                  title: Text("Lab 2")
              )
            ]
        ),
      ),
    );
  }
}