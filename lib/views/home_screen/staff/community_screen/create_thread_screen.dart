import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateThreadScreen extends StatefulWidget {
  @override
  _CreateThreadScreenState createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorNameController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createThread() async {
    try {
      await _firestore.collection('threads').add({
        'author_name': _authorNameController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': 'General',  // Replace with actual category or user input
        'created_at': Timestamp.now(),
        'likes': 0,
        'comments': 0,
        'views': 0,
      });
      // Optionally show a success message or navigate back
    } catch (e) {
      // Handle error
      print('Error adding thread: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Thread'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _authorNameController,
              decoration: InputDecoration(labelText: 'Author Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createThread,
              child: Text('Post Thread'),
            ),
          ],
        ),
      ),
    );
  }
}
