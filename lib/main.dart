import 'dart:async';

import 'package:circuts2/bindings.dart';
import 'package:circuts2/root/root_view.dart';
import 'package:circuts2/settings/settings_controller.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import 'package:window_manager/window_manager.dart';

import 'helper.dart';
// import 'package:shell/shell.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // WindowOptions windowOptions = WindowOptions(
  //   size: Size(800, 600),
  //   center: true,
  //   backgroundColor: fluent.Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.hidden,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });





  runApp(GetMaterialApp(
    home: MyApp(),
    initialBinding: RootBindings(),
  ));
}


class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Circuts',
      home: RootView(),
      theme: fluent.ThemeData(
        typography: fluent.Typography.raw(
          caption: TextStyle(
            fontSize: 12,
            color: fluent.Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: NavigationPaneTheme(
            data: NavigationPaneThemeData(),
            child: child!,
          ),
        );
      },
    );
  }
}
