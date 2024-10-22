import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../util/colors.dart';

class ChartComponent extends StatelessWidget {
  final List<FlSpot> data;
  final List<String> weekDays;

  const ChartComponent({super.key, required this.data, required this.weekDays});

  @override
  Widget build(BuildContext context) {
    final reversedData = data.map((spot) => FlSpot((weekDays.length - 1) - spot.x, spot.y)).toList();
    final reversedWeekDays = weekDays.reversed.toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenChart(data: reversedData, weekDays: reversedWeekDays),
          ),
        );
      },
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < reversedWeekDays.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          reversedWeekDays[index],
                          style: const TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  interval: 1,
                ),
              ),
            ),
            minX: 0,
            maxX: weekDays.length - 1.toDouble(),
            minY: 0,
            maxY: data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1, // Adjust maxY dynamically
            lineBarsData: [
              LineChartBarData(
                spots: reversedData,
                isCurved: true,
                barWidth: 4,
                color: AppColors.buttonColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenChart extends StatelessWidget {
  final List<FlSpot> data;
  final List<String> weekDays;

  const FullScreenChart({super.key, required this.data, required this.weekDays});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < weekDays.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          weekDays[index],
                          style: const TextStyle(
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  interval: 1,
                ),
              ),
            ),
            minX: 0,
            maxX: weekDays.length - 1.toDouble(),
            minY: 0,
            maxY: data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1, // Adjust maxY dynamically
            lineBarsData: [
              LineChartBarData(
                spots: data,
                isCurved: true,
                barWidth: 4,
                color: AppColors.buttonColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
