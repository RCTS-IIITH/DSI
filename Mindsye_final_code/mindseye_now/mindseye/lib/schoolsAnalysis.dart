import 'package:flutter/material.dart';

class SchoolAnalysisScreen extends StatefulWidget {
  const SchoolAnalysisScreen({super.key});

  @override
  _SchoolAnalysisScreenState createState() => _SchoolAnalysisScreenState();
}

class _SchoolAnalysisScreenState extends State<SchoolAnalysisScreen> {
  final String schoolName = 'School A'; // School name for the report
  final int overallAverageScore = 65; // Example average score

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
            // Title
            Text(
              'Mental Health Report Analysis For $schoolName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Overall Average Score
            Text(
              'Overall Average Score: $overallAverageScore',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(thickness: 2, color: Colors.black),
            const SizedBox(height: 10),

            // Placeholder for the first graph
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'Graph',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 2, color: Colors.black),
            const SizedBox(height: 20),

            // Placeholder for the second graph
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: Text(
                  'Graph',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
