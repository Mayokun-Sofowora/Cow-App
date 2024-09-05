import 'package:cow_monitor/services/cow_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/provider_service.dart';
import 'pages/home_page.dart';
import 'pages/behavior_page.dart';
import 'pages/select_cow_page.dart';
import 'pages/settings_page.dart';
import 'pages/tracking_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CowProvider()),
        Provider(create: (_) => CowRepository()),
      ],
      child: const CowMonitor(),
    ),
  );
}

class CowMonitor extends StatelessWidget {
  const CowMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CowProvider>(
      // Update Consumer type to CowProvider
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cow Monitor',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          themeAnimationDuration: Duration.zero,
          home: Screen(
            onToggleDarkMode: provider.toggleDarkMode,
            currentStreamUrl: provider.currentStreamUrl,
            onStreamSelected: provider.setCurrentStreamUrl,
            videoTimestamp: 1724093350, // Change the video timestamp later
          ),
        );
      },
    );
  }
}

class Screen extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  final String currentStreamUrl;
  final Function(String) onStreamSelected;
  final int videoTimestamp;

  const Screen({
    super.key,
    required this.onToggleDarkMode,
    required this.currentStreamUrl,
    required this.onStreamSelected,
    required this.videoTimestamp,
  });

  @override
  ScreenState createState() => ScreenState();
}

class ScreenState extends State<Screen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pages = [
      {
        'title': const Text('Home Screen'),
        'page': HomePage(
            videoUrl: widget.currentStreamUrl,
            timestamp: widget.videoTimestamp),
      },
      {
        'title': const Text('Select Cow'),
        'page': const SelectCowPage(),
      },
      {
        'title': const Text('Behavior Records'),
        'page': const BehaviorPage(),
      },
      {
        'title': const Text('Movement Tracking'),
        'page': const TrackingPage(),
      },
      {
        'title': const Text('Settings'),
        'page': SettingsPage(
          onToggleDarkMode: widget.onToggleDarkMode,
          currentStreamUrl: widget.currentStreamUrl,
        ),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cow Monitor',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.green[800],
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: pages[_selectedIndex]['page'],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Select Cow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Behavior',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.lightGreen[100],
        selectedItemColor: Colors.green[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
