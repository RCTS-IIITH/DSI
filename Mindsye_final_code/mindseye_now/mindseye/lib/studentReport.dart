import 'package:flutter/material.dart';

class StudentReportScreen extends StatefulWidget {
  @override
  _StudentReportScreenState createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen> {
  // Dummy data for student details and answers
  final String studentName = "Student D";
  final int age = 15;
  final String rollNumber = "123456";
  final String score = "85";
  final String briefSummary = "This student has performed well in all subjects.";
  final List<String> answers = [
    "Answer to first question",
    "Answer to second question",
    "Answer to third question",
    "Answer to fourth question"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Report',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Name: $studentName',
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
              height: 150,
              color: Colors.grey[300], // Placeholder for the image section
            ),
            SizedBox(height: 16),
            Text(
              'Score',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              score,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Brief Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              briefSummary,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: answers
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'Answer ${entry.key + 1}: ${entry.value}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
