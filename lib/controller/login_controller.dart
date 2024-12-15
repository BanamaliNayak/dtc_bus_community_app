import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dtc_bus_community/auth_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dtc_bus_community/views/home_screen/admin/admin_screen.dart';
import 'package:dtc_bus_community/views/home_screen/staff/staff_screen.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to login user using email and password
  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null) {
        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final role = userData?['role'];
          if (role == 'Admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminHomeScreen(
                    userData: userData!,
                  )),
            );
          } else if (role == 'Staff') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => StaffHomeScreen(
                    userData: userData!,
                  )),
            );
          } else {
            // Handle unknown role
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown user role')),
            );
            await _auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          // Handle missing role in Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No role assigned')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log in')),
      );
      debugPrint('Failed to log in: $error');
    }
  }
}
