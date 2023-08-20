import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser; // User might be null

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You are logged in as:',
              style: TextStyle(fontSize: 20),
            ),
            if (user?.email != null)
              Text(
                user!
                    .email!, // Use null check (!) as we know user.email is not null here
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Perform logout logic here
                _performLogout(context);
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false, // Prevent navigating back to the previous pages
      );
    } catch (e) {
      // Handle logout error
      print('Logout failed: $e');
    }
  }
}
