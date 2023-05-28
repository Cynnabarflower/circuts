import 'dart:math';

import 'package:circuts2/helper.dart';
import 'package:circuts2/lab2/lab2_controller.dart';
import 'package:circuts2/widgets/my_draggable.dart';
import 'package:circuts2/widgets/plot_card.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

import '../widgets/title_text.dart';

class Lab2View extends GetView<Lab2Controller> {

  static const spacing = 12.0;
  var _tiles = <Widget>[];
  var isLandscape = true;

  @override
  Widget build(BuildContext context) {
    var infoWidth = (BoxConstraints c) => isLandscape ? (c.maxWidth - spacing) / 2 : c.maxWidth;
    var plotWidth = (BoxConstraints c) => isLandscape ? (c.maxWidth - spacing) / 2 : c.maxWidth;

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(spacing),
        child: LayoutBuilder(
          builder: (context, constraints) {
            isLandscape = (constraints.maxWidth > 600.0 && constraints.maxWidth/constraints.maxHeight > 4/3);
            _tiles = [
              Builder(
                builder: (context) {
                  print('v: $isLandscape');
                  return SizedBox(
                    key: GlobalKey(),
                    height: isLandscape ? constraints.maxHeight : 500,
                    width: infoWidth(constraints),
                    child: Card(
                        child: InfoLabel(
                          label: 'Условия',
                          child: Obx(
                            () => Markdown(
                              controller: ScrollController(initialScrollOffset: 0),
                              shrinkWrap: true,
                              data: controller.info.string,
                            ),
                          )
                        )
                    ),
                  );
                }
              ),
              Builder(
                builder: (context) => SizedBox(
                  width: plotWidth(constraints),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black.withOpacity(0.1),
                    ),
                    child: Column(
                      children: [
                        PlotCard(
                          controller: controller.plotControllers[0],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('Select plots:'),
                                  ),
                                ),
                                if (controller.allPlots.isNotEmpty)
                                ...controller.allPlots.map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Obx(
                                    () => ToggleButton(
                                        child: Text(e.tag + (e.voltage ? 'V' : e.current ? 'A' : '')),
                                        checked: controller.visiblePlots[e.token] ?? false,
                                        onChanged: (v){
                                          controller.visiblePlots[e.token] = v;
                                          controller.updatePlots();
                                        },
                                      style: ToggleButtonThemeData.standard(
                                        ThemeData.light().copyWith(
                                          activeColor: e.color,
                                          checkedColor: e.color,
                                          accentColor: e.color,
                                        )
                                      ),
                                        ),
                                  ),
                                )
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Obx(() => Text('R: ${controller.r.value.toStringAsFixed(1)} ')),
                              const SizedBox(width: 16.0,),
                              Obx(() => Slider(
                                min: 1.0,
                                max: 100.0,
                                divisions: 100,
                                value: controller.r.value, onChanged: (v){controller.r.trigger(v.roundToDouble());}, onChangeEnd: (v) => controller.updateData(),))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Obx(() => Text('C: ${controller.c.value.toStringAsFixed(1)}m ')),
                              const SizedBox(width: 16.0,),
                              Obx(() => Slider(
                                min: 1.0,
                                max: 100.0,
                                divisions: 100,
                                value: controller.c.value, onChanged: (v){controller.c.trigger(v.roundToDouble());}, onChangeEnd: (v) => controller.updateData(),))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Obx(() => Text('L: ${controller.l.value.toStringAsFixed(1)}m ')),
                              const SizedBox(width: 16.0,),
                              Obx(() => Slider(
                                min: 1.0,
                                max: 100.0,
                                divisions: 100,
                                value: controller.l.value, onChanged: (v){controller.l.trigger(v.roundToDouble());}, onChangeEnd: (v) => controller.updateData(),))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ];

            return StatefulBuilder(
              builder: (context, ss) {
                return ReorderableWrap(
                  onReorder: (oldIndex, newIndex) {
                    var c = _tiles.removeAt(oldIndex);
                    _tiles.insert(newIndex, c);
                    ss((){});
                  },
                  spacing: spacing,
                  runSpacing: spacing,
                  direction: Axis.horizontal,
                  children: _tiles,
                  scrollPhysics: isLandscape ? null : NeverScrollableScrollPhysics(),
                );
              }
            );
          }
        ),
      ),
    );
  }
}