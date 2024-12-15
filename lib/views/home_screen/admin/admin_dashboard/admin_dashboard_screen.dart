import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final TextEditingController acUnavailableController = TextEditingController();
  final TextEditingController nonAcUnavailableController =
      TextEditingController();
  final TextEditingController electricUnavailableController =
      TextEditingController();
  final TextEditingController empIdController = TextEditingController();
  final TextEditingController routeNumberController = TextEditingController();
  DateTime? selectedDate;
  DateTime _selectedCalendarDate = DateTime.now();

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isShowingCrewSchedule = true;

  int acUnavailablePercentage = 0;
  int nonAcUnavailablePercentage = 0;
  int electricUnavailablePercentage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();

    acUnavailableController.addListener(() {
      setState(() {
        acUnavailablePercentage =
            _calculatePercentage(acUnavailableController.text);
      });
    });

    nonAcUnavailableController.addListener(() {
      setState(() {
        nonAcUnavailablePercentage =
            _calculatePercentage(nonAcUnavailableController.text);
      });
    });

    electricUnavailableController.addListener(() {
      setState(() {
        electricUnavailablePercentage =
            _calculatePercentage(electricUnavailableController.text);
      });
    });
  }

  // Percentage Calculator
  int _calculatePercentage(String input) {
    if (input.isEmpty) return 0;
    int unavailable = int.tryParse(input) ?? 0;
    // Assume a total of 100 buses for simplicity, modify this based on your actual data
    int totalBuses = 100;
    return ((unavailable / totalBuses) * 100).round();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Toggle Crew Section
  void _toggleCrewSection() {
    setState(() {
      _isShowingCrewSchedule = !_isShowingCrewSchedule;
      if (_isShowingCrewSchedule) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildManageBusesSection(context),
                  const SizedBox(height: 20),
                  _buildManageCrewSection(context),
                  const SizedBox(height: 20),
                  _buildManageRoutesSection(context),
                  const SizedBox(height: 20),
                  _buildRidershipSection(context),
                  const SizedBox(height: 20),
                  _buildFeedbackEvaluationSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Manage Buses Section
  Widget _buildManageBusesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bus, size: 30, color: Colors.orange),
            SizedBox(width: 20),
            Text(
              'Manage Buses',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Center(
            child: const Text('View, add, or remove buses from the fleet')),
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildBusRow(context, 'AC Buses', acUnavailablePercentage,
                    acUnavailableController, Colors.green),
                const Divider(thickness: 2),
                _buildBusRow(
                    context,
                    'Non-AC Buses',
                    nonAcUnavailablePercentage,
                    nonAcUnavailableController,
                    Colors.red),
                const Divider(thickness: 2),
                _buildBusRow(
                    context,
                    'Electric Buses',
                    electricUnavailablePercentage,
                    electricUnavailableController,
                    Colors.blue),
                const SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BusRow Widgets
  Widget _buildBusRow(BuildContext context, String title, int percentage,
      TextEditingController controller, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 450, // Adjusting the width for web layout
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Enter the no of Unavaailable Buses',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          height: 150,
          width: 150, // Setting size for the pie chart
          child: _buildPieChart(percentage, color),
        ),
      ],
    );
  }

  // pie chart for unavailable busses
  Widget _buildPieChart(int percentage, Color color) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: percentage.toDouble(),
            color: color,
            radius: 50,
            title: '$percentage%',
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            value: (100 - percentage).toDouble(),
            color: Colors.grey,
            radius: 50,
            title: '${100 - percentage}%',
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
      String unavailableText, int totalPercentage) {
    int unavailable = int.tryParse(unavailableText) ?? 0;
    int available = totalPercentage - unavailable;

    return [
      PieChartSectionData(
        color: Colors.grey,
        value: unavailable.toDouble(),
        title: '$unavailable%',
        radius: 30,
        titleStyle: const TextStyle(
            fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: available.toDouble(),
        title: '$available%',
        radius: 30,
        titleStyle: const TextStyle(
            fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }

  // Manage Crew Section
  Widget _buildManageCrewSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ExpansionTile for Manage Crew Section
          ExpansionTile(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 30, color: Colors.orange),
                SizedBox(width: 20),
                Text(
                  'Manage Crew',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle:
                Center(child: const Text('Manage crew schedules and details')),
            children: [
              // TabBar and TabBarView for Crew Schedule and Crew Details
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Crew Schedule'),
                        Tab(text: 'Crew Details'),
                      ],
                      labelColor: Colors.orange,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 600,
                      width: double.infinity, // Adjusted to take full width
                      child: TabBarView(
                        children: [
                          _buildCrewSchedule(),
                          _buildCrewDetails(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Crew Schedule Section
  Widget _buildCrewSchedule() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 1500,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('EmpID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Route No')),
                DataColumn(label: Text('Bus Type')),
                DataColumn(label: Text('Source')),
                DataColumn(label: Text('Destination')),
                DataColumn(label: Text('Start Time')),
                DataColumn(label: Text('End Time')),
              ],
              rows: List.generate(
                50,
                (index) => DataRow(cells: [
                  DataCell(Text('Emp${index + 1}')),
                  DataCell(Text('Name $index')),
                  DataCell(Text('Route ${index + 1}')),
                  DataCell(Text('Bus Type ${index % 3}')),
                  DataCell(Text('Source $index')),
                  DataCell(Text('Destination $index')),
                  DataCell(Text('Start Time')),
                  DataCell(Text('End Time')),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Crew Details Section (Existing Code)
  Widget _buildCrewDetails() {
    return Column(
      children: [
        _buildTextField(controller: empIdController, label: 'Employee ID'),
        const SizedBox(height: 20),
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _selectedCalendarDate,
          selectedDayPredicate: (day) => isSameDay(day, _selectedCalendarDate),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedCalendarDate = selectedDay;
              selectedDate = selectedDay;
            });
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (selectedDate != null) {
              final formattedDate =
                  DateFormat('yyyy-MM-dd').format(selectedDate!);
              _showReviewDialog(context, formattedDate);
            }
          },
          child: const Text('Mark Absent'),
        ),
      ],
    );
  }

  // Manage Routes Section
  Widget _buildManageRoutesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 30, color: Colors.orange),
            SizedBox(width: 20),
            Text(
              'Manage Routes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Center(child: const Text('View or manage bus routes')),
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'New Route Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('Route: Source to Destination'),
                const Text('Stops: 12'),
                const SizedBox(height: 20),
                _buildMap(),
                const SizedBox(height: 20),
                _buildNearbyRoutes(),
                const SizedBox(height: 20),
                _buildRouteStatistics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ridership Section
  Widget _buildRidershipSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 30, color: Colors.orange),
            SizedBox(width: 20),
            Text(
              'Ridership Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle:
            Center(child: const Text('View ridership statistics for routes')),
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildRidershipForm(),
                const SizedBox(height: 20),
                _buildBarChart(),
                const SizedBox(height: 20),
                _buildRidershipTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Form for Ridership Stats
  Widget _buildRidershipForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: routeNumberController,
            decoration: const InputDecoration(
              labelText: 'Route Number',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Handle show ridership stats logic
          },
          child: const Text('Show Ridership Stats'),
        ),
      ],
    );
  }

// Bar Chart for Ridership Stats
  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 20, // Adjust interval as needed
                getTitlesWidget: leftTitles,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          barGroups: [
            makeGroupData(0, 30, 20),
            makeGroupData(1, 40, 15),
            makeGroupData(2, 70, 30),
            makeGroupData(3, 90, 25),
            makeGroupData(4, 60, 35),
            makeGroupData(5, 80, 40),
            makeGroupData(6, 50, 20),
            makeGroupData(7, 70, 30),
            makeGroupData(8, 85, 45),
            makeGroupData(9, 95, 50),
          ],
        ),
      ),
    );
  }

