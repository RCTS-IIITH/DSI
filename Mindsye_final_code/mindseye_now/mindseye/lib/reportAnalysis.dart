import 'package:flutter/material.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen({super.key});

  @override
  _ReportAnalysisScreenState createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Mental Health Report Analysis For School A',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Overall Average Score: 65',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(thickness: 2, color: Colors.black),
              const SizedBox(height: 16),
              _buildGraphPlaceholder('Graph'),
              const SizedBox(height: 16),
              _buildGraphPlaceholder('Graph'),
              const SizedBox(height: 16),
              _buildGraphPlaceholder('Graph'),
              const SizedBox(height: 16),
              _buildGraphPlaceholder('Graph'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGraphPlaceholder(String label) {
    return Container(
      height: 100,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
