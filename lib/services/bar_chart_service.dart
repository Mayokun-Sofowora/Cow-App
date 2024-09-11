import 'package:cow_monitor/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cow_monitor/services/cow_service.dart';

class BarChartService {
  bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Widget createBarChart(BuildContext context, List<CowAction> cowActions, String selectedBehavior) {
    bool darkMode = isDarkMode(context);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 60,  // Maximum value for the Y-axis
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final action = cowActions.firstWhere((a) => a.name == selectedBehavior, orElse: () => CowAction('Unknown', 0));
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
        barGroups: _getBarGroupsForSelectedBehavior(cowActions),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroupsForSelectedBehavior(List<CowAction> cowActions) {
    List<BarChartGroupData> barGroups = [];

    // Calculate total time spent
    for (int i = 0; i < cowActions.length; i++) {
      final action = cowActions[i];
      barGroups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: action.timeSpent.toDouble(), // Use time spent for the Y value
            color: _getBarColor(action.name),
            borderRadius: BorderRadius.zero,
          ),
        ],
      ));
    }

    return barGroups;
  }

  Color _getBarColor(String actionName) {
    switch (actionName) {
      case 'Eating':
        return Colors.green;
      case 'Keeping still':
        return Colors.blue;
      case 'Standing':
        return Colors.orange;
      case 'Walking':
        return Colors.red;  
      default:
        return Colors.grey; // Default color for an unknown action
    }
  }
}