// Helper method to create bar groups with two bars per group
  BarChartGroupData makeGroupData(int x, double boarded, double exited) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: boarded,
          color: Colors.green, // Color for boarded passengers
          width: 10, // Adjust width as needed
        ),
        BarChartRodData(
          toY: exited,
          color: Colors.red, // Color for exited passengers
          width: 10, // Adjust width as needed
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: max(boarded, exited),
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

// Title widgets for the left axis
  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 20) {
      text = '20';
    } else if (value == 40) {
      text = '40';
    } else if (value == 60) {
      text = '60';
    } else if (value == 80) {
      text = '80';
    } else if (value == 100) {
      text = '100';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

// Title widgets for the bottom axis
  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>[
      '6 - 8AM',
      '8 - 10AM',
      '10 - 12PM',
      '1 - 3PM',
      '3 - 4PM',
      '4 - 5PM',
      '5 - 6PM',
      '6 - 8PM',
      '8 - 9PM',
      '9 - 10PM'
    ];

    final int index = value.toInt();

    if (index < 0 || index >= titles.length) {
      return Container(); // Return an empty container if index is out of range
    }

    final String title = titles[index];

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff7589a2),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Ridership Table
  Widget _buildRidershipTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legends for colors
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.green,
              margin: const EdgeInsets.only(right: 8),
            ),
            const Text('Boarded'),
            SizedBox(width: 20),
            Container(
              width: 20,
              height: 20,
              color: Colors.red,
              margin: const EdgeInsets.only(right: 8),
            ),
            const Text('Exited'),
          ],
        ),
        const SizedBox(height: 10), // Spacing between legend and table
        Center(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Stop')),
              DataColumn(label: Text('Boarded')),
              DataColumn(label: Text('Exited')),
            ],
            rows: List.generate(
              4,
              (index) => DataRow(cells: [
                DataCell(Text('Stop ${index + 1}')),
                DataCell(Text('${(index + 1) * 10}')),
                DataCell(Text('${(index + 1) * 5}')),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(child: Text('Map Placeholder')),
    );
  }

  Widget _buildNearbyRoutes() {
    return Container(
      height: 100,
      color: Colors.grey[200],
      child: const Center(child: Text('Nearby Routes Placeholder')),
    );
  }

  Widget _buildRouteStatistics() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: const Center(child: Text('Route Statistics Placeholder')),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, String formattedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Review Absence'),
          content:
              Text('Are you sure you want to mark absent for $formattedDate?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle marking absence logic
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

// Add this method in your _AdminDashboardState class
Widget _buildLegend() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      _buildLegendItem(color: Colors.green, label: 'AC Bus'),
      const SizedBox(width: 20),
      _buildLegendItem(color: Colors.red, label: 'Non-AC Bus'),
      const SizedBox(width: 20),
      _buildLegendItem(color: Colors.blue, label: 'Electric Bus'),
    ],
  );
}

