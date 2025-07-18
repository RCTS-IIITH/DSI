import 'package:flutter/material.dart';

class SchoolAnalysisScreen extends StatefulWidget {
  final String schoolName;

  const SchoolAnalysisScreen({super.key, required this.schoolName});

  @override
  _SchoolAnalysisScreenState createState() => _SchoolAnalysisScreenState();
}

class _SchoolAnalysisScreenState extends State<SchoolAnalysisScreen> {
  final int overallAverageScore = 65; // Example average score

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Optional: Add confirmation dialog here
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back
            },
          ),
          title: Text("Report Analysis"),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Mental Health Report Analysis For ${widget.schoolName}',
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
      ),
    );
  }
}
