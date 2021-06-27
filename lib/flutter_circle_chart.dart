import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/math/index.dart';

class CircleChartItemData {
  final Color color;
  final double value;
  final String name;
  final String description;

  CircleChartItemData({
    required this.color,
    required this.value,
    required this.name,
    required this.description,
  });
}

enum CircleChartType {
  solid,
  gradient,
  bracelet,
  dots,
}

class CircleChart extends StatefulWidget {
  final Color backgroundColor;
  final Radius borderRadius;
  final EdgeInsets padding;
  final Duration duration;

  final double chartRadius;
  final CircleChartType chartType;
  final double chartStrokeWidth;
  final double chartCircleBackgroundStrokeWidth;

  final Radius labelBorderRadius;
  final EdgeInsets labelPadding;
  final TextStyle labelTextStyle;

  final List<CircleChartItemData> items;
  final EdgeInsets itemPadding;
  final TextStyle itemTextStyle;
  final TextStyle itemDescriptionTextStyle;

  const CircleChart({
    Key? key,
    this.backgroundColor: const Color(0xff32074e),
    this.borderRadius: const Radius.circular(8),
    this.padding: const EdgeInsets.all(12),
    this.chartRadius: 60,
    this.labelPadding: const EdgeInsets.all(12),
    this.labelBorderRadius: const Radius.circular(8),
    this.labelTextStyle: const TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
    this.itemTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    this.itemDescriptionTextStyle: const TextStyle(
      color: Colors.white60,
      fontSize: 10,
    ),
    required this.items,
    this.chartType: CircleChartType.dots,
    this.chartStrokeWidth: 15,
    this.chartCircleBackgroundStrokeWidth: 20,
    this.itemPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.duration: const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  _CircleChartState createState() => _CircleChartState();
}

class _CircleChartState extends State<CircleChart>
    with SingleTickerProviderStateMixin {
  CircleChartItemData? checkedItem;
  late AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: widget.duration);
    animationController.addListener(() {
      setState(() {});
    });
    startAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CircleChart oldWidget) {
    if (oldWidget.items != widget.items) {
      checkedItem = null;
      startAnimation();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.all(widget.borderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPaint(
            painter: CircleChartPainter(
              items: widget.items,
              chartType: widget.chartType,
              chartRadius: widget.chartRadius,
              strokeWidth: widget.chartStrokeWidth,
              circleStrokeWidth: widget.chartCircleBackgroundStrokeWidth,
              animationValue: CurveTween(curve: Curves.easeInOutCirc)
                  .evaluate(animationController),
              checkedItem: checkedItem,
            ),
            size: Size(widget.chartRadius * 2, widget.chartRadius * 2),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: widget.itemPadding.left),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: widget.labelPadding,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(widget.labelBorderRadius),
                        color: checkedItem?.color ?? Colors.black54,
                      ),
                      child: Text(
                        '${(checkedItem != null ? checkedItem!.value : _calculateTotalValue(widget.items)).toStringAsFixed(2)}',
                        style: widget.labelTextStyle,
                      ),
                    ),
                  ],
                ),
                ...widget.items.map((e) => Padding(
                      padding: EdgeInsets.only(top: widget.itemPadding.top),
                      child: _buildItem(e),
                    )),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildItem(CircleChartItemData item) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (checkedItem != item || checkedItem == null) {
            checkedItem = item;
          } else {
            checkedItem = null;
          }
        });
      },
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(widget.borderRadius),
        )),
        padding: MaterialStateProperty.all<EdgeInsets>(widget.itemPadding),
        elevation: MaterialStateProperty.all<double>(0.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: MaterialStateProperty.all<Size>(Size.zero),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.itemTextStyle.fontSize,
                height: widget.itemTextStyle.fontSize,
                decoration: ShapeDecoration(
                  color: item.color,
                  shape: CircleBorder(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: widget.itemPadding.left),
                  child: Text(
                    '${item.value.toStringAsFixed(2)} ${item.name}',
                    style: widget.itemTextStyle,
                  ),
                ),
              ),
            ],
          ),
          if (checkedItem == item)
            Padding(
              padding: EdgeInsets.only(top: widget.itemPadding.top),
              child: Text(
                item.description,
                style: widget.itemDescriptionTextStyle,
              ),
            ),
        ],
      ),
    );
  }

  void startAnimation() {
    animationController.forward(from: 0.1);
  }
}

class CircleChartPainter extends CustomPainter {
  final double chartRadius;
  final List<CircleChartItemData> items;
  final CircleChartType chartType;
  final double strokeWidth;
  final double circleStrokeWidth;
  final double animationValue;
  final CircleChartItemData? checkedItem;

