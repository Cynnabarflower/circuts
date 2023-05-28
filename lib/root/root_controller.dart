import 'package:circuts2/lab1/lab1_view.dart';
import 'package:circuts2/lab2/lab2_view.dart';
import 'package:circuts2/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootController extends GetxController {
  var _index = 0.obs;

  get index => _index.value;

  set index(v) => _index.trigger(v);

  final pages = [() => Lab1View(), () => Material(child: Container(
    color: Colors.teal,
    alignment: Alignment.center,
  )), () => SettingsView()];

  get page => pages[index];



}