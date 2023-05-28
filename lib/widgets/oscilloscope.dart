// Copyright (c) 2018-2021, Steve Rogers. All rights reserved. Use of this source code
// is governed by an Apache License 2.0 that can be found in the LICENSE file.
library oscilloscope;

import 'package:flutter/material.dart';

/// A widget that defines a customisable Oscilloscope type display that can be used to graph out data
///
/// The [dataSet] arguments MUST be a List<double> -  this is the data that is used by the display to generate a trace
///
/// All other arguments are optional as they have preset values
///
/// [showYAxis] this will display a line along the yAxis at 0 if the value is set to true (default is false)
/// [yAxisColor] determines the color of the displayed yAxis (default value is Colors.white)
///
/// [yAxisMin] and [yAxisMax] although optional should be set to reflect the data that is supplied in [dataSet]. These values
/// should be set to the min and max values in the supplied [dataSet].
///
/// For example if the max value in the data set is 2.5 and the min is -3.25  then you should set [yAxisMin] = -3.25 and [yAxisMax] = 2.5
/// This allows the oscilloscope display to scale the generated graph correctly.
///
/// You can modify the background color of the oscilloscope with the [backgroundColor] argument and the color of the trace with [traceColor]
///
/// The [margin] argument allows space to be set around the display (this defaults to EdgeInsets.all(10.0) if not specified)
///
/// The [strokeWidth] argument defines how wide to make lines drawn (this defaults to 2.0 if not specified).
///
/// NB: This is not a Time Domain trace, the update frequency of the supplied [dataSet] determines the trace speed.
class Oscilloscope extends StatefulWidget {
  final List<List<num>> dataSets;
  final double yAxisMin;
  final double yAxisMax;
  final double padding;
  final Color backgroundColor;
  final List<Color> traceColors;
  final Color yAxisColor;
  final bool showYAxis;
  final double xScale;
  final double strokeWidth;
  final EdgeInsetsGeometry margin;
  final void Function()? onNewViewport;

  Oscilloscope(
      {required this.traceColors,
      this.backgroundColor = Colors.black,
      this.yAxisColor = Colors.white,
      @Deprecated("Use 'margin' instead") this.padding = 10.0,
      this.margin = const EdgeInsets.all(10.0),
      this.yAxisMax = 1.0,
      this.yAxisMin = 0.0,
      this.showYAxis = false,
        this.xScale = 1.0,
      this.strokeWidth = 2.0,
      this.onNewViewport,
      required this.dataSets});

  @override
  _OscilloscopeState createState() => _OscilloscopeState();
}

class _OscilloscopeState extends State<Oscilloscope> {

  double offset = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.dataSets.isNotEmpty && widget.dataSets.first.isNotEmpty) {
        if (offset >= widget.dataSets.first.length - 1) {
          offset = widget.dataSets.first.length.toDouble() - 1;
        }
        if (offset < 0) {
          offset = 0;
        }
    }
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (widget.dataSets.isNotEmpty && widget.dataSets.first.isNotEmpty) {
          setState(() {
            offset -= details.primaryDelta ?? 0.0;
          if (offset >= widget.dataSets.first.length - 1) {
            offset = widget.dataSets.first.length.toDouble() - 1;
          }
          if (offset < 0) {
              offset = 0;
          }
          });
        }
      },
      child: Container(
        padding: widget.margin,
        width: double.infinity,
        height: double.infinity,
        color: widget.backgroundColor,
        child: ClipRect(
          child: CustomPaint(
              painter: _TracePainter(
                xScale: widget.xScale,
            showYAxis: widget.showYAxis,
            yAxisColor: widget.yAxisColor,
            dataSets: widget.dataSets.map((e) => e.sublist(offset.floor())).toList(),
            traceColors: widget.traceColors,
            yMin: widget.yAxisMin,
            yMax: widget.yAxisMax,
            strokeWidth: widget.strokeWidth,
            onNewViewport: widget.onNewViewport,
          )),
        ),
      ),
    );
  }
}

/// A Custom Painter used to generate the trace line from the supplied dataset
class _TracePainter extends CustomPainter {
  final List<List<num>> dataSets;
  final double xScale;
  final double yMin;
  final double yMax;
  late List<Color> traceColors;
  final Color? yAxisColor;
  final bool showYAxis;
  final double? strokeWidth;
  final void Function()? onNewViewport;
  late List<Paint> _tracePaints;
  final Paint _axisPaint;

  _TracePainter(
      {required this.showYAxis,
      this.yAxisColor,
      required this.yMin,
      required this.yMax,
      required this.dataSets,
      this.xScale = 1.0,
      this.strokeWidth,
      this.onNewViewport,
      List<Color>? traceColors}) : _axisPaint = Paint()
    ..strokeWidth = 1.0
    ..color = yAxisColor! {
    this.traceColors = traceColors ?? [Colors.white];
    _tracePaints = this.traceColors.map((e) => Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth!
      ..color = e
      ..style = PaintingStyle.stroke).toList();
  }


  double _scale(double newMax, double newMin, {required num value}) {
    final double oldRange = yMax - yMin;
    if (oldRange == 0) return newMin;

    final double newRange = newMax - newMin;
    return (((value - yMin) * newRange) / oldRange) + newMin;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // only start plot if dataset has data

    for (var i = 0; i < dataSets.length; i++) {
      final dataSet = dataSets[i];

      if (showYAxis) {
        final double yOrigin = _scale(0, size.height, value: 0);
        final Offset yStart = Offset(0, yOrigin);
        final Offset yEnd = Offset(size.width, yOrigin);
        canvas.drawLine(yStart, yEnd, _axisPaint);
        // canvas.drawLine(Offset(0, yOrigin - size.height/4), Offset(size.width, yOrigin - size.height/4), _axisPaint);
        // canvas.drawLine(Offset(0, yOrigin + size.height/4), Offset(size.width, yOrigin + size.height/4), _axisPaint);
        // canvas.drawLine(Offset(0, yOrigin - size.height/2 + 1), Offset(size.width, yOrigin - size.height/2 + 1), _axisPaint);
        // canvas.drawLine(Offset(0, yOrigin + size.height/2 - 1), Offset(size.width, yOrigin + size.height/2 - 1), _axisPaint);
      }

      int length = dataSet.length;
      if (length > 0) {
        // transform data set to just what we need if bigger than the width(otherwise this would be a memory hog)
        // if (length > size.width) {
        //   // dataSet.removeAt(0);
        //   dataSet.removeLast();
        //   length = dataSet.length;
        //   onNewViewport?.call();
        // }

        // Create Path and set Origin to first data point
        final Path trace = Path();
        trace.moveTo(0, _scale(0, size.height, value: dataSet[0]));

        // generate trace path
        for (int p = 0; p < length; p++) {
          final double plotPoint = _scale(0, size.height, value: dataSet[p]);
          trace.lineTo(p.toDouble() * xScale, plotPoint);
        }

        // display the trace
        canvas.drawPath(trace, _tracePaints[i]);

        // if yAxis required draw it here
      }
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
