import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AQI Graph")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(1, 2),
                  FlSpot(2, 3),
                  FlSpot(3, 4),
                  FlSpot(4, 3),
                  FlSpot(5, 2),
                ],
                isCurved: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}