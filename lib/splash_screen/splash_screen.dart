import 'dart:async';
import 'package:dtc_bus_community/auth_screen/login_screen.dart';
import 'package:dtc_bus_community/consts/animations.dart';
import 'package:dtc_bus_community/views/home_screen/admin/admin_screen.dart';
import 'package:dtc_bus_community/views/home_screen/staff/staff_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () async {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final User? user = _auth.currentUser;

      if (user == null) {
        // Navigate to LoginScreen if user is not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        try {
          // Fetch user document from Firestore
          final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>;
            final role = data['role'];

            // Navigate based on user role
            if (role == 'Admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdminHomeScreen(userData: data), // Pass user data
                ),
              );
            } else if (role == 'Staff') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StaffHomeScreen(userData: data), // Pass user data
                ),
              );
            } else {
              // Handle unknown role
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unknown user role')),
              );
            }
          } else {
            // Handle missing role in Firestore
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No role assigned')),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch user role')),
          );
          debugPrint('Failed to fetch user role: $error');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            SizedBox(
              width: 100,
              height: 100,
              child: Lottie.asset(animation1),
            ),
            const Text(
              'WELCOME TO DTC BUS COMMUNITY',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 500,
              height: 500,
              child: Lottie.asset(busAnimation),
            ),
            const SizedBox(height: 20),
            const Text(
              'DELHI TRANSPORT CORPORATION',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
