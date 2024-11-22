import 'package:flutter/material.dart';
import 'package:mindseye/schoolsAnalysis.dart';

class SchoolsScreen extends StatefulWidget {
  @override
  _SchoolsScreenState createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
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
                'Schools',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              _buildSchoolButton('School A'),
              SizedBox(height: 16),
              _buildSchoolButton('School B'),
              SizedBox(height: 16),
              _buildSchoolButton('School C'),
              SizedBox(height: 16),
              _buildSchoolButton('School D'),
              SizedBox(height: 16),
              _buildSchoolButton('School E'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolButton(String schoolName) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Add navigation or action for each school button
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolAnalysisScreen()
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          schoolName,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
