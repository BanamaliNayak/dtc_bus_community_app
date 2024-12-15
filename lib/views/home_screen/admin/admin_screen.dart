import 'package:dtc_bus_community/consts/images.dart';
import 'package:dtc_bus_community/controller/home_controller.dart';
import 'package:dtc_bus_community/views/home_screen/admin/admin_dashboard/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile_screen/profile_screen.dart';


class AdminHomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  AdminHomeScreen({required this.userData});

  @override
  Widget build(BuildContext context) {

    var controller = Get.put(HomeController());

    var navbarItem = [
      BottomNavigationBarItem(
        icon: Image.asset(dashboard, width: 35),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(profile, width: 35),
        label: 'Profile',
      ),
    ];

    var navBody = [
      AdminDashboard(),
      ProfileScreen(userData: userData),
    ];


    return Scaffold(
      body: Column(
        children: [
          Obx(
                () => Expanded(child: navBody.elementAt(controller.currentnavIndex.value)),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: controller.currentnavIndex.value,
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: navbarItem,
          onTap: (value) {
            controller.currentnavIndex.value = value;
          },
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}


