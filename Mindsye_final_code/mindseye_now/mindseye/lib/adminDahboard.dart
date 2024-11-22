import 'package:flutter/material.dart';
import 'package:mindseye/uploadChildDetails.dart';
import 'package:mindseye/uploadTeacherDetails.dart';

class AdminDashboard extends StatefulWidget {
  final String data;

  const AdminDashboard({
    Key? key,
    required this.data,
  }) : super(key: key);
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              _buildButton('Upload Child Details'),
              SizedBox(height: 16),
              _buildButton('Upload Teacher Details'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Add your action here for button press
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return label == 'Upload Child Details'
                ? UploadChildDetails()
                : UploadTeacherDetails();
          }));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
