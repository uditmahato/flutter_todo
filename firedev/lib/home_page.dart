import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firedev/ProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'todo_page.dart';
import 'dart:ui_web';

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
  DatabaseReference databaseReference = rtdb.ref();
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
        var taskData = event.snapshot.value as Map<dynamic, dynamic>?;
        if (taskData != null) {
          tasks = taskData.entries
              .map((entry) => {"id": entry.key, ...entry.value})
              .toList();
        } else {
          tasks = []; // Clear the tasks list when there's no data in Firebase.
        }
        setState(() {});
      });
    }
  }

  _deleteTask(String taskId) {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .child(taskId)
          .remove()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted!')),
        );
      });
    }
  }

  _deleteAllTasks() {
    if (user != null) {
      databaseReference
          .child('users')
          .child(user!.uid)
          .child('tasks')
          .remove()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted!')),
        );
      });
    }
  }

  _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete All Tasks'),
        content: Text('Are you sure you want to delete all tasks?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteAllTasks();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully!')),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Tasks'),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(user: user),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _performLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) => Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                tasks[index]['subject'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'Priority: ${tasks[index]['priority']}',
                style: TextStyle(
                  color: tasks[index]['priority'] == 'high'
                      ? Colors.red
                      : tasks[index]['priority'] == 'medium'
                          ? Colors.orange
                          : Colors.green,
                  fontSize: 14,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.deepPurple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TodoPage(editTask: tasks[index]),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      _deleteTask(tasks[index]['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task deleted!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.shade900,
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TodoPage()),
                      );
                    },
                  ),
                  Text(
                    'Add Task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_forever, color: Colors.white),
                    onPressed: _confirmDeleteAll,
                  ),
                  Text(
                    'Delete All',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
