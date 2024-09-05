import 'dart:io';
import 'package:cow_monitor/services/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String _name = 'Jane Doe';
  String _email = 'janedoe@example.com';
  String _phone = '+1 123 456 7890';
  String _profileImageUrl =
      'https://res.cloudinary.com/dtkpg6jgv/image/upload/v1722962830/cld-sample.jpg';

  final ImagePicker _picker = ImagePicker();

  // Function to pick a new profile picture
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImageUrl = image.path;
      });
    }
  }

  // Function to edit name
  void _editName() {
    TextEditingController nameController = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to edit email
  void _editEmail() {
    TextEditingController emailController = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Email'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _email = emailController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to edit phone number
  void _editNumber() {
    TextEditingController phoneController = TextEditingController(text: _phone);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Phone'),
          content: TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _phone = phoneController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Update _showNotificationPreferences function
  void _showNotificationPreferences() {
    // Load current preferences from CowProvider (if applicable)
    final cowProvider = Provider.of<CowProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notify Me By'),
          content: SingleChildScrollView(
            // Wrap in SingleChildScrollView to avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Email'),
                  value: cowProvider.emailNotifications,
                  onChanged: (bool? value) {
                    // Update provider directly and notify listeners
                    cowProvider.toggleEmailNotifications(value ?? false);
                  },
                ),
                CheckboxListTile(
                  title: const Text('SMS'),
                  value: cowProvider.smsNotifications,
                  onChanged: (bool? value) {
                    // Update provider directly and notify listeners
                    cowProvider.toggleSmsNotifications(value ?? false);
                  },
                ),
                CheckboxListTile(
                  title: const Text('Push'),
                  value: cowProvider.pushNotifications,
                  onChanged: (bool? value) {
                    // Update provider directly and notify listeners
                    cowProvider.togglePushNotifications(value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl.startsWith('http')
                      ? NetworkImage(_profileImageUrl)
                      : FileImage(File(_profileImageUrl)) as ImageProvider,
                ),
              ),
              const SizedBox(height: 16),

              // User Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                _email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Editable Fields
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Full Name'),
                subtitle: Text(_name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editName,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(_email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editEmail,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone Number'),
                subtitle: Text(_phone),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editNumber,
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Change Password'),
                onTap: () {
                  // Handle password change
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notification Preferences'),
                onTap: _showNotificationPreferences,
              ),
              const SizedBox(height: 20),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle user logout
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
