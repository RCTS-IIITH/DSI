import 'package:flutter/material.dart';
import 'package:mindseye/labelDataScreen.dart';

class   ReportDetailsScreen extends StatefulWidget {
  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final String reportId = '82736';
  final String name = 'Student C';
  final int age = 13;
  final int rollNumber = 345678;
  final int score = 87;
  final List<String> answers = [
    'Answer to first question',
    'Answer to second question',
    'Answer to third question',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report ID: $reportId',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: $name',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Age: $age',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Roll Number: $rollNumber',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Brief Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Answer 1: ${answers[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Answer 2: ${answers[1]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Answer 3: ${answers[2]}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Implement navigation or action for manual scoring
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LabelDataScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Proceed to Manual Score',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
