import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/provider_service.dart';
import 'package:cow_monitor/services/cow_repository.dart';

class SelectCowPage extends StatefulWidget {
  const SelectCowPage({super.key});

  @override
  SelectCowPageState createState() => SelectCowPageState();
}

class SelectCowPageState extends State<SelectCowPage> {
  List<Cow> _cows = []; // To store the cow data retrieved
  List<int> _cowIds = []; // To store the available cow IDs
  bool _isLoading = false; // To show loading status
  String _errorMessage = ''; // To store error messages

  final CowRepository _cowRepository = CowRepository(); // Repository instance
  DateTime? _startDateTime; // Start time for data fetching
  DateTime? _endDateTime; // End time for data fetching
  int? _selectedCowId; // Selected cow ID

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final cowProvider = Provider.of<CowProvider>(context, listen: false);
    setState(() {
      _selectedCowId = cowProvider.selectedCowId;
      _startDateTime = cowProvider.startTimestamp;
      _endDateTime = cowProvider.endTimestamp;
    });
    if (_selectedCowId != null &&
        _startDateTime != null &&
        _endDateTime != null) {
      _fetchCowsData();
    }
  }

  // Fetch available cow IDs based on selected date and time
  Future<void> _fetchCowIds() async {
    if (_startDateTime == null || _endDateTime == null) {
      setState(() {
        _errorMessage = 'Please select both start and end date and time.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _cowIds = []; // Reset cow IDs
    });

    try {
      // Convert DateTime to Unix timestamps
      int startTimestamp = _startDateTime!.millisecondsSinceEpoch ~/ 1000;
      int endTimestamp = _endDateTime!.millisecondsSinceEpoch ~/ 1000;

      // Fetch cow IDs for the provided timestamp range
      List<int> ids =
          await _cowRepository.fetchCowIds(startTimestamp, endTimestamp);

      if (mounted) {
        setState(() {
          _cowIds = ids;
          _isLoading = false;
          if (ids.isEmpty) {
            _errorMessage = 'No cows found for the selected time range';
          }
        });
      }else {
          // Store the selected cow in the provider
          _selectedCowId = ids.first; // Automatically select the first available cow ID
          Provider.of<CowProvider>(context, listen: false)
              .setSelectedTimeRange(_startDateTime!, _endDateTime!);
        }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Fetch cow data for the selected cow ID
  Future<void> _fetchCowsData() async {
    if (_selectedCowId == null) {
      setState(() {
        _errorMessage = 'Please select a cow ID.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Convert DateTime to Unix timestamps
      int startTimestamp = _startDateTime!.millisecondsSinceEpoch ~/ 1000;
      int endTimestamp = _endDateTime!.millisecondsSinceEpoch ~/ 1000;

      // Fetch cow data for the selected cow ID
      List<Cow> cows = await _cowRepository.fetchCowData(
        startTimestamp,
        endTimestamp,
        _selectedCowId!,
      );

      if (mounted) {
        setState(() {
          _cows = cows; // Assign the list of cows to the state variable
          _isLoading = false;
          if (cows.isEmpty) {
            _errorMessage = 'No cows found for the selected time range';
          }
        });
      }
      if (cows.isNotEmpty) {
        // Store the selected cow and time range in the provider
        Provider.of<CowProvider>(context, listen: false)
            .selectCow(cows.first, _selectedCowId!);
        Provider.of<CowProvider>(context, listen: false)
            .setSelectedTimeRange(_startDateTime!, _endDateTime!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Select the start date and time
  Future<void> _selectStartDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (!mounted) return; // Check if widget is still mounted

    if (pickedDate != null && pickedDate != _startDateTime) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startDateTime ?? DateTime.now()),
      );

      if (!mounted) return; // Check if widget is still mounted

      if (pickedTime != null) {
        setState(() {
          _startDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Select the end date and time
  Future<void> _selectEndDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (!mounted) return; // Check if widget is still mounted

    if (pickedDate != null && pickedDate != _endDateTime) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endDateTime ?? DateTime.now()),
      );

      if (!mounted) return; // Check if widget is still mounted

      if (pickedTime != null) {
        setState(() {
          _endDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Cow'),
        ),
        body: Consumer<CowProvider>(builder: (context, cowProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _selectStartDateTime,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: _startDateTime == null
                            ? 'Start Date & Time'
                            : '${'Start: ${_startDateTime!.toLocal()}'.split(' ')[0]} ${_startDateTime!.hour}:${_startDateTime!.minute.toString().padLeft(2, '0')}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _selectEndDateTime,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: _endDateTime == null
                            ? 'End Date & Time'
                            : '${'End: ${_endDateTime!.toLocal()}'.split(' ')[0]} ${_endDateTime!.hour}:${_endDateTime!.minute.toString().padLeft(2, '0')}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _fetchCowIds,
                child: const Text('Fetch Cow IDs'),
              ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage.isNotEmpty)
                Center(child: Text(_errorMessage))
              else ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select Cow ID:'),
                ),
                DropdownButton<int>(
                  hint: const Text('Select a cow ID'),
                  value: _selectedCowId,
                  onChanged: (int? newValue) {
                    if (mounted) {
                      setState(() {
                        _selectedCowId = newValue;
                        _cows = []; // Clear previous cow data
                        _errorMessage = ''; // Reset error message
                      });
                    }
                  },
                  items: _cowIds.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('Cow ID: $value'),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _fetchCowsData,
                  child: const Text('Fetch Cow Data'),
                ),
              ],
              if (_cows.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Selected Cow Data:'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cows.length,
                    itemBuilder: (context, index) {
                      final cow = _cows[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 5,
                        color: Colors.lightBlue[50], // Light blue background
                        child: ListTile(
                          title: Text(
                            'Coordinates: (${cow.x}, ${cow.y}), \nWidth: ${cow.w}, \nHeight: ${cow.h}, \nAction: ${cow.action}, \nTimestamp: ${cow.timestamp}', // Complete details
                            style: TextStyle(
                                color:
                                    Colors.grey[700]), // Grey text for subtitle
                          ),
                          onTap: () {
                            _showCowDetails(cow); // Show cow details on tap
                          },
                        ),
                      );
                    },
                  ),
                ),
              ]
            ],
          );
        }));
  }

  // Show details for a selected cow
  void _showCowDetails(Cow cow) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cow Details'),
          content: Text('Coordinates: (${cow.x}, ${cow.y})\n'
              'Width: ${cow.w}\n'
              'Height: ${cow.h}\n'
              'Action: ${cow.action}\n'
              'Timestamp: ${cow.timestamp}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