  const CircleChartPainter({
    required this.chartRadius,
    required this.items,
    required this.chartType,
    required this.strokeWidth,
    required this.circleStrokeWidth,
    this.animationValue: 1.0,
    this.checkedItem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = chartRadius - circleStrokeWidth * 0.5;
    final totalValue = _calculateTotalValue(items);
    // final count = items.length;
    final totalRad = animationValue * 2 * math.pi;
    double startAngle = 0;

    /// draw circle background
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.black54
          ..strokeWidth = circleStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke);

    /// draw arc items
    switch (chartType) {
      case CircleChartType.bracelet:
        startAngle = (totalRad * items.first.value / totalValue);
        for (var i = 0; i < items.length; ++i) {
          var item = items[i];
          var sweepAngle = (totalRad * item.value / totalValue);
          canvas.drawArc(
              Rect.fromCircle(center: center, radius: radius),
              startAngle,
              sweepAngle,
              false,
              Paint()
                ..strokeWidth = strokeWidth * (checkedItem == item ? 1.5 : 1)
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..style = PaintingStyle.stroke
                ..shader = ui.Gradient.radial(
                  center,
                  radius,
                  [
                    item.color.darker,
                    item.color,
                  ],
                  [0.9, 1.0],
                )
              //
              );
          startAngle += sweepAngle;
        }
        break;
      case CircleChartType.gradient:
        startAngle = (totalRad * items.first.value / totalValue);
        for (var i = 1; i < items.length; ++i) {
          var item = items[i];
          var sweepAngle = totalRad * item.value / totalValue;
          canvas.drawArc(
              Rect.fromCircle(center: center, radius: radius),
              startAngle,
              sweepAngle,
              false,
              Paint()
                ..strokeWidth = strokeWidth * (checkedItem == item ? 1.5 : 1)
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..style = PaintingStyle.stroke
                ..shader = ui.Gradient.sweep(
                  center,
                  [
                    item.color,
                    item.color.darker,
                  ],
                  [0.0, 1.0],
                  TileMode.clamp,
                  startAngle,
                  startAngle + sweepAngle,
                )
              //
              );
          startAngle += sweepAngle;
        }
        startAngle = 0;
        var item = items.first;
        var sweepAngle = ((totalRad) * item.value / totalValue);
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle,
            false,
            Paint()
              ..strokeWidth = strokeWidth * (checkedItem == item ? 1.5 : 1)
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..style = PaintingStyle.stroke
              ..color = item.color
            //
            );
        break;
      case CircleChartType.dots:
        var totalDots = ((totalRad * radius) / (strokeWidth * 1.5)).round();
        totalDots = totalDots + 3 - totalDots % 3;
        // print('CircleChartPainter.paint: totalDots=$totalDots');
        var startPoint = Offset(center.dx + radius, center.dy);
        Offset c = startPoint;
        // var totalDots = 18;
        var totalCount = 0;
        for (var item in items) {
          var percent = item.value / totalValue;
          late int count;
          if (item == items.last) {
            count = totalDots - totalCount;
          } else {
            count = (percent * totalDots).round();
          }

          // print(
          //     'CircleChartPainter.paint: ${item.value.toStringAsFixed(2)} ~ $percent ~ $count dots');
          final da = totalRad / totalDots;
          for (var i = 0; i < count; ++i) {
            canvas.drawCircle(
                c,
                strokeWidth * 0.5 * (checkedItem == item ? 1.5 : 1),
                Paint()
                  ..color = item.color
                  ..style = PaintingStyle.fill
                //
                );
            c = c.rotate(center, da);
          }
          totalCount += count;
        }
        break;
      case CircleChartType.solid:
      default:
        for (var item in items) {
          var sweepAngle = (totalRad * item.value / totalValue);
          canvas.drawArc(
              Rect.fromCircle(center: center, radius: radius),
              startAngle,
              sweepAngle,
              false,
              Paint()
                ..color = item.color
                ..strokeWidth = strokeWidth * (checkedItem == item ? 1.5 : 1)
                ..strokeCap = StrokeCap.round
                ..strokeJoin = StrokeJoin.round
                ..style = PaintingStyle.stroke);
          startAngle += sweepAngle;
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

double _calculateTotalValue(List<CircleChartItemData> items) {
  double a = 0;
  for (var item in items) {
    a += item.value;
  }
  return a;
}

extension _ColorEx on Color {
  get darker => Color.alphaBlend(this.withOpacity(0.5), Colors.black);
}

extension _OffsetEx on Offset {
  Offset rotate(Offset center, double alphaRad) {
    if (alphaRad == double.infinity || alphaRad == double.negativeInfinity)
      return this;
    // print('rotate: $center, $alphaRad');
    AffineTransform t = AffineTransform.identity();
    var p = Point(dx, dy);
    t
      ..rotate(alphaRad * kRadToDeg, Point(center.dx, center.dy))
      ..apply(p);
    var res = Offset(p.x, p.y);
    // print('rotate: res=$res');
    return res;
  }
}
