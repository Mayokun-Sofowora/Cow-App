import 'package:cow_monitor/services/bar_chart_service.dart';
import 'package:cow_monitor/services/pie_chart_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/provider_service.dart';
import 'package:cow_monitor/services/cow_repository.dart';
import 'package:cow_monitor/services/cow_service.dart';

class BehaviorPage extends StatefulWidget {
  const BehaviorPage({super.key});

  @override
  BehaviorPageState createState() => BehaviorPageState();
}

class BehaviorPageState extends State<BehaviorPage> {
    
  String _chartType = 'Pie'; // Default chart type
  String? _selectedBehavior; // Track selected behavior
  List<CowAction> _cowActions = []; // Store cow actions
  final CowService _cowService = CowService();
  final PieChartService _pieChartService = PieChartService();
  final BarChartService _barChartService = BarChartService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCow = Provider.of<CowProvider>(context).selectedCow;
    final selectedCowId = Provider.of<CowProvider>(context).selectedCowId;
    final startTimestamp = Provider.of<CowProvider>(context).startTimestamp;
    final endTimestamp = Provider.of<CowProvider>(context).endTimestamp;

    if (selectedCow == null ||
        selectedCowId == null ||
        startTimestamp == null ||
        endTimestamp == null) {
      return const Center(child: Text('No cow or time range selected'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Behavior Record'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Select Chart Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart, color: Colors.green),
              title: const Text(
                'Pie Chart Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  _chartType = 'Pie';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.blue),
              title: const Text(
                'Bar Chart Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                setState(() {
                  _chartType = 'Bar';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Selected Cow ID: $selectedCowId',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateTime.fromMillisecondsSinceEpoch(startTimestamp.millisecondsSinceEpoch).toLocal()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.green[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateTime.fromMillisecondsSinceEpoch(endTimestamp.millisecondsSinceEpoch).toLocal()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dropdown for behavior is only visible for Bar Chart
              _chartType == 'Bar'
                  ? DropdownButton<String>(
                      hint: const Text("Select Behavior"),
                      value: _selectedBehavior,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBehavior = newValue;
                        });
                      },
                      items: _cowActions
                          .map<DropdownMenuItem<String>>((CowAction action) {
                        return DropdownMenuItem<String>(
                          value: action.name,
                          child: Text(action.name),
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(), // Hide dropdown for Pie Chart
              const SizedBox(height: 16),
              FutureBuilder<List<Cow>>(
                future: _cowService.fetchCowsDataForSelectedCow(
                    selectedCowId, startTimestamp, endTimestamp),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No data available for this cow.'));
                  } else {
                    final cowData = snapshot.data!;
                    _cowActions = _cowService.processCowData(cowData);
                    // Create a map for PieChart data
                    final Map<String, double> pieChartData = {};
                    for (final action in _cowActions) {
                      pieChartData[action.name] = action.timeSpent.toDouble();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height:
                              400, // Ensure the charts have a defined height
                          child: _chartType == 'Pie'
                              ? _pieChartService.createPieChart(
                                  _cowActions, context)
                              : _selectedBehavior != null
                                  ? _barChartService.createBarChart(
                                    context, _cowActions, _selectedBehavior!)
                                  : const Center(
                                      child: Text(
                                          'Please select a behavior to display the bar chart'),
                                    ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
