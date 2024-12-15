import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_thread_screen.dart';
import 'comment_screen.dart'; // Import the comment screen

class Thread {
  final String authorName;
  final String title;
  final String description;
  final String category;
  final Timestamp createdAt;
  final int likes;
  final int comments;
  final int views;
  final String documentId;

  Thread({
    required this.authorName,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.likes,
    required this.comments,
    required this.views,
    required this.documentId,
  });

  // Convert Firestore Document to Thread
  factory Thread.fromDocument(DocumentSnapshot doc) {
    return Thread(
      authorName: doc['author_name'],
      title: doc['title'],
      description: doc['description'],
      category: doc['category'],
      createdAt: doc['created_at'],
      likes: doc['likes'],
      comments: doc['comments'],
      views: doc['views'],
      documentId: doc.id,
    );
  }
}

class CommunityScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Forum'),
        backgroundColor: Colors.orange,
        elevation: 4,
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('threads').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                return Center(child: Text('No threads available.', style: TextStyle(fontSize: 18)));
              }

              final threads = snapshot.data!.docs.map((doc) => Thread.fromDocument(doc)).toList();

              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: threads.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final thread = threads[index];

                  // Increment view count when the thread is displayed
                  _incrementViews(thread.documentId, thread.views);

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with avatar, name, and date
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 24,
                                child: Icon(Icons.person, size: 28, color: Colors.grey[700]),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      thread.authorName,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${thread.createdAt.toDate().day} ${_getMonth(thread.createdAt.toDate().month)} ${thread.createdAt.toDate().year}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Thread content
                          Text(
                            thread.title,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            thread.description,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          // Footer with likes, comments, and views
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _incrementLikes(thread.documentId, thread.likes),
                                child: Row(
                                  children: [
                                    Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey[700]),
                                    SizedBox(width: 6),
                                    Text(
                                      "${thread.likes} Likes",
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CommentScreen(threadId: thread.documentId)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.comment_outlined, size: 20, color: Colors.grey[700]),
                                    SizedBox(width: 6),
                                    Text(
                                      "${thread.comments} Comments",
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              Row(
                                children: [
                                  Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.grey[700]),
                                  SizedBox(width: 6),
                                  Text(
                                    "${thread.views} Views",
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateThreadScreen()),
                );
              },
              child: Icon(Icons.add, size: 35.0),
              backgroundColor: Colors.orange,
              tooltip: 'Create a New Thread',
            ),
          ),
        ],
      ),
    );
  }

  // Function to increment likes
  void _incrementLikes(String documentId, int currentLikes) {
    _firestore.collection('threads').doc(documentId).update({
      'likes': currentLikes + 1,
    });
  }

  // Function to increment views
  void _incrementViews(String documentId, int currentViews) {
    _firestore.collection('threads').doc(documentId).update({
      'views': currentViews + 1,
    });
  }

  // Helper function to get month name
  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
