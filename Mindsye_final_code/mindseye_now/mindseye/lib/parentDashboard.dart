import 'package:flutter/material.dart';
import 'package:mindseye/previousSubmission.dart';
import 'package:mindseye/schoolLogin.dart';
import 'package:mindseye/selectChild.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String data;
  final String phone; // 🔹 Added phone parameter

  const ParentDashboardScreen({
    super.key,
    required this.data,
    required this.phone, // 🔹 Required phone number
  });

  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int imagesSubmittedToday = 5; // Example data, can be dynamically updated

  void _captureChildDrawing() {
    // 🔹 Pass `phone` to SelectChildScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildScreen(
          data: "Parent",
          phone: widget.phone,
          role: "Parent", // ✅ Add this line
        ),
      ),
    );
  }

  void _viewPreviousStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousSubmissionsScreen(
          data: widget.data,
          phone: widget.phone,
          role: "Parent",
        ),
      ),
    );
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
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SchoolLoginScreen()),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Parent Dashboard',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Capture Child's Drawing
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
                  child: const Text(
                    "Capture Child's Drawing",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // View Previous Status
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
                  child: const Text(
                    "View Previous Status",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Logout
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
                  child: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Display Images Submitted Today
              Text(
                '$imagesSubmittedToday images submitted today',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
