import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'todo_page.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://firedev-64a4e-default-rtdb.firebaseio.com/');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  DatabaseReference databaseReference = rtdb.ref(); // Use rtdb instance

  List<Map<dynamic, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  _fetchTasks() {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .onValue
          .listen((event) {
        print("Fetched tasks: ${event.snapshot.value}");

        if (event.snapshot.value != null && event.snapshot.value is Map) {
          Map<dynamic, dynamic> tasksMap =
              event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            tasks = List<Map<dynamic, dynamic>>.from(tasksMap.values);
          });
        }
      }, onError: (error) {
        print("Error fetching tasks: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _performLogout(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index]['subject']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoPage(editTask: tasks[index]),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTask(
                        tasks[index]['id']); // Assuming each task has an 'id'
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TodoPage()),
          );
        },
      ),
    );
  }

  void _deleteTask(String taskId) {
    databaseReference.child(taskId).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task deleted successfully'),
        ),
      );
      _fetchTasks(); // Refresh tasks after deletion
    });
  }

  void _performLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully logged out'),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Logout failed: $e');
    }
  }
}
