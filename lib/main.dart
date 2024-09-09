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
  WidgetsFlutterBinding.ensureInitialized();
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
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cow Monitor',
          theme: ThemeData(
            primarySwatch: Colors.green,
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green[600],
              elevation: 0,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.green,
            brightness: Brightness.dark,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.green[600],
              elevation: 0,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MainScreen(
            onToggleDarkMode: provider.toggleDarkMode,
            // onStreamSelected: provider.setCurrentStreamUrl,
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(bool) onToggleDarkMode;
  // final Function(String) onStreamSelected;

  const MainScreen({
    super.key,
    required this.onToggleDarkMode,
    // required this.onStreamSelected,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const HomePage(),
      const SelectCowPage(),
      const BehaviorPage(),
      const TrackingPage(),
      SettingsPage(onToggleDarkMode: widget.onToggleDarkMode),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Select Cow'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Behavior'),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: 'Tracking'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.deepPurple[600]
            : Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
