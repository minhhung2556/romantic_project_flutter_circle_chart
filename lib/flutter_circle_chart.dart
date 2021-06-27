import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// const _kDegToRad = math.pi / 180.0;
// const _kRadToDeg = 180.0 / math.pi;
const _kTotalRad = 2 * math.pi;
const _kSelectedItemFactor = 1.3;

/// The data is used to draw the [CircleChart]
/// Each item has [CircleChartItemData.value] and the [CircleChart] will calculate total value itself and display as a label.
class CircleChartItemData {
  /// [color] : color to draw.
  final Color color;

  /// [value] : value to calculate its part of the [CircleChart].
  final double value;

  /// [name] : is used to call each item.
  final String name;

  /// [description] : Item description is used to describe more details each item.
  final String description;

  /// Constructor
  CircleChartItemData({
    required this.color,
    required this.value,
    required this.name,
    required this.description,
  });
}

/// Drawing types of [CircleChart]
/// [CircleChartType.solid] draws items in solid colors.
/// [CircleChartType.gradient] draws items in gradients from their [CircleChartItemData.color] darker to their origin color.
/// [CircleChartType.bracelet] like as gradient, but it come from the center, make the chart like a bracelet.
/// [CircleChartType.dots] draws items in dots with their [CircleChartItemData.color].
enum CircleChartType {
  solid,
  gradient,
  bracelet,
  dots,
}

/// Help you create a Circle Chart that is used to display some kinds of reports.
class CircleChart extends StatefulWidget {
  /// [backgroundColor] : the background of whole widget.
  final Color backgroundColor;

  /// [borderRadius] : the border radius of whole widget.
  final Radius borderRadius;

  /// [padding] : the padding of whole widget.
  final EdgeInsets padding;

  /// [duration] : use for the animation, triggered whenever the [items] changes or not by [animationOnItemsChanged].
  final Duration duration;
  final bool animationOnItemsChanged;

  /// [chartRadius] : radius to draw the circle.
  final double chartRadius;

  /// [chartType] : drawing type. See all [CircleChartType].
  final CircleChartType chartType;

  /// [chartStrokeWidth] : stroke width of the item value circle.
  final double chartStrokeWidth;

  /// [chartCircleBackgroundStrokeWidth] : stroke width of the dark circle behind the item value circle.
  final double chartCircleBackgroundStrokeWidth;

  /// See [labelTextStyle]
  final Radius labelBorderRadius;

  /// See [labelTextStyle]
  final EdgeInsets labelPadding;

  /// The label is used to show the total value and selected item value to focus on. [labelTextStyle] is used for Text. [labelBorderRadius] & [labelPadding] are used for the label background.
  final TextStyle labelTextStyle;

  /// [items] : is the data to draw.
  final List<CircleChartItemData> items;

  /// [itemPadding] : is the padding of each item placed at the right.
  final EdgeInsets itemPadding;

  /// [itemTextStyle] : is the text style of each item placed at the right.
  final TextStyle itemTextStyle;

  /// [itemDescriptionTextStyle] : is the text style of description label of each item placed at the bottom of item label.
  final TextStyle itemDescriptionTextStyle;

  /// Create an CircleChart. It has a default style.
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
    this.animationOnItemsChanged: true,
  }) : super(key: key);

  @override
  _CircleChartState createState() => _CircleChartState();
}

class _CircleChartState extends State<CircleChart>
    with SingleTickerProviderStateMixin {
  CircleChartItemData? _selectedItem;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _animationController.addListener(() {
      setState(() {});
    });
    _startAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CircleChart oldWidget) {
    if (widget.animationOnItemsChanged) {
      if (oldWidget.items != widget.items) {
        _selectedItem = null;
        _startAnimation();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            painter: _CircleChartPainter(
              items: widget.items,
              chartType: widget.chartType,
              chartRadius: widget.chartRadius,
              strokeWidth: widget.chartStrokeWidth,
              circleStrokeWidth: widget.chartCircleBackgroundStrokeWidth,
              animationValue: CurveTween(curve: Curves.easeInOutCirc)
                  .evaluate(_animationController),
              selectedItem: _selectedItem,
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
                        color: _selectedItem?.color ?? Colors.black54,
                      ),
                      child: Text(
                        '${(_selectedItem != null ? _selectedItem!.value : _calculateTotalValue(widget.items)).toStringAsFixed(2)}',
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
          if (_selectedItem != item || _selectedItem == null) {
            _selectedItem = item;
          } else {
            _selectedItem = null;
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
          if (_selectedItem == item)
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

  void _startAnimation() {
    _animationController.forward(from: 0.1);
  }
}

class _CircleChartPainter extends CustomPainter {
  final double chartRadius;
  final List<CircleChartItemData> items;
  final CircleChartType chartType;
  final double strokeWidth;
  final double circleStrokeWidth;
  final double animationValue;
  final CircleChartItemData? selectedItem;

  const _CircleChartPainter({
    required this.chartRadius,
    required this.items,
    required this.chartType,
    required this.strokeWidth,
    required this.circleStrokeWidth,
    this.animationValue: 1.0,
    this.selectedItem,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = chartRadius - circleStrokeWidth * 0.5;
    final totalValue = _calculateTotalValue(items);
    // final count = items.length;
    final totalRad = animationValue * _kTotalRad;
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
                ..strokeWidth = strokeWidth *
                    (selectedItem == item ? _kSelectedItemFactor : 1)
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
                ..strokeWidth = strokeWidth *
                    (selectedItem == item ? _kSelectedItemFactor : 1)
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
              ..strokeWidth = strokeWidth *
                  (selectedItem == item ? _kSelectedItemFactor : 1)
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
                strokeWidth *
                    0.5 *
                    (selectedItem == item ? _kSelectedItemFactor : 1),
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
                ..strokeWidth = strokeWidth *
                    (selectedItem == item ? _kSelectedItemFactor : 1)
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

/// calculate total value
double _calculateTotalValue(List<CircleChartItemData> items) {
  double a = 0;
  for (var item in items) {
    a += item.value;
  }
  return a;
}

extension _ColorEx on Color {
  /// build a color darker from its origin.
  get darker => Color.alphaBlend(this.withOpacity(0.5), Colors.black);
}

extension _OffsetEx on Offset {
  /// rotate a point by a [alphaRad] around a circle that has the [center] point.
  Offset rotate(Offset center, double alphaRad) {
    if (alphaRad == double.infinity || alphaRad == double.negativeInfinity)
      return this;
    // print('rotate: $center, $alphaRad');
    var matrix = Matrix4.identity()..translate(-center.dx, -center.dy);
    var p = MatrixUtils.transformPoint(matrix, this);
    matrix = Matrix4.identity()..rotateZ(alphaRad);
    p = MatrixUtils.transformPoint(matrix, p);
    matrix = Matrix4.identity()..translate(center.dx, center.dy);
    p = MatrixUtils.transformPoint(matrix, p);
    return p;
  }
}
