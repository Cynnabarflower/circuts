import 'package:circuts2/helper.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';

import 'oscilloscope.dart';



class PlotController  {
  final _scale = 1.0.obs;
  final _offset = 0.obs;
  final RxList<double> _yAxisMin = <double>[0.0].obs;
  final RxList<double> _yAxisMax = <double>[0.0].obs;
  final RxList<List<double>> _dataset = <List<double>>[].obs;
  final RxList<Color> _traceColor = <Color>[].obs;
  final RxList<String> _labels = <String>[].obs;
  final RxList<String> _corners = <String>[].obs;
  set scale(v) => _scale.value = v;
  set yAxisMin(v) {
    if (v.runtimeType == double) {
      _yAxisMin.value = List.filled(_dataset.length, v);
    } else {
      _yAxisMin.value = List.of(v);
    }
  }
  set yAxisMax(v) {
    if (v.runtimeType == double) {
      _yAxisMax.value = RxList.filled(_dataset.length, v);
    } else {
      _yAxisMax.value = RxList.of(v);
    }
  }
  set dataset(v) => _dataset.value = v;
  set traceColor(v) => _traceColor.value = v;
  set labels(v) => _labels.value = v;
  set corners(v) => _corners.value = v;

  PlotController.empty();
}

class Plot extends StatelessWidget {

  PlotController controller;

  Plot({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Obx(() => Text('Scale: ${controller._scale.toStringAsFixed(2)} ')),
              SizedBox(width: 16.0,),
              Expanded(
                child: Obx(() => Slider(
                  min: 1,
                  max: 20,
                  value: controller._scale.value, onChanged: (v){controller._scale.trigger(v);},)),
              )
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Obx(
                    () {
                      return Stack(
                    alignment: Alignment.center,
                    children:
                    [
                      if (controller._dataset.isNotEmpty)
                      GestureDetector(
                        child: Oscilloscope(
                          strokeWidth: 2.0,
                          xScale: constraints.maxWidth / controller._dataset.map((e) => e.length).max()! * controller._scale.value,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          backgroundColor: Colors.transparent,
                          traceColors: controller._traceColor,
                          yAxisColor: Colors.black.withOpacity(0.6),
                          showYAxis: true,
                          yAxisMax: controller._yAxisMax.max()!,
                          yAxisMin: controller._yAxisMin.min()!,
                          dataSets: controller._dataset,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 4.0,
                            top: 4.0,
                          ),
                          child: Column(
                            children:
                            List.generate(controller._labels.length, (index) => Text(controller._labels[index], style: TextStyle(color: controller._traceColor[index]),)),
                          ),
                        ),
                      ),
                      // Oscilloscope(
                      //   strokeWidth: 1.0,
                      //   xScale: 99,
                      //   backgroundColor: Colors.transparent,
                      //   traceColors: [Colors.red, Colors.red],
                      //   showYAxis: false,
                      //   yAxisMax: 1.0,
                      //   yAxisMin: -1.0,
                      //   dataSets: [[-1.0, -1.0], [1.0, 1.0]],
                      // ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Text('${controller._corners.length > 0 ? controller._corners[0] : ''}')),
                              Obx(() => Text('${controller._corners.length > 3 ? controller._corners[3] : ''}')),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Text('${controller._corners.length > 1 ? controller._corners[1] : ''}')),
                              Obx(() => Text('${controller._corners.length > 2 ? controller._corners[2] : ''}')),
                            ],
                          ),
                        ),
                      )
                    ]
                );},
              );
            }
          ),
        ),
      ],
    );
  }
}