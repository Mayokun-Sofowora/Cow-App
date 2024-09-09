import 'package:cow_monitor/pages/notifications_page.dart';
import 'package:cow_monitor/pages/profile_page.dart';
import 'package:cow_monitor/pages/support_page.dart';
import 'package:cow_monitor/services/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  final Function(bool) onToggleDarkMode;

  const SettingsPage({
    super.key,
    required this.onToggleDarkMode,
  });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  // String get selectedStreamUrl {
  //   final provider = Provider.of<CowProvider>(context, listen: false);
  //   return provider.currentStreamUrl;
  // }

  // void _showStreamSelectionDialog(BuildContext context, CowProvider provider) {
  //   int? selectedStreamIndex = provider.streams.indexWhere((stream) =>
  //       stream['url'] == provider.currentStreamUrl);
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Select Stream'),
  //         content: SizedBox(
  //           height: 200,
  //           width: 300,
  //           child: ListView.builder(
  //             itemCount: provider.streams.length,
  //             itemBuilder: (context, index) {
  //               return RadioListTile<int>(
  //                 title: Text(provider.streams[index]['name']!),
  //                 value: index,
  //                 groupValue: selectedStreamIndex,
  //                 onChanged: (value) {
  //                   if (value != null) {
  //                     provider.setCurrentStreamUrl(provider.streams[value]['url']!);
  //                     Navigator.of(context).pop();
  //                   }
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CowProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.live_tv),
          //   title: const Text('Cow Stream'),
          //   onTap: () {
          //     _showStreamSelectionDialog(context, provider);
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsPage()),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: provider.isDarkMode,
            onChanged: (bool value) {
              widget.onToggleDarkMode(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Backup & Restore'),
                    content: const Text(
                        'Backup & restore functionality not implemented yet.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HelpSupportPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About App'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('About App'),
                    content: const Text(
                        'This app was made during a practice placement while studying at the Silesian University of Technology.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
