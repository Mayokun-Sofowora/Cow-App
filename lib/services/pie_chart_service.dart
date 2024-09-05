import 'package:cow_monitor/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pie_chart;
import 'package:cow_monitor/services/cow_service.dart';

class PieChartService {
  Widget createPieChart(List<CowAction> cowActions, BuildContext context) {
    final Map<String, double> pieChartData = {};
    for (final action in cowActions) {
      pieChartData[action.name] = action.timeSpent.toDouble();
    }

    return Column(
      children: [
        Expanded(
          child: pie_chart.PieChart(
            dataMap: pieChartData,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 32,
            chartRadius: MediaQuery.of(context).size.width / 2,
            colorList: const [
              Colors.blue,
              Colors.red,
              Colors.green,
              Colors.yellow,
              Colors.orange,
              Colors.purple,
            ],
            initialAngleInDegree: 0,
            chartType: pie_chart.ChartType.disc,
            legendOptions: const pie_chart.LegendOptions(
              legendPosition: pie_chart.LegendPosition.left,
              showLegends: true,
              legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            chartValuesOptions: const pie_chart.ChartValuesOptions(
              showChartValues: true,
              showChartValuesInPercentage: true,
              decimalPlaces: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...cowActions.map((action) {
          return ListTile(
            title: Text(action.name),
            trailing: Text(TimeUtils.formatTimeSpent(action.timeSpent)),
          );
        }),
      ],
    );
  }
}