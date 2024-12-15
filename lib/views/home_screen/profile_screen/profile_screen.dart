import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dtc_bus_community/auth_screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfileScreen({required this.userData});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      _uploadImage(); // Upload image to Firestore Storage and update Firestore document
    }
  }

  // Function to remove the image
  void _removeImage() {
    setState(() {
      _profileImage = null;
    });
    _updateUserProfilePhotoUrl(null); // Remove image URL from Firestore
  }

  // Function to show bottom sheet with options
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () {
                _pickImage();
                Navigator.pop(context);
              },
            ),
            if (_profileImage != null || widget.userData['profilePhotoUrl'] != null)
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove photo'),
                onTap: () {
                  _removeImage();
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Function to upload image to Firebase Storage and update Firestore document
  Future<void> _uploadImage() async {
    if (_profileImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${FirebaseAuth.instance.currentUser!.uid}');
      final uploadTask = storageRef.putFile(_profileImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      _updateUserProfilePhotoUrl(downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  // Function to update Firestore user document with the new profile photo URL
  Future<void> _updateUserProfilePhotoUrl(String? photoUrl) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePhotoUrl': photoUrl,
      });
      setState(() {
        widget.userData['profilePhotoUrl'] = photoUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            Center(
              child: Stack(
                children: [
                  InkWell(
                    onTap: _showImageOptions,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (widget.userData['profilePhotoUrl'] != null && widget.userData['profilePhotoUrl'].isNotEmpty)
                          ? NetworkImage(widget.userData['profilePhotoUrl']) as ImageProvider
                          : null,
                      child: _profileImage == null && (widget.userData['profilePhotoUrl'] == null || widget.userData['profilePhotoUrl'].isEmpty)
                          ? Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.black,
                      )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // User details
            Expanded(
              child: ListView(
                children: [
                  _buildDetailCard('EmpID', widget.userData['empId'] ?? 'No ID provided'),
                  _buildDetailCard('Name', widget.userData['name'] ?? 'No name provided'),
                  _buildDetailCard('Phone Number', widget.userData['phoneNumber'] ?? 'No phone number provided'),
                  // _buildDetailCard('Experience', '${widget.userData['experience'] ?? 'No experience provided'} years'),
                  _buildDetailCard('Role', widget.userData['role'] ?? 'No role provided'),
                  // _buildDetailCard('Route Familiarity', widget.userData['routeFamiliarity'] ?? 'No route familiarity provided'),
                  // _buildDetailCard('Route Preference', widget.userData['routePreference'] ?? 'No route preference provided'),
                  _buildDetailCard('Gender', widget.userData['gender'] ?? 'No gender provided'),
                  _buildDetailCard('Username', widget.userData['username'] ?? 'No username provided'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build a detail card
  Widget _buildDetailCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
