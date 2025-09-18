import 'package:flutter/material.dart';

class ReportAnalysisScreen extends StatefulWidget {
  const ReportAnalysisScreen({super.key});

  @override
  _ReportAnalysisScreenState createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  // Example data structure for reports
  List<Map<String, dynamic>> reports = [
    // This should be fetched from backend
    // Example:
    // {'schoolName': 'School A', 'score': 65, 'houseScore': 70, 'treeScore': 60, 'personScore': 65},
  ];

  bool isLoading = false;
  String? errorMessage;
  double overallAverageScore = 0;
  String schoolName = 'N/A';

  @override
  void initState() {
    super.initState();
    fetchReportAnalysis();
  }

  Future<void> fetchReportAnalysis() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // TODO: Replace with actual backend API call
      // final response = await http.get(...);
      // if (response.statusCode == 200) {
      //   reports = ...parse response...
      // }
      // For now, use dummy data
      reports = [
        {
          'schoolName': 'School A',
          'score': 65,
          'houseScore': 70,
          'treeScore': 60,
          'personScore': 65
        },
        {
          'schoolName': 'School B',
          'score': 75,
          'houseScore': 80,
          'treeScore': 70,
          'personScore': 75
        },
        {
          'schoolName': null,
          'score': null,
          'houseScore': null,
          'treeScore': null,
          'personScore': null
        },
      ];
      // Calculate overall average score with error handling
      int totalScore = 0;
      int count = 0;
      for (var report in reports) {
        var score = report['score'];
        if (score != null && score is num) {
          totalScore += score.toInt();
          count++;
        }
      }
      overallAverageScore = count > 0 ? totalScore / count : 0;
      // Use first school's name for demo
      schoolName = reports.isNotEmpty && reports[0]['schoolName'] != null
          ? reports[0]['schoolName']
          : 'N/A';
    } catch (e) {
      errorMessage = 'Error fetching analysis: $e';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Score calculation logic:
  // - Scores are averaged from available sections (house, tree, person)
  // - If any section is missing/null, it is skipped in the average
  // - If all are missing, score is set to 0
  int calculateSectionAverage(Map<String, dynamic> report) {
    int total = 0;
    int count = 0;
    for (var key in ['houseScore', 'treeScore', 'personScore']) {
      var val = report[key];
      if (val != null && val is num) {
        total += val.toInt();
        count++;
      }
    }
    return count > 0 ? (total / count).round() : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text(errorMessage!))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Mental Health Report Analysis For $schoolName',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Overall Average Score: ${overallAverageScore.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(thickness: 2, color: Colors.black),
                        const SizedBox(height: 16),
                        // Dynamic graphs for each report
                        ...reports.map((report) {
                          final name = report['schoolName'] ?? 'Unknown School';
                          final score = report['score'] ?? 0;
                          final sectionAvg = calculateSectionAverage(report);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$name: Score ${score ?? 'N/A'} | Section Avg: $sectionAvg',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildGraphPlaceholder('Graph for $name'),
                              SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
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
