import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: Color(0xff4C2882),
        appBar: AppBar(
          title: Text('Flutter Circle Chart'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: List.generate(
              CircleChartType.values.length,
              (index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${CircleChartType.values[index]}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CircleChart(
                      chartType: CircleChartType.values[index],
                      items: List.generate(
                        3,
                        (index) => CircleChartItemData(
                          color: randomColor(),
                          value: 100 + Random.secure().nextDouble() * 1000,
                          name: 'Lorem Ipsum $index',
                          description:
                              'Lorem Ipsum $index không phải chỉ là một đoạn văn bản ngẫu nhiên.',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color randomColor() {
  var g = math.Random.secure().nextInt(255);
  var b = math.Random.secure().nextInt(255);
  var r = math.Random.secure().nextInt(255);
  return Color.fromARGB(255, r, g, b);
}
