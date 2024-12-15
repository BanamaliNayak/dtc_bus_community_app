import 'package:dtc_bus_community/views/home_screen/staff/incident_screens/incident_history_screen.dart';
import 'package:dtc_bus_community/views/home_screen/staff/incident_screens/incident_reporting_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../task_detail_screen/task_details_page.dart';

// Mock Task Model
class Task {
  String title;
  String details;
  String status;
  String busNumber;
  String routeDetails;
  String stops;

  Task({
    required this.title,
    required this.details,
    required this.status,
    required this.busNumber,
    required this.routeDetails,
    required this.stops,
  });
}

class StaffDashboardScreen extends StatefulWidget {
  @override
  _StaffDashboardScreenState createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final List<Task> dailyTasks = [
    Task(
      title: 'Bus Route: 101A',
      details: 'Morning shift, 08:00 AM - 12:00 PM',
      status: 'Ongoing',
      busNumber: 'Bus 32',
      routeDetails: 'From Station A to Station D',
      stops: 'Station A, Station B, Station C, Station D',
    ),
    Task(
      title: 'Rest Break',
      details: 'Time: 12:00 PM - 1:00 PM',
      status: 'Pending',
      busNumber: 'N/A',
      routeDetails: 'N/A',
      stops: 'N/A',
    ),
    Task(
      title: 'Bus Route: 102C',
      details: 'Time: 1:00 PM - 4:00 PM',
      status: 'Pending',
      busNumber: 'N/A',
      routeDetails: 'N/A',
      stops: 'N/A',
    ),
    Task(
      title: 'Vehicle Inspection',
      details: 'Complete checklist before starting',
      status: 'Pending',
      busNumber: 'Bus 32',
      routeDetails: 'Station A Garage',
      stops: 'N/A',
    ),

  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Staff Dashboard'),
        //   centerTitle: true,
        // ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeNote(),
                SizedBox(height: 20),
                _buildDailyWorkflowSection(context),
                SizedBox(height: 20),
                _buildSuccessorCrewSection(),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(width: 10,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IncidentReportScreen()),
                        );
                      },
                      child: Text('Report an Incident'),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                    ),
                    SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IncidentHistoryScreen()),
                        );
                      },
                      child: Text('View Incident History'),
                        style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle: TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Welcome Note
  Widget _buildWelcomeNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Welcome, Crew Member!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          _getCurrentDate(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }


  // Daily Workflow Section
  Widget _buildDailyWorkflowSection(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Workflow Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildTasksList(context),
          ],
        ),
      ),
    );
  }

  // Tasks List
  Widget _buildTasksList(BuildContext context) {
    return Column(
      children: dailyTasks.map((task) => _buildTaskItem(task, context)).toList(),
    );
  }

  // Task Item
  Widget _buildTaskItem(Task task, BuildContext context) {
    return ListTile(
      leading: Icon(
        task.status == 'Completed'
            ? Icons.check_circle
            : (task.status == 'Ongoing'
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked),
        color: task.status == 'Completed'
            ? Colors.green
            : (task.status == 'Ongoing' ? Colors.orange : Colors.grey),
      ),
      title: Text(task.title),
      subtitle: Text(task.details),
      trailing: IconButton(
        icon: Icon(Icons.info, color: Colors.deepOrangeAccent,size: 25,),
        onPressed: () async {
          // Navigate to Task Details Page and wait for result
          final updatedTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailsPage(task: task),
            ),
          );

          // Update the task status if changed
          if (updatedTask != null) {
            setState(() {
              int index = dailyTasks.indexOf(task);
              dailyTasks[index] = updatedTask;
            });
          }
        },
      ),
    );
  }

  // Successor Crew Section
  Widget _buildSuccessorCrewSection() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Successor Crew Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildCrewDetails('Driver2', 'Driver', 'Handover: 12PM at 101C', '+91 1234567890'),
            _buildCrewDetails('Conductor2', 'Conductor', 'Handover: 12PM at 101C', '+91 9876543210'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmShiftHandover,
              child: Text('Confirm Shift Handover'),
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: Colors.orange,
                  // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
            ),
            SizedBox(height: 10),
            _buildCrewDetails('Driver3', 'Driver', 'Handover: 4PM at 102A', '+91 1234567890'),
            _buildCrewDetails('Conductor3', 'Conductor', 'Handover: 4PM at 102A', '+91 9876543210'),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: _confirmShiftHandover,
                child: Text('Confirm Shift Handover'),
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: Colors.orange,
                  // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  // Crew Details Item
  Widget _buildCrewDetails(String name, String role, String shiftTiming, String contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.person, color: Colors.white,),
      ),
      title: Text('$name - $role'),
      subtitle: Text(shiftTiming),
      trailing: IconButton(
        icon: Icon(Icons.call, color: Colors.green),
        onPressed: () {
          // Handle call action
        },
      ),
    );
  }

  // Handle Shift Handover Confirmation
  void _confirmShiftHandover() {
    // For now, just show a toast message
    Fluttertoast.showToast(
      msg: "Shift Handover Confirmed!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    // Implement actual shift handover logic (e.g., log to Firebase, update shift status, etc.)
  }
}
