import 'dart:math';

import 'package:circuts2/helper.dart' as helper;
import 'package:circuts2/simulator/plot_data.dart';
import 'package:circuts2/simulator/schemas.dart';
import 'package:circuts2/simulator/simulation_result.dart';
import 'package:circuts2/simulator/simulator.dart';
import 'package:circuts2/widgets/plot.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


class Lab1Controller extends GetxController {
  RxList<PlotData> allPlots =<PlotData>[].obs;
  RxMap<String, bool> visiblePlots = <String, bool>{}.obs;
  RxString info = ''.obs;
  List<RxList<double>> plotData = List.generate(7, (index) => <double>[].obs);
  List<SimulationResult> results = [];
  List<SimulationResult> resultsFreq = [];
  var plotKeys = [GlobalKey()];
  var plotControllers = [
    PlotController.empty(),
  ];
  var r = 1.0.obs;
  var c = 1.0.obs;
  var l = 1.0.obs;
  Map<String, List<SimulationResult>> cache = {};

  Future updateData({useCache = true}) async {
    var schema = (Schemas.first
      ..data['R1']![2] = '${r.value}'
      ..data['C1']![2] = '${c.value}u'
      ..data['L1']![2] = '${l.value}u'
    ).toString();
    if (useCache && cache[schema] != null) {
      print('from cahche');
      results = cache[schema]!;
    } else {
      results = await Simulator().simulate(schema, variableString: 'current voltage');
    }
    if (useCache) {
      cache[schema] = [...results];
    }


    var schemaFrequencyResponse = (Schemas.firstFrequencyResponse
      ..data['R1']![2] = '${r.value}'
      ..data['C1']![2] = '${c.value}u'
      ..data['L1']![2] = '${l.value}u'
    ).toString();
    if (useCache && cache[schemaFrequencyResponse] != null) {
      print('from cahche');
      resultsFreq = cache[schemaFrequencyResponse]!;
    } else {
      resultsFreq = await Simulator().simulate(schemaFrequencyResponse, variableString: 'voltage');
    }
    if (useCache) {
      cache[schemaFrequencyResponse] = [...resultsFreq];
    }

    allPlots.assignAll([
      PlotData.fromResults(results: results, tag: 'V1', voltage: true, color: Colors.blue),
      PlotData.fromResults(results: results, tag: 'C1', voltage: true, color: Colors.green),
      PlotData.fromResults(results: results, tag: 'C1', current: true, color: Colors.purple),
      PlotData.fromResults(results: results, tag: 'L1', voltage: true, color: Colors.teal),
      PlotData.fromResults(results: results, tag: 'L1', current: true, color: Colors.orange),
    ]);

    var data = PlotData.fromResults(results: resultsFreq, tag: 'L1', voltage: true, color: Colors.red, token: 'L1/V1');
    var data2 = PlotData.fromResults(results: resultsFreq, tag: 'V1', voltage: true, color: Colors.red);
    data.min = 999999999;
    data.max = -999999999;
    for (int i = 0; i < data.data.length; i++) {
      data.data[i] = data2.data[i] == 0 ? 0.0 : (data.data[i] / data2.data[i]);
      data.min = min(data.min, data.data[i]);
      data.max = min(data.max, data.data[i]);
    }
    data.tag = 'Freq response';
    allPlots.add(data);

    for (var e in allPlots) {
      visiblePlots[e.token] = visiblePlots[e.token] ?? false;
    }

    updatePlots();
  }

  void updatePlot(int index, {double? scale, double? yAxisMin, double? yAxisMax, List<List<double>>? dataset, List<Color>? colors,  List<String>? labels, List<String>? corners, List<PlotData>? plotDatas}) {
    if (dataset != null) {
      plotControllers[index].dataset = dataset;
    }
    if (plotDatas != null) {
      plotControllers[index].dataset = plotDatas.map((e) => e.data).toList();
      plotControllers[index].yAxisMin = plotDatas.map((e) => e.min).toList();
      plotControllers[index].yAxisMax = plotDatas.map((e) => e.max).toList();
      var corners = ['', '', '', ''];
      var hasCurrent = plotDatas.any((element) => element.current);
      var hasVoltage = plotDatas.any((element) => element.voltage);
      if (hasCurrent) {
         corners[0] = plotDatas.where((e) => e.current).map((e) => e.max).max()!.toStringAsPrecision(2) + 'A';
         corners[3] = plotDatas.where((e) => e.current).map((e) => e.min).min()!.toStringAsPrecision(2) + 'A';
      }
      if (hasVoltage) {
        corners[1] = plotDatas.where((e) => e.voltage).map((e) => e.max).max()!.toStringAsPrecision(2) + 'V';
        corners[2] = plotDatas.where((e) => e.voltage).map((e) => e.min).min()!.toStringAsPrecision(2) + 'V';
      }
      plotControllers[index].corners = corners;
      plotControllers[index].traceColor = plotDatas.map((e) => e.color).toList();
    }
    if (scale != null) {
      plotControllers[index].scale = scale;
    }
    if (yAxisMin != null) {
      plotControllers[index].yAxisMin = yAxisMin;
    }
    if (yAxisMax != null) {
      plotControllers[index].yAxisMax = yAxisMax;
    }
    if (colors != null) {
      plotControllers[index].traceColor = colors;
    }
    if (labels != null) {
      plotControllers[index].labels = labels;
    }
    if (corners != null) {
      plotControllers[index].corners = corners;
    }
  }

  void updatePlots() {
    updatePlot(0,
      plotDatas: allPlots.where((element) => visiblePlots[element.token] ?? false).toList(),
    );
  }

  Future loadInfo() async {
    info.trigger(await rootBundle.loadString('assets/lab1.md'));
  }

  @override
  void onInit() {
    super.onInit();
    loadInfo();
    // updateData();
  }
}