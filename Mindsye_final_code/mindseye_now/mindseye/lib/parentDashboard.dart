import 'package:flutter/material.dart';
import 'package:mindseye/captureDrawing.dart';
import 'package:mindseye/previousSubmission.dart';
import 'package:mindseye/schoolLogin.dart';
import 'package:mindseye/selectChild.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String data;

  const ParentDashboardScreen({
    Key? key,
    required this.data,
  }) : super(key: key);
  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int imagesSubmittedToday = 5; // Example data, can be dynamically updated

  void _captureChildDrawing() {
    // Logic for capturing a child's drawing
    Navigator.push(context, MaterialPageRoute(builder: (context) => SelectChildScreen(data: "Parent")));
    print("Capture Child's Drawing clicked");
    // Update as needed for actual functionality
  }

  void _viewPreviousStatus() {
    // Logic for viewing the previous status
    Navigator.push(context, MaterialPageRoute(builder: (context) => PreviousSubmissionsScreen(data: widget.data)));
    print("View Previous Status clicked");
    // Update as needed for actual functionality
  }

  void _logout() {
    // Logic for logging out
    Navigator.push(context, MaterialPageRoute(builder: (context) => SchoolLoginScreen()));
    print("Logout clicked");
    // Update as needed for actual functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parent Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              // Button for capturing child's drawing
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _captureChildDrawing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Capture Child's Drawing",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Button for viewing previous status
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _viewPreviousStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "View Previous Status",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Logout button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 32),
              // Display number of images submitted today
              Text(
                '$imagesSubmittedToday images submitted today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
