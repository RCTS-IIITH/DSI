import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'labelDataScreen.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailsScreen({Key? key, required this.reportId})
      : super(key: key);

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late Future<Map<String, dynamic>> futureReport;

  Map<String, dynamic> reportData = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    futureReport = fetchReport(widget.reportId);
  }

  Future<Map<String, dynamic>> fetchReport(String reportId) async {
    final backendUrl = "http://localhost:3000";
    final uri =
        Uri.parse('$backendUrl/api/reports/get-report-data-clinic/$reportId');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          reportData = data;
          isLoading = false;
        });
        return data;
      } else {
        throw Exception('Failed to load');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching report: $e';
        isLoading = false;
      });
      return {};
    }
  }

  Color getRoleColor(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'parent':
        return Colors.green;
      case 'teacher':
        return Colors.orange;
      case 'professional':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget buildAnswerSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Map<String, dynamic> answers,
    Color color = Colors.blue,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: answers.entries.map((entry) {
          final key = entry.key;
          final value = entry.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "$key:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text(value),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Report Details",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: futureReport,
            builder: (context, snapshot) {
              if (isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (errorMessage.isNotEmpty) {
                return Center(child: Text(errorMessage));
              }

              final houseAns = reportData['houseAns'] ?? {};
              final personAns = reportData['personAns'] ?? {};
              final treeAns = reportData['treeAns'] ?? {};

              final submittedBy = reportData['submittedBy'] ?? {};

              final submitterRole = submittedBy['role']?.toUpperCase() ?? 'N/A';
              final submitterPhone = submittedBy['phone'] ?? 'N/A';

              final manualScore = reportData['manualScore'];
              final score = reportData['score'];
              final displayScore = manualScore != null ? parseScore(manualScore) : parseScore(score);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📄 Report ID
                    FadeInImageSections(
                      child: Text(
                        'Report ID: ${reportData['_id'] ?? 'N/A'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: 24),

                    // 📄 Submitted By Section
                    if (reportData.containsKey('submittedBy'))
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Submitted By",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(color: Colors.grey[400], thickness: 1),
                            ProfileInfoRow(
                              label: "Role",
                              value: submitterRole,
                              color: getRoleColor(submitterRole),
                            ),
                            ProfileInfoRow(
                                label: "Phone", value: submitterPhone),
                          ],
                        ),
                      ),

                    // 👦 Child Info
                    ProfileInfoRow(
                        label: "Child Name", value: reportData['childsName']),
                    ProfileInfoRow(label: "Age", value: reportData['age']),
                    ProfileInfoRow(
                        label: "Roll Number", value: reportData['rollNumber']),
                    // Show both scores if available
                    if (manualScore != null)
                      ProfileInfoRow(
                          label: "Manual Score", value: "${parseScore(manualScore)}/100"),
                    if (score != null)
                      ProfileInfoRow(
                          label: "Model Score", value: "${parseScore(score)}/100"),
                    // Main Score (for progress bar and summary)
                    ProfileInfoRow(
                        label: "Score", value: "${displayScore}/100"),
                    // Progress bar for score
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(
                        value: displayScore / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                    ),

                    SizedBox(height: 24),

                    // 🏠 House Test
                    buildAnswerSection(
                      context,
                      title: 'House Test',
                      icon: Icons.home_filled,
                      answers: houseAns,
                      color: Colors.blue[700]!,
                    ),

                    // 👤 Person Test
                    buildAnswerSection(
                      context,
                      title: 'Person Test',
                      icon: Icons.person,
                      answers: personAns,
                      color: Colors.green[700]!,
                    ),

                    // 🌳 Tree Test
                    buildAnswerSection(
                      context,
                      title: 'Tree Test',
                      icon: Icons.tram_outlined,
                      answers: treeAns,
                      color: Colors.brown,
                    ),

                    // ✍️ Proceed to Manual Scoring Button
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LabelDataScreen(
                              reportId: widget.reportId,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit_document,
                          size: 20, color: Colors.white),
                      label: Text("Proceed to Manual Scoring",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// 🎨 Custom Widgets

class FadeInImageSections extends StatelessWidget {
  final Widget child;
  const FadeInImageSections({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity:
          context.findAncestorStateOfType<State<ReportDetailsScreen>>()!.mounted
              ? 1.0
              : 0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInCirc,
      child: child,
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color? color;

  const ProfileInfoRow({
    Key? key,
    required this.label,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: ${value?.toString() ?? 'N/A'}',
        style: TextStyle(fontSize: 16, color: color),
      ),
    );
  }
}

int parseScore(dynamic score) {
  if (score == null) return 0;
  if (score is int) return score;
  if (score is double) return score.round();
  if (score is String) return int.tryParse(score) ?? 0;
  return 0;
}
