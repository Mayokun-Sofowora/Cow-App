import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _name = pref.getString('name') ?? 'Jane Doe';
      _email = pref.getString('email') ?? 'janedoe@example.com';
      _phone = pref.getString('phone') ?? '+1 123 456 7890';
      _profileImageUrl = pref.getString('profileImageUrl') ??
          'https://res.cloudinary.com/dtkpg6jgv/image/upload/v1722962830/cld-sample.jpg';
    });
  }

  Future<void> _saveProfileData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('name', _name);
    await pref.setString('email', _email);
    await pref.setString('phone', _phone);
    await pref.setString('profileImageUrl', _profileImageUrl);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImageUrl = image.path;
      });
      _saveProfileData(); // Save the updated profile picture path
    }
  }

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
                _saveProfileData(); // Save the updated name
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
                _saveProfileData(); // Save the updated email
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
                _saveProfileData(); // Save the updated phone number
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
              Text(
                _email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
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
            ],
          ),
        ),
      ),
    );
  }
}
