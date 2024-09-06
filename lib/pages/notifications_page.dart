import 'package:cow_monitor/services/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  NotificationsPageState createState() => NotificationsPageState();
}

class NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CowProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: provider.notificationsEnabled,
              onChanged: (bool value) {
                provider.toggleNotifications(value);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Notification Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text('Alerts'),
              value: provider.alertsEnabled,
              onChanged: (bool? value) {
                provider.toggleAlerts(value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Messages'),
              value: provider.messagesEnabled,
              onChanged: (bool? value) {
                provider.toggleMessages(value ?? false);
              },
            ),
            CheckboxListTile(
              title: const Text('Reminders'),
              value: provider.remindersEnabled,
              onChanged: (bool? value) {
                provider.toggleReminders(value ?? false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
