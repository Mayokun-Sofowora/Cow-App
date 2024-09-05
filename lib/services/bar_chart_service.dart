import 'package:cow_monitor/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cow_monitor/services/cow_service.dart';

class BarChartService {
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget createBarChart(BuildContext context, List<CowAction> cowActions,
      String selectedBehavior) {
    bool darkMode = isDarkMode(context);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 60, // Adjusted for maximum Y value
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              // Create a tooltip for the selected behavior
              final action =
                  cowActions.firstWhere((a) => a.name == selectedBehavior);
              return BarTooltipItem(
                '${action.name}\n${TimeUtils.formatTimeSpent(rod.toY.toInt())}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              'Hours',
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(
              'Minutes',
              style: TextStyle(
                color: darkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        barGroups:
            _getBarGroupsForSelectedBehavior(cowActions, selectedBehavior),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroupsForSelectedBehavior(
      List<CowAction> cowActions, String selectedBehavior) {
    List<BarChartGroupData> barGroups = [];

    final action = cowActions.firstWhere((a) => a.name == selectedBehavior);

    // Calculate the total time spent
    final totalTimeSpent = action.timeSpent;
    // Generate accumulated minutes for each 4-hour period
    for (int hour = 0; hour < 24; hour += 2) {
      // Calculate minutes for this 4-hour period (distribute time evenly)
      final minutesForPeriod = (totalTimeSpent / 4).round();

      barGroups.add(BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            color: Colors.deepPurple,
            fromY: 0,
            toY: minutesForPeriod.toDouble(),
            borderRadius: BorderRadius.circular(0),
          ),
        ],
      ));
    }
    return barGroups;
  }
}
