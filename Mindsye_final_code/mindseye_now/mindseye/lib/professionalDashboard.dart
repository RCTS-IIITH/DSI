import 'package:flutter/material.dart';
import 'package:mindseye/captureDrawing.dart';
import 'package:mindseye/labelPreviousData.dart';
import 'package:mindseye/login.dart';
import 'package:mindseye/professionalLogin.dart';
import 'package:mindseye/reportsDashboard.dart';
import 'package:mindseye/schoolScreen.dart';
import 'package:mindseye/tagImageManuaaly.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Text(
                'Professional Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
          // Add button-specific action here
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
            // Add action for Label Previous Data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabelPreviousDataScreen(),
              ),
            );
          } else if (text == 'School Analysis') {
            // Add action for School Analysis
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SchoolsScreen(),
              ),
            );
          } else if (text == 'Logout') {
            // Add action for Logout
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
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
