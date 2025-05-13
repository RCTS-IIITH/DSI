import 'package:flutter/material.dart';
import 'package:mindseye/labelPreviousData.dart';
import 'package:mindseye/login.dart';
import 'package:mindseye/reportsDashboard.dart';
import 'package:mindseye/schoolScreen.dart';
import 'package:mindseye/tagImageManuaaly.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class ProfessionalDashboard extends StatefulWidget {
  final String data;

  const ProfessionalDashboard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _ProfessionalDashboardState createState() => _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  Map<String, String> userDetails = {'role': 'Guest', 'phoneNumber': 'N/A'};

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final details = await SharedPrefsHelper.getUserDetails();
    setState(() {
      userDetails = details;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await SharedPrefsHelper.clearUserDetails();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Professional dark black
        title: Text(
          'Professional Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

              // 🧾 User Info Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Role: ${userDetails['role']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Phone: ${userDetails['phoneNumber']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              _buildButton('Report Dashboard'),
              SizedBox(height: 16),
              _buildButton("Capture Child's Drawing"),
              SizedBox(height: 16),
              _buildButton('Label Previous Data'),
              SizedBox(height: 16),
              _buildButton('School Analysis'),
              SizedBox(height: 16),
              _buildButton('Logout'),
              SizedBox(height: 24),
              Text(
                '5 images submitted today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildNotification(
                'Report ready for School A',
                'Updated on: 10/01/2023',
              ),
              SizedBox(height: 16),
              _buildNotification(
                'School B Uploaded the pictures',
                'Updated on: 10/01/2023',
              ),
              SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add action for marking all as read
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Mark All as Read',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Report Dashboard') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportsDashboardScreen(),
              ),
            );
          } else if (text == "Capture Child's Drawing") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TagImageManually(data: "Professional"),
              ),
            );
          } else if (text == 'Label Previous Data') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabelPreviousDataScreen(),
              ),
            );
          } else if (text == 'School Analysis') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SchoolsScreen(),
              ),
            );
          } else if (text == 'Logout') {
            _logout();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNotification(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          date,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