Widget _buildLegendItem({required Color color, required String label}) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        color: color,
      ),
      const SizedBox(width: 8),
      Text(label),
    ],
  );
}

// Add this method in your Admin Dashboard screen
Widget _buildFeedbackEvaluationSection(BuildContext context) {
  // Placeholder feedback data (replace with real data from Firestore later)
  final List<Map<String, String>> feedbacks = [
    {
      'user': 'Raman',
      'date': '2024-09-17',
      'stop': 'Kanaught Place',
      'route': 'New Delhi to Gurugram',
      'comment': 'Great service, but the bus was late by 10 minutes.'
    },
    {
      'user': 'Rajshree',
      'date': '2024-09-16',
      'comment': 'The ride was comfortable, but the app crashed once.'
    },
    {
      'user': 'Kaushik',
      'date': '2024-09-15',
      'route': 'New Delhi to Noida',
      'comment': 'Loved the experience, very easy to book tickets.'
    },
    {
      'user': 'Sukhpreet',
      'date': '2024-09-15',
      'route': 'New Delhi to Gurugram',
      'comment': 'Booking ticket was not easy'
    },
  ];

  return Container(
    padding: const EdgeInsets.all(24.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ExpansionTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback, size: 30, color: Colors.orange),
          SizedBox(width: 20),
          Text(
            'Feedback Evaluation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Center(child: const Text('View and evaluate user feedback')),
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Feedbacks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true, // To make ListView fit inside the Column
                itemCount: feedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = feedbacks[index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: const Icon(Icons.feedback, color: Colors.orange, size: 40),
                      title: Text(
                        feedback['user'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text('Date: ${feedback['date'] ?? 'Unknown Date'}'),
                          const SizedBox(height: 8),
                          Text('Feedback: ${feedback['comment'] ?? 'No Feedback'}'),
                          const SizedBox(height: 8),
                          if (feedback['stop'] != null)
                            Text('Requested Stop: ${feedback['stop']}'),
                          const SizedBox(height: 8),
                          if (feedback['route'] != null)
                            Text('Requested Route: ${feedback['route']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.rate_review, color: Colors.green),
                        onPressed: () {
                          _showEvaluationDialog(context, feedback['comment'] ?? 'No Feedback');
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// This method can be reused to show the feedback evaluation dialog
void _showEvaluationDialog(BuildContext context, String feedback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Evaluate Feedback'),
        content: Text('Do you want to mark this feedback as reviewed?\n\nFeedback:\n"$feedback"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle the feedback evaluation logic here
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}


