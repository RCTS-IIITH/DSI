import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mindseye/childReportDetails.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';

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
  List<String> availableSchools = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  String backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3000";
  Map<String, String> schoolNameToIdMap = {};
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await _loadSchools();
      await getReports();
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing dashboard: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getReports() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = userDetails['phoneNumber'];

      final uri = Uri.parse(
          '$backendUrl/api/reports/get-professional-reports?professionalId=$professionalId');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          students = (data as List).map<Map<String, dynamic>>((report) {
            final manualScore = report['manualScore'];
            final modelScore = report['score'];
            final displayScore = manualScore != null
                ? parseScore(manualScore)
                : parseScore(modelScore);
            final schoolName = report['schoolName'] ??
                (report['schoolId'] is Map
                    ? report['schoolId']['schoolName']
                    : 'N/A');

            return {
              'id': report['_id'],
              'name': report['childsName'] ?? 'N/A',
              'score': displayScore,
              'manualScore': manualScore,
              'modelScore': modelScore,
              'labelledManually': report['flagforlabel'] == true,
              'schoolName': schoolName,
              'schoolId':
                  report['schoolId'] is Map ? report['schoolId']['_id'] : null,
              'age': report['age'],
              'submittedAt': report['submittedAt'],
            };
          }).toList();

          filteredStudents = [...students];
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch reports: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching reports: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadSchools() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = userDetails['phoneNumber'];
      final uri = Uri.parse(
          '$backendUrl/api/users/verify-professional?professionalId=$professionalId');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found']) {
          final assignedSchools =
              data['professional']['assignedSchools'] as List;

          setState(() {
            availableSchools = assignedSchools
                .map((school) => school['name'] as String)
                .toList();

            schoolNameToIdMap = Map.fromEntries(
              assignedSchools.map(
                (school) => MapEntry(
                  school['name'] as String,
                  school['id'] as String,
                ),
              ),
            );
          });
        }
      }
    } catch (e) {
      // Silently fail, handled in getReports
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredStudents = students.where((student) {
        // School filter
        if (selectedSchool != null && selectedSchool!.isNotEmpty) {
          if (student['schoolName'] != selectedSchool) {
            return false;
          }
        }

        // Score filter
        if (maxScore != null) {
          final studentScore = (student['score'] is num)
              ? (student['score'] as num).toDouble()
              : 0.0;
          if (studentScore > maxScore!) {
            return false;
          }
        }

        // Age filter
        if (age != null) {
          final studentAge = student['age'] is int
              ? student['age']
              : int.tryParse(student['age']?.toString() ?? '');
          if (studentAge != age) {
            return false;
          }
        }

        // Date range filter
        if (startDate != null &&
            endDate != null &&
            student['submittedAt'] != null) {
          try {
            final submittedAt = DateTime.parse(student['submittedAt']);
            if (submittedAt.isBefore(startDate!) ||
                submittedAt.isAfter(endDate!)) {
              return false;
            }
          } catch (_) {
            // Ignore parse errors, don't filter out
          }
        }

        // Manual labelling filter
        if (labelledManually && !(student['labelledManually'] == true)) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      selectedSchool = null;
      maxScore = null;
      age = null;
      startDate = null;
      endDate = null;
      labelledManually = false;
      filteredStudents = [...students];
    });
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black54),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildSchoolSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedSchool,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('All Schools'),
            ),
            ...availableSchools.map((school) {
              return DropdownMenuItem(
                value: school,
                child: Text(school),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              selectedSchool = value;
              _applyFilters();
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.school),
            hintText: "Select School",
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            "No reports found.",
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _initializeDashboard,
            icon: Icon(Icons.refresh),
            label: Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  int parseScore(dynamic score) {
    if (score == null) return 0;
    if (score is int) return score;
    if (score is double) return score.round();
    if (score is String) return int.tryParse(score) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Reports Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: _initializeDashboard,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _buildErrorState(errorMessage!)
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Filter Reports",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        _buildSchoolSelector(),
                        _buildInputField(
                          hintText: "Max Score",
                          icon: Icons.score,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              maxScore =
                                  value.isEmpty ? null : double.tryParse(value);
                            });
                          },
                        ),
                        _buildInputField(
                          hintText: "Age",
                          icon: Icons.accessibility,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              age = value.isEmpty ? null : int.tryParse(value);
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Start: ${startDate != null ? DateFormat('MMM d, yyyy').format(startDate!) : 'Select'}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'End: ${endDate != null ? DateFormat('MMM d, yyyy').format(endDate!) : 'Select'}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _selectDateRange,
                                icon: Icon(Icons.date_range_outlined),
                                label: Text("Pick Date Range"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _resetFilters,
                                icon: Icon(Icons.clear),
                                label: Text("Reset Filters"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text("Labelled Manually"),
                          value: labelledManually,
                          onChanged: (value) {
                            setState(() {
                              labelledManually = value ?? false;
                            });
                          },
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _applyFilters,
                            icon: Icon(Icons.filter_alt),
                            label: Text("Apply Filters"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: filteredStudents.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: filteredStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = filteredStudents[index];
                                    final studentScore = student['score'] is num
                                        ? (student['score'] as num).toDouble()
                                        : parseScore(student['score']);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChildReport(
                                                  data: student['id']),
                                            ),
                                          );
                                        },
                                        child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16)),
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    child: Icon(
                                                        Icons.person_outline,
                                                        color: Colors.white),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          student['name'] ??
                                                              'Unknown',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.score,
                                                                size: 16,
                                                                color: Colors
                                                                    .grey),
                                                            SizedBox(width: 4),
                                                            if (student[
                                                                    'manualScore'] !=
                                                                null)
                                                              Chip(
                                                                label: Text(
                                                                    "${student['manualScore']}/100"),
                                                                backgroundColor:
                                                                    Colors
                                                                        .orange
                                                                        .shade100,
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade800),
                                                              )
                                                            else if (student[
                                                                    'modelScore'] !=
                                                                null)
                                                              Chip(
                                                                label: Text(
                                                                    "${student['modelScore']}/100"),
                                                                backgroundColor:
                                                                    Colors.blue
                                                                        .shade100,
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade800),
                                                              )
                                                            else
                                                              Chip(
                                                                label: Text(
                                                                    "Pending"),
                                                                backgroundColor:
                                                                    Colors.grey
                                                                        .shade200,
                                                                labelStyle: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700),
                                                              ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        if (student['score'] !=
                                                                null &&
                                                            student['score'] >
                                                                0)
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    LinearProgressIndicator(
                                                                  value:
                                                                      studentScore /
                                                                          100,
                                                                  color: studentScore >=
                                                                          70
                                                                      ? Colors
                                                                          .green
                                                                      : studentScore >
                                                                              0
                                                                          ? Colors
                                                                              .orange
                                                                          : Colors
                                                                              .red,
                                                                  backgroundColor:
                                                                      Colors.grey[
                                                                          300],
                                                                  minHeight: 6,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                "${studentScore.toInt()}%",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          )
                                                        else
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .hourglass_empty_rounded,
                                                                  color: Colors
                                                                      .grey,
                                                                  size: 16),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                "Evaluation pending",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
