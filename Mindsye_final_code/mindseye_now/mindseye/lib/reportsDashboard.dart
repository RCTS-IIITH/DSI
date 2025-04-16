import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mindseye/childReportDetails.dart';
import 'package:mindseye/reportDetails.dart';
import 'package:http/http.dart' as http;

class ReportsDashboardScreen extends StatefulWidget {
  @override
  _ReportsDashboardScreenState createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  String? selectedSchool;
  double? maxScore;
  int? age;
  DateTime? startDate;
  DateTime? endDate;
  bool labelledManually = false;

  // Dummy student data
  // List<Map<String, dynamic>> students = [
  //   {'name': 'Student A', 'score': 85, 'labelledManually': true},
  //   {'name': 'Student B', 'score': 90, 'labelledManually': false},
  //   {'name': 'Student C', 'score': 78, 'labelledManually': true},
  //   {'name': 'Student D', 'score': 60, 'labelledManually': false},
  // ];
  List<Map<String, dynamic>> students = [];

  List<Map<String, dynamic>> filteredStudents = [];
  String backendUrl = dotenv.env['BACKEND_URL']!;
  Future<void> getStudents() async {
    // Fetch students from the database
    // This is a placeholder for the actual implementation
    final uri = Uri.parse('$backendUrl/api/reports/get-report-data-clinic');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        for (var student in data) {
          students.add({
            'id': student['_id'],
            'name': student['childsName'],
            'score': student['score'] == null ? 0 : student['score'],
            'labelledManually':
                student['flagforlabel'] == "true" ? true : false,
          });
        }
      });
    } else {
      print('Failed to load students');
    }
  }

  @override
  void initState() {
    super.initState();
    getStudents();
    filteredStudents = students; // Initialize with the full list
  }

  // Date picker function for selecting date range
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null &&
        picked !=
            DateTimeRange(
                start: startDate ?? DateTime.now(),
                end: endDate ?? DateTime.now())) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  // Apply filters
  void _applyFilters() {
    setState(() {
      filteredStudents = students.where((student) {
        final meetsScoreCriteria =
            maxScore == null || student['score'] <= maxScore!;
        final meetsLabelledCriteria =
            !labelledManually || student['labelledManually'] == true;
        return meetsScoreCriteria && meetsLabelledCriteria;
      }).toList();
    });
    print("Filters applied: ${filteredStudents.length} students matched.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reports Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Select School',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedSchool = value;
                });
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Filter by Score Less Than',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  maxScore = double.tryParse(value);
                });
              },
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Filter by Age',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  age = int.tryParse(value);
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start: ${startDate != null ? DateFormat('EEE, MMM d').format(startDate!) : 'Select'}',
                ),
                Text(
                  'End: ${endDate != null ? DateFormat('EEE, MMM d').format(endDate!) : 'Select'}',
                ),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectDateRange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Select Date Range',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text("Labelled Manually"),
              value: labelledManually,
              onChanged: (value) {
                setState(() {
                  labelledManually = value!;
                });
              },
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) {
                  final student = filteredStudents[index];
                  String id = student['id'];
                  // print(id);
                  return InkWell(
                    onTap: () {
                      print(id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChildReport(
                            data: id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            '${student['name']}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Score: ${student['score']}'),
                        ),
                      ),
                    ),
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
