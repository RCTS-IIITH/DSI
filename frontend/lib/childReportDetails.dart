import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'styles.dart';

class ChildReport extends StatefulWidget {
  final String data; // student ID passed from ReportsDashboardScreen

  // const ChildReport(student, {
  //   super.key,
  //   required this.data,
  // });
  const ChildReport({required this.data, Key? key}) : super(key: key);

  @override
  _ChildReportState createState() => _ChildReportState();
}

class _ChildReportState extends State<ChildReport> {
  String reportId = '';
  String name = '';
  int? age;
  int? rollNumber;
  int? score;
  int? modelScore;
  int? manualScore;
  String? labeledBy;
  DateTime? labeledAt;

  List<Map<String, String>> answerSections = [];

  late Future<void> futureReportData;

  @override
  void initState() {
    super.initState();
    futureReportData = getReportData();
  }

  final backendUrl = dotenv.env['BACKEND_URL']!;
  Future<void> getReportData() async {
    try {
      print('Fetching data for student ID: ${widget.data}');

      final uri = Uri.parse(
          '$backendUrl/api/reports/get-report-data-clinic/${widget.data}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data fetched: $data');

        setState(() {
          reportId = data['_id'] ?? 'N/A';
          name = data['childsName'] ?? 'N/A';
          age = data['age'] is num ? (data['age'] as num).toInt() : null;
          rollNumber = data['rollNumber'] is num
              ? (data['rollNumber'] as num).toInt()
              : null;

          // Handle scores properly
          if (data['score'] is num) {
            modelScore = (data['score'] as num).toInt();
          }

          if (data['manualScore'] is num) {
            manualScore = (data['manualScore'] as num).toInt();
          }

          labeledBy = data['labeledBy'];
          labeledAt = data['labeledAt'] != null
              ? DateTime.parse(data['labeledAt'])
              : null;

          final houseAns = data['houseAns'] as Map<String, dynamic>? ?? {};
          final personAns = data['personAns'] as Map<String, dynamic>? ?? {};
          final treeAns = data['treeAns'] as Map<String, dynamic>? ?? {};

          answerSections = [
            ..._mapToAnswerList(houseAns, sectionTitle: 'House'),
            ..._mapToAnswerList(personAns, sectionTitle: 'Person'),
            ..._mapToAnswerList(treeAns, sectionTitle: 'Tree'),
          ];
        });
      } else {
        throw Exception('Failed to load report data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading report data: $e');
      throw e;
    }
  }

  List<Map<String, String>> _mapToAnswerList(
    Map<String, dynamic> ansMap, {
    String sectionTitle = '',
  }) {
    return ansMap.entries.map((entry) {
      final question = entry.key;
      final answer = entry.value.toString();
      return {
        'question': '$sectionTitle: $question',
        'answer': answer,
      };
    }).toList();
  }

  Widget _buildScoreSection() {
    final displayScore = manualScore ?? modelScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        if (displayScore != null)
          Row(
            children: [
              Text('Overall Score: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$displayScore/100'),
            ],
          ),
        if (manualScore != null) _buildInfoRow("Manual Score", "$manualScore"),
        if (labeledBy != null || labeledAt != null) ...[
          _buildInfoRow("Labeled By", labeledBy ?? 'N/A'),
          if (labeledAt != null)
            _buildInfoRow(
                "Labeled At", DateFormat('MMM d, y').format(labeledAt!)),
        ],
        if (modelScore != null && manualScore == null)
          _buildInfoRow("Model Score Only", "$modelScore/100"),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        toolbarHeight: 50,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Child Report", style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: futureReportData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Error fetching data"),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureReportData = getReportData();
                          });
                        },
                        icon: Icon(Icons.refresh),
                        label: Text("Try Again"),
                      ),
                    ],
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInAnimation(
                          child: Text(
                        "Report ID: $reportId",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      )),
                      SizedBox(height: 24),
                      CardSection(
                        color: Colors.blue[700]!.withOpacity(0.1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Name", name),
                            _buildInfoRow("Age", age?.toString() ?? "N/A"),
                            _buildInfoRow(
                                "Roll Number", rollNumber?.toString() ?? "N/A"),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      CardSection(
                        color: Colors.green[700]!.withOpacity(0.1),
                        child: _buildScoreSection(),
                      ),
                      SizedBox(height: 24),
                      if (answerSections.isNotEmpty)
                        CardSection(
                          color: Colors.grey[300]!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  "Answers:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...answerSections.map((qa) => FadeInAnimation(
                                    delay: Duration(milliseconds: 100),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${qa['question'] ?? ''}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[900],
                                          ),
                                        ),
                                        Text(
                                          '${qa['answer'] ?? 'N/A'}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Divider(),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        )
                      else
                        Text("No answers available.",
                            style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
