import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
  app: firebaseApp,
  databaseURL: 'https://firedev-64a4e-default-rtdb.firebaseio.com/',
);

class TodoPage extends StatefulWidget {
  final Map<dynamic, dynamic>? editTask;

  TodoPage({this.editTask});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage>
    with SingleTickerProviderStateMixin {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'High';
  DatabaseReference databaseReference = rtdb.ref();
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );

    if (widget.editTask != null) {
      _subjectController.text = widget.editTask!['subject'];
      _descriptionController.text = widget.editTask!['description'];
      _priority = widget.editTask!['priority'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo Page'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _animation!,
          child: ListView(
            children: [
              _buildCard(
                icon: Icons.subject,
                child: TextField(
                  controller: _subjectController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Enter task subject here',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 12),
              _buildCard(
                icon: Icons.priority_high,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: const Color.fromARGB(255, 255, 255, 255),
                    style: TextStyle(color: Colors.black),
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
                ),
              ),
              SizedBox(height: 12),
              _buildCard(
                icon: Icons.description,
                child: TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: Colors.black),
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Provide more details about the task',
                    hintStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  ),
                  onPressed: _addOrUpdateTask,
                  child: Text(
                    widget.editTask == null ? 'Add' : 'Update',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required Widget child}) {
    return Card(
      elevation: 8.0,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.purpleAccent, size: 28.0),
            SizedBox(width: 16),
            Expanded(child: child),
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
        await databaseReference
            .child('users')
            .child(user.uid)
            .child('tasks')
            .push()
            .set(task);
      } else {
        String taskKey = widget.editTask!['id'];
        await databaseReference
            .child('users')
            .child(user.uid)
            .child('tasks')
            .child(taskKey)
            .update(task);
      }

      Navigator.pop(context); // Go back to the previous page
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
