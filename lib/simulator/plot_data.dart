import 'package:fluent_ui/fluent_ui.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'simulation_result.dart';

class PlotData {
  var data = <double>[];
  var voltage = false;
  var current = false;
  String tag;
  late double min;
  late double max;

  late String _token;
  AccentColor color = fluent.Colors.blue;

  get token => _token;

  PlotData.fromResults({required List<SimulationResult> results, bool? voltage, bool? current, AccentColor? color, required this.tag, token}) {
    this.color = color ?? fluent.Colors.blue;
    this.voltage = voltage ?? false;
    this.current = current ?? false;
    _token = token ?? (tag + (this.voltage ? 'v' : this.current ? 'a' : ''));

    if (this.voltage) {
      data = [...results.firstWhere((element) => element.name == tag).voltage];
    } else if (this.current) {
      data = [...results.firstWhere((element) => element.name == tag).current];
    }
    min = 9999999;
    max = -9999999;
    for (var d in data) {
      if (d < min) {
        min = d;
      }
      if (d > max) {
        max = d;
      }
    }

  }
}