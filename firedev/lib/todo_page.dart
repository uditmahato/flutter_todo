import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://firedev-64a4e-default-rtdb.firebaseio.com/');

class TodoPage extends StatefulWidget {
  final Map<dynamic, dynamic>? editTask;

  TodoPage({this.editTask});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'High';
  DatabaseReference databaseReference = rtdb.ref();
  @override
  void initState() {
    super.initState();
    if (widget.editTask != null) {
      _subjectController.text = widget.editTask!['subject'];
      _descriptionController.text = widget.editTask!['description'];
      _priority = widget.editTask!['priority'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            DropdownButton<String>(
              value: _priority,
              items: ['High', 'Medium', 'Low'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _priority = newValue!;
                });
              },
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            ElevatedButton(
              onPressed: _addOrUpdateTask,
              child: Text(widget.editTask == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _addOrUpdateTask() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final task = {
        'subject': _subjectController.text,
        'priority': _priority,
        'description': _descriptionController.text,
      };

      if (widget.editTask == null) {
        // Add new task
        await databaseReference
            .child('users')
            .child(user.uid)
            .child('tasks')
            .push()
            .set(task);
      } else {
        // Update existing task
        // You'll need the key of the task to update. This is just a placeholder.
        String taskKey = 'TASK_KEY'; // Replace with the actual key
        await databaseReference
            .child('users')
            .child(user.uid)
            .child('tasks')
            .child(taskKey)
            .update(task);
      }

      Navigator.pop(context); // Go back to the home page
    }
  }
}
