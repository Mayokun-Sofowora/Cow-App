import 'package:cow_monitor/pages/notifications_page.dart';
import 'package:cow_monitor/pages/profile_page.dart';
import 'package:cow_monitor/pages/support_page.dart';
import 'package:cow_monitor/services/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  final Function(bool) onToggleDarkMode;
  final String currentStreamUrl;

  SettingsPage({
    super.key,
    required this.onToggleDarkMode,
    required this.currentStreamUrl,
  });

  // List of streams
  final List<Map<String, String>> streams = [
    {
      'name': 'Stream Video',
      'url': 'http://140.116.86.242:25582/stream_video'
    },
    {
      'name': 'Pixel Video',
      'url': 'https://videos.pexels.com/video-files/856065/856065-hd_1920_1080_30fps.mp4'
    },
  ];

  void _showStreamSelectionDialog(BuildContext context, CowProvider provider) {
    int? selectedStreamIndex;

    // Find the currently selected stream index
    for (int i = 0; i < streams.length; i++) {
      if (streams[i]['url'] == provider.currentStreamUrl) {
        selectedStreamIndex = i;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Stream'),
          content: SizedBox(
            height: 200,
            width: 300,
            child: ListView.builder(
              itemCount: streams.length,
              itemBuilder: (context, index) {
                return RadioListTile<int>(
                  title: Text(streams[index]['name']!),
                  value: index,
                  groupValue: selectedStreamIndex,
                  onChanged: (value) {
                    if (value != null) {
                      selectedStreamIndex = value;
                      provider.setCurrentStreamUrl(streams[value]['url']!);
                      Navigator.of(context).pop(); // Close the dialog after selection
                    }
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

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
            leading: const Icon(Icons.person), // Icon for Profile
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.live_tv), // Icon for Cow Stream
            title: const Text('Cow Stream'),
            subtitle: Text(streams.firstWhere((stream) => stream['url'] == provider.currentStreamUrl)['name']!),
            onTap: () {
              _showStreamSelectionDialog(context, provider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications), // Icon for Notifications
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode), // Icon for Dark Mode
            title: const Text('Dark Mode'),
            value: provider.isDarkMode,
            onChanged: (bool value) {
              provider.toggleDarkMode(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup), // Icon for Backup & Restore
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
            leading: const Icon(Icons.help), // Icon for Help & Support
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info), // Icon for About App
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
