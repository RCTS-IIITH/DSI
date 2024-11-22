import 'package:flutter/material.dart';

class SubmissionStatusScreen extends StatefulWidget {
  @override
  _SubmissionStatusScreenState createState() => _SubmissionStatusScreenState();
}

class _SubmissionStatusScreenState extends State<SubmissionStatusScreen> {
  final List<Map<String, String>> submissions = [
    {'name': 'Student A', 'status': 'Submitted'},
    {'name': 'Student B', 'status': 'Processing'},
    {'name': 'Student C', 'status': 'Report is Ready'},
    {'name': 'Student D', 'status': 'Sent to Professional'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submission Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Submission Status',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: submissions.length,
                itemBuilder: (context, index) {
                  final submission = submissions[index];
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    title: Text(
                      submission['name']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(submission['status']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
