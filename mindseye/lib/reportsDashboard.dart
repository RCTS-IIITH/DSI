import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mindseye/childReportDetails.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';

// ✅ REMOVED: grid option
enum ReportViewMode { detailed, compact }

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  _ReportsDashboardScreenState createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  String? selectedSchool = 'All Schools';
  double? maxScore;
  int? age;
  DateTime? startDate;
  DateTime? endDate;
  String? clinicName;
  bool unlabelled = false;
  List<String> availableSchools = ['All Schools'];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  String backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
  Map<String, String> schoolNameToIdMap = {};
  bool isLoading = false;
  String? errorMessage;

  // Default to compact — most mobile-friendly
  ReportViewMode viewMode = ReportViewMode.compact;

  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();
  String? _sortField = 'date'; // default sort

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
    _loadClinicName();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClinicName() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final clinic = userDetails?['clinicName']?.toString();
      setState(() {
        clinicName = clinic ?? 'Clinic Not Set';
      });
    } catch (e) {
      debugPrint('Error loading clinic name: $e');
      setState(() {
        clinicName = 'Unknown Clinic';
      });
    }
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
      final professionalId = userDetails?['phoneNumber']?.toString();

      if (professionalId == null || professionalId.isEmpty) {
        throw Exception('Professional ID not found in user details');
      }

      final uri = Uri.parse(
          '$backendUrl/api/reports/get-professional-reports?professionalId=$professionalId');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          students = (data as List).map<Map<String, dynamic>>((report) {
            final images = report['images'] ?? {};
            final houseScore = images['house']?['score'];
            final treeScore = images['tree']?['score'];
            final personScore = images['person']?['score'];

            final houseManualScore = images['house']?['manualScore'];
            final treeManualScore = images['tree']?['manualScore'];
            final personManualScore = images['person']?['manualScore'];

            int? manualAvg, modelAvg, displayScore;

            if (houseManualScore != null ||
                treeManualScore != null ||
                personManualScore != null) {
              int total = 0;
              int count = 0;
              if (houseManualScore != null) {
                total += (houseManualScore as num).toInt();
                count++;
              }
              if (treeManualScore != null) {
                total += (treeManualScore as num).toInt();
                count++;
              }
              if (personManualScore != null) {
                total += (personManualScore as num).toInt();
                count++;
              }
              manualAvg = count > 0 ? (total / count).round() : null;
            }

            if (houseScore != null ||
                treeScore != null ||
                personScore != null) {
              int total = 0;
              int count = 0;
              if (houseScore != null) {
                total += (houseScore as num).toInt();
                count++;
              }
              if (treeScore != null) {
                total += (treeScore as num).toInt();
                count++;
              }
              if (personScore != null) {
                total += (personScore as num).toInt();
                count++;
              }
              modelAvg = count > 0 ? (total / count).round() : null;
            }

            displayScore = manualAvg ?? modelAvg;

            final schoolName = report['schoolName'] ??
                (report['schoolId'] is Map
                    ? report['schoolId']['schoolName']
                    : null);

            final displaySchoolName =
                (schoolName == null || schoolName == '' || schoolName == 'N/A')
                    ? 'Personal Submission'
                    : schoolName;

            return {
              'id': report['_id'],
              'name': report['childsName'] ?? 'N/A',
              'score': displayScore,
              'manualScore': manualAvg,
              'modelScore': modelAvg,
              'labelledManually': report['flagforlabel'] == true,
              'schoolName': displaySchoolName,
              'schoolId':
                  report['schoolId'] is Map ? report['schoolId']['_id'] : null,
              'age': report['age'],
              'submittedAt': report['submittedAt'],
              'houseScore': houseScore,
              'treeScore': treeScore,
              'personScore': personScore,
              'houseManualScore': houseManualScore,
              'treeManualScore': treeManualScore,
              'personManualScore': personManualScore,
            };
          }).toList();

          filteredStudents = [...students];
          _applyFilters(); // Apply initial sort
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
      final professionalId = userDetails?['phoneNumber']?.toString();

      if (professionalId == null) return;

      final uri = Uri.parse(
          '$backendUrl/api/users/verify-professional?professionalId=$professionalId');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found']) {
          final assignedSchools =
              (data['professional']['assignedSchools'] as List?) ?? [];

          final safeSchools = assignedSchools.where((s) {
            if (s == null) return false;
            if (s is Map) {
              return s['name'] != null;
            }
            return false;
          }).toList();

          setState(() {
            availableSchools = [
              'All Schools',
              'Personal Submission',
              ...safeSchools
                  .map((school) => (school['name'] ?? '').toString())
                  .where((s) => s.isNotEmpty)
            ];

            schoolNameToIdMap = Map.fromEntries(
              safeSchools.map((school) => MapEntry(
                    (school['name'] ?? '').toString(),
                    (school['id'] ?? '').toString(),
                  )),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading schools: $e');
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
        _debouncedApplyFilters();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
        _debouncedApplyFilters();
      });
    }
  }

  void _debouncedApplyFilters() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), _applyFilters);
  }

  void _applyFilters() {
    setState(() {
      filteredStudents = students.where((student) {
        // School filter
        if (selectedSchool != null &&
            selectedSchool!.isNotEmpty &&
            selectedSchool != 'All Schools') {
          if (selectedSchool == 'Personal Submission') {
            if (student['schoolName'] != 'Personal Submission') return false;
          } else {
            if (student['schoolName'] != selectedSchool) return false;
          }
        }

        // Max score filter
        if (maxScore != null) {
          final studentScore = (student['score'] is num)
              ? (student['score'] as num).toDouble()
              : parseScore(student['score']).toDouble();
          if (studentScore > maxScore!) return false;
        }

        // Age filter
        if (age != null) {
          final studentAge = student['age'] is int
              ? student['age']
              : int.tryParse(student['age']?.toString() ?? '');
          if (studentAge != age) return false;
        }

        // Date range filter
        if (startDate != null && student['submittedAt'] != null) {
          try {
            final submittedAt = DateTime.parse(student['submittedAt']);
            if (submittedAt.isBefore(startDate!)) return false;
          } catch (_) {}
        }
        if (endDate != null && student['submittedAt'] != null) {
          try {
            final submittedAt = DateTime.parse(student['submittedAt']);
            if (submittedAt.isAfter(endDate!)) return false;
          } catch (_) {}
        }

        // Unlabelled filter
        if (unlabelled) {
          final isUnlabelled = student['labelledManually'] == false ||
              student['labelledManually'] == null;
          if (!isUnlabelled) return false;
        }

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          final name = (student['name'] ?? '').toLowerCase();
          if (!name.contains(query)) return false;
        }

        return true;
      }).toList();

      // Apply sorting
      filteredStudents.sort((a, b) {
        switch (_sortField) {
          case 'score':
            return (b['score'] ?? 0).compareTo(a['score'] ?? 0);
          case 'date':
            final dateA = DateTime.tryParse(a['submittedAt'] ?? '');
            final dateB = DateTime.tryParse(b['submittedAt'] ?? '');
            return (dateB ?? DateTime(1970)).compareTo(dateA ?? DateTime(1970));
          case 'name':
            return (a['name'] ?? '').compareTo(b['name'] ?? '');
          default:
            return 0;
        }
      });
    });
  }

  void _resetFilters() {
    setState(() {
      selectedSchool = 'All Schools';
      maxScore = null;
      age = null;
      startDate = null;
      endDate = null;
      unlabelled = false;
      _searchController.clear();
      _sortField = 'date';
      filteredStudents = [...students];
      _applyFilters();
    });
  }

  Widget _compactInput({
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return SizedBox(
      height: 36,
      child: TextField(
        onChanged: (value) {
          onChanged?.call(value);
          _debouncedApplyFilters();
        },
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          prefixIcon: Icon(icon, size: 16, color: Colors.black54),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
        style: TextStyle(fontSize: 13),
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

  Widget _schoolDropdownCompact() {
    return SizedBox(
      height: 36,
      child: DropdownButtonFormField<String?>(
        isExpanded: true,
        value: selectedSchool,
        items: availableSchools
            .map((school) => DropdownMenuItem<String?>(
                  value: school,
                  child: Text(
                    school ?? 'All Schools',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedSchool = value ?? 'All Schools';
            _applyFilters();
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.school, size: 16),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
        style: TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _dateButton(String label, DateTime? date, VoidCallback onTap) {
    final text = date != null ? DateFormat('dd MMM').format(date) : label;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.calendar_today_outlined, size: 14),
            SizedBox(width: 4),
            Text(text, style: TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildCompactFilters() {
    return Column(children: [
      // Search + School Row
      Row(children: [
        Expanded(
          child: SizedBox(
            height: 32, // 👈 Reduced from default (was ~48) to 32 or even 28
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _debouncedApplyFilters(),
              decoration: InputDecoration(
                hintText: "Search by name...",
                prefixIcon:
                    Icon(Icons.search, size: 14), // 👈 Optional: smaller icon
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(
                    vertical: 4, horizontal: 10), // 👈 Reduced padding
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6), // 👈 Smaller radius
                    borderSide: BorderSide.none),
                isDense: true, // 👈 Important: reduces internal spacing
              ),
              style: TextStyle(fontSize: 12), // 👈 Smaller font
            ),
          ),
        ),
        SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          child: Checkbox(
            value: unlabelled,
            onChanged: (v) {
              setState(() {
                unlabelled = v ?? false;
                _applyFilters();
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ]),
      SizedBox(height: 8),
      // School + Sort Row
      Row(children: [
        Expanded(child: _schoolDropdownCompact()),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String?>(
            value: _sortField,
            decoration: InputDecoration(
              labelText: "Sort by",
              labelStyle: TextStyle(color: Colors.black87),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: 'date',
                child: Text('Date ↓',
                    style: TextStyle(
                        fontSize: 13, color: Colors.black87)), // 👈 Black text
              ),
              DropdownMenuItem(
                value: 'score',
                child: Text('Score ↓',
                    style: TextStyle(
                        fontSize: 13, color: Colors.black87)), // 👈 Black text
              ),
              DropdownMenuItem(
                value: 'name',
                child: Text('Name A-Z',
                    style: TextStyle(
                        fontSize: 13, color: Colors.black87)), // 👈 Black text
              ),
            ],
            onChanged: (value) {
              setState(() {
                _sortField = value;
                _applyFilters();
              });
            },
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ]),
      SizedBox(height: 8),
      // Date Range
      Row(children: [
        _dateButton('Start', startDate, _selectStartDate),
        SizedBox(width: 8),
        _dateButton('End', endDate, _selectEndDate),
      ]),
      SizedBox(height: 8),
      // Apply + Reset
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: Icon(Icons.filter_alt, size: 16),
            label: Text("Apply", style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetFilters,
            icon: Icon(Icons.clear, size: 16),
            label: Text("Reset", style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ]),
    ]);
  }

  Widget _buildDetailedReportCard(Map<String, dynamic> student) {
    final studentScore = student['score'] is num
        ? (student['score'] as num).toDouble()
        : parseScore(student['score']).toDouble();
    return InkWell(
      onTap: () => _openChildReport(student),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person_outline, color: Colors.white)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(student['name'] ?? 'Unknown',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))),
                      SizedBox(width: 8),
                      if (student['manualScore'] != null)
                        Chip(
                            label: Text("Manual"),
                            backgroundColor: Colors.orange.shade100,
                            labelStyle:
                                TextStyle(color: Colors.orange.shade800))
                      else if (student['modelScore'] != null)
                        Chip(
                            label: Text("AI"),
                            backgroundColor: Colors.blue.shade100,
                            labelStyle: TextStyle(color: Colors.blue.shade800))
                      else
                        Chip(
                            label: Text("Pending"),
                            backgroundColor: Colors.grey.shade200,
                            labelStyle: TextStyle(color: Colors.grey.shade700)),
                    ]),
                    SizedBox(height: 8),
                    if ((student['houseScore'] != null ||
                        student['treeScore'] != null ||
                        student['personScore'] != null ||
                        student['houseManualScore'] != null ||
                        student['treeManualScore'] != null ||
                        student['personManualScore'] != null))
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (student['houseManualScore'] != null ||
                                student['houseScore'] != null)
                              Row(children: [
                                Icon(Icons.home, size: 14, color: Colors.brown),
                                SizedBox(width: 6),
                                Text(
                                    "House: ${student['houseManualScore'] ?? student['houseScore'] ?? 'N/A'}%",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]))
                              ]),
                            if (student['treeManualScore'] != null ||
                                student['treeScore'] != null)
                              Row(children: [
                                Icon(Icons.park, size: 14, color: Colors.green),
                                SizedBox(width: 6),
                                Text(
                                    "Tree: ${student['treeManualScore'] ?? student['treeScore'] ?? 'N/A'}%",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]))
                              ]),
                            if (student['personManualScore'] != null ||
                                student['personScore'] != null)
                              Row(children: [
                                Icon(Icons.person,
                                    size: 14, color: Colors.orange),
                                SizedBox(width: 6),
                                Text(
                                    "Person: ${student['personManualScore'] ?? student['personScore'] ?? 'N/A'}%",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[700]))
                              ]),
                            SizedBox(height: 8),
                          ]),
                    Row(children: [
                      Expanded(
                          child: LinearProgressIndicator(
                              value: (studentScore / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              color: studentScore >= 70
                                  ? Colors.green
                                  : studentScore > 0
                                      ? Colors.orange
                                      : Colors.red,
                              backgroundColor: Colors.grey[300])),
                      SizedBox(width: 8),
                      Text("${studentScore.toInt()}%",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    SizedBox(height: 6),
                    Row(children: [
                      if (student['age'] != null)
                        Text("${student['age']} yrs",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(width: 12),
                      if (student['schoolName'] != null)
                        Expanded(
                            child: Text(student['schoolName'],
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis)),
                      Text(
                        student['submittedAt'] != null
                            ? DateFormat('dd MMM yyyy')
                                .format(DateTime.parse(student['submittedAt']))
                            : 'N/A',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue, // 👈 date color
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCompactReportCard(Map<String, dynamic> student) {
    final studentScore = student['score'] is num
        ? (student['score'] as num).toDouble()
        : parseScore(student['score']).toDouble();
    return InkWell(
      onTap: () => _openChildReport(student),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person_outline, color: Colors.white)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(student['name'] ?? 'Unknown',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis)),
                      SizedBox(width: 6),
                      if (student['manualScore'] != null)
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text("Manual",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange.shade800)))
                      else if (student['modelScore'] != null)
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text("AI",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.blue.shade800)))
                      else
                        SizedBox.shrink(),
                    ]),
                    SizedBox(height: 6),
                    Row(children: [
                      if (student['age'] != null)
                        Text("${student['age']} yrs",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black)),
                      SizedBox(width: 8),
                      if (student['schoolName'] != null) ...[
                        SizedBox(width: 8),
                        Expanded(
                            child: Text(student['schoolName'],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                                overflow: TextOverflow.ellipsis)),
                        Text(
                          student['submittedAt'] != null
                              ? DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(student['submittedAt']))
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue, // 👈 date color
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ]),
                    SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LinearProgressIndicator(
                              value: (studentScore / 100).clamp(0.0, 1.0),
                              minHeight: 6,
                              color: studentScore >= 70
                                  ? Colors.green
                                  : studentScore > 0
                                      ? Colors.orange
                                      : Colors.red,
                              backgroundColor: Colors.grey[300])),
                      SizedBox(width: 8),
                      Text("${studentScore.toInt()}%",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _openChildReport(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChildReport(data: "${student['id']}", reportId: student['id'])),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
        SizedBox(height: 12),
        Text("No reports found.",
            style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
        SizedBox(height: 12),
        Text(message,
            style: TextStyle(fontSize: 16, color: Colors.red[600]),
            textAlign: TextAlign.center),
        SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _initializeDashboard,
          icon: Icon(Icons.refresh),
          label: Text("Retry"),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, foregroundColor: Colors.white),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text('Reports Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              tooltip: "Refresh",
              onPressed: _initializeDashboard),
          PopupMenuButton<ReportViewMode>(
            tooltip: "View mode",
            onSelected: (mode) {
              setState(() {
                viewMode = mode;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: ReportViewMode.detailed,
                  child: Row(children: [
                    Icon(Icons.view_agenda, size: 18),
                    SizedBox(width: 8),
                    Text('Detailed')
                  ])),
              PopupMenuItem(
                  value: ReportViewMode.compact,
                  child: Row(children: [
                    Icon(Icons.view_list, size: 18),
                    SizedBox(width: 8),
                    Text('Compact')
                  ])),
              // ✅ REMOVED: Grid option
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(children: [
                Icon(
                  viewMode == ReportViewMode.detailed
                      ? Icons.view_agenda
                      : Icons.view_list, // ✅ Only two icons now
                  size: 20,
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_drop_down),
              ]),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _buildErrorState(errorMessage!)
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Filter Reports',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          _buildCompactFilters(),
                          SizedBox(height: 12),
                          // LIST area — no grid option
                          Expanded(
                            child: filteredStudents.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    itemCount: filteredStudents.length,
                                    itemBuilder: (context, index) {
                                      final student = filteredStudents[index];
                                      if (viewMode == ReportViewMode.detailed) {
                                        return _buildDetailedReportCard(
                                            student);
                                      } else {
                                        return _buildCompactReportCard(student);
                                      }
                                    },
                                  ),
                          ),
                        ]),
                  ),
      ),
    );
  }
}
