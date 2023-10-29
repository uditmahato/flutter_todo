import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firedev/NotificationSettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://firedev-64a4e-default-rtdb.firebaseio.com/');
final FirebaseStorage storage = FirebaseStorage.instance;

class ProfilePage extends StatefulWidget {
  final User? user;

  ProfilePage({this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userName;
  String? userEmail;
  String? userImage; // <-- Store the user's image URL
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseReference = rtdb.ref();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  _fetchUserData() {
    if (user != null) {
      databaseReference.child('users').child(user!.uid).onValue.listen((event) {
        var userData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null) {
          String? userName = userData['name'];
          String? userEmail = userData['email'];
          String? imageUrl = userData['image']; // <-- Fetch the image URL

          setState(() {
            this.userName = userName;
            this.userEmail = userEmail;
            this.userImage = imageUrl; // <-- Update the user image URL
          });
        }
      });
    }
  }

  void _changePassword() async {
    String? newPassword = await _showPasswordDialog();
    if (newPassword != null && newPassword.isNotEmpty) {
      try {
        await user!.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password updated successfully!")));
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error updating password")));
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    String? newPassword;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Enter New Password',
            style: TextStyle(color: Colors.blueAccent),
          ),
          content: TextField(
            onChanged: (value) {
              newPassword = value;
            },
            obscureText: true,
            style: TextStyle(color: Colors.black),
            cursorColor: Colors.blue.shade900,
            decoration: InputDecoration(
              hintText: "Enter new password",
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade900),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade900),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue.shade900),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                'Change',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.pop(context, newPassword);
              },
            ),
          ],
        );
      },
    );
  }

  void _notifications() {
    // Navigate to the notifications settings screen
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => NotificationSettingsScreen()));
  }

  void _appearance() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Select Theme'),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  // Indicate that dark mode was selected
                  print("Dark Mode selected.");
                  // Set the theme mode in your app state here
                  Navigator.pop(context);
                },
                child: Text('Dark Mode'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  // Indicate that light mode was selected
                  print("Light Mode selected.");
                  // Set the theme mode in your app state here
                  Navigator.pop(context);
                },
                child: Text('Light Mode'),
              ),
            ],
          );
        });
  }

  void _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        userImage = pickedFile.path; // <-- Display the picked image immediately
      });

      File file = File(pickedFile.path);
      try {
        final ref = storage.ref().child('userImages').child(user!.uid);
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => {});
        final url = await snapshot.ref.getDownloadURL();

        await databaseReference
            .child('users')
            .child(user!.uid)
            .update({'image': url});

        setState(() {
          userImage = url; // <-- Update the user image URL after uploading
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  }

  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue.shade900, Colors.purpleAccent],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(
              child: MouseRegion(
                onEnter: (_) => setState(() => isHovering = true),
                onExit: (_) => setState(() => isHovering = false),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://m.media-amazon.com/images/M/MV5BNzcxZGNmNzQtMDljZi00ZDdkLTg5MTAtNDYwNzY3ZWM1ZjQ2XkEyXkFqcGdeQXVyMTExNDQ2MTI@._V1_FMjpg_UX1000_.jpg'),
                      radius: 70,
                      backgroundColor: Colors.transparent,
                    ),
                    Visibility(
                      visible:
                          isHovering, // <-- Control the visibility based on hover state
                      child: GestureDetector(
                        onTap:
                            _uploadImage, // <-- Call your uploadImage function here
                        child: CircleAvatar(
                          child:
                              Icon(Icons.camera, color: Colors.white, size: 30),
                          backgroundColor:
                              Colors.black38, // Semi-transparent black
                          radius: 70,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _profileInfoRow(Icons.person, "Name: $userName"),
                    SizedBox(height: 15),
                    _profileInfoRow(Icons.email, "Email: $userEmail"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text('Settings',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white70)),
            SizedBox(height: 15),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _settingTile(
                        Icons.security, "Change Password", _changePassword),
                    Divider(),
                    _settingTile(Icons.notification_important, "Notifications",
                        _notifications),
                    Divider(),
                    _settingTile(Icons.home, "Appearance", _appearance),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text, style: TextStyle(fontSize: 20)),
    );
  }

  Widget _settingTile(IconData icon, String text, void Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text, style: TextStyle(fontSize: 20)),
      onTap: onTap,
    );
  }
}
