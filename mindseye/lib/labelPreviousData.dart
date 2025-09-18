import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'reportDetails.dart';

// 🎨 App-Wide Design Tokens
class AppColors {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color success = Color(0xFF4CC9F0);
  static const Color warning = Color(0xFFF72585);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212529);
  static const Color divider = Color(0xFFE9ECEF);
}

// 📐 Spacing Tokens — Optimized for Mobile
const kSpacingTiny = 4.0;
const kSpacingSmall = 8.0;
const kSpacingMedium = 12.0; // 👈 Reduced from 16 for mobile
const kSpacingLarge = 20.0; // 👈 Reduced from 24

class LabelPreviousDataScreen extends StatefulWidget {
  const LabelPreviousDataScreen({super.key});

  @override
  _LabelPreviousDataScreenState createState() =>
      _LabelPreviousDataScreenState();
}

class _LabelPreviousDataScreenState extends State<LabelPreviousDataScreen> {
  late Future<List<dynamic>> futureReports;
  List<dynamic> allReports = [];
  String backendUrl = "http://localhost:3001";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureReports = fetchReports();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchReports() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = userDetails['phoneNumber'];
      if (professionalId == null) {
        throw Exception('Professional ID not found');
      }

      final uri = Uri.parse(
          '$backendUrl/api/reports/get-professional-reports?professionalId=$professionalId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final mappedReports =
            (data as List).map<Map<String, dynamic>>((report) {
          final images = report['images'] ?? {};
          final houseScore = images['house']?['score'];
          final treeScore = images['tree']?['score'];
          final personScore = images['person']?['score'];
          final houseManualScore = images['house']?['manualScore'];
          final treeManualScore = images['tree']?['manualScore'];
          final personManualScore = images['person']?['manualScore'];

          int? displayScore;
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
            displayScore = count > 0 ? (total / count).round() : null;
          } else if (houseScore != null ||
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
            displayScore = count > 0 ? (total / count).round() : null;
          }

          final submittedBy = report['submittedBy'] ?? {};
          final role = submittedBy['role']?.toString();

          return {
            '_id': report['_id']?.toString() ?? '',
            'childsName': report['childsName']?.toString() ?? 'N/A',
            'score': displayScore,
            'flagforlabel': report['flagforlabel'] == true,
            'schoolName': report['schoolName']?.toString() ??
                (report['schoolId'] is Map
                    ? report['schoolId']['schoolName']?.toString()
                    : 'Unknown School'),
            'age': report['age']?.toString() ?? 'N/A',
            'submittedAt': report['submittedAt']?.toString() ?? '',
            'submittedByRole': role ?? 'Unknown Role',
            'houseScore': houseScore,
            'treeScore': treeScore,
            'personScore': personScore,
            'houseManualScore': houseManualScore,
            'treeManualScore': treeManualScore,
            'personManualScore': personManualScore,
          };
        }).toList();

        return mappedReports;
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  String formatRelativeDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) return "Today";
      if (difference.inDays == 1) return "Yesterday";
      if (difference.inDays < 7)
        return "${difference.inDays}d ago"; // 👈 Shorter for mobile
      return DateFormat('MMM d').format(date); // 👈 Removed year to save space
    } catch (e) {
      return 'N/A';
    }
  }

  Map<String, List<dynamic>> groupReportsByChild(List<dynamic> reports) {
    final Map<String, List<dynamic>> grouped = {};
    for (var report in reports) {
      final name = report['childsName']?.toString() ?? '';
      final age = report['age']?.toString() ?? 'N/A';
      final key = "$name ($age)";
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(report);
    }
    return grouped;
  }

  Color getColorByScore(int score) {
    if (score >= 80) return Colors.green[700]!;
    if (score >= 50) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  Widget buildReportCard(BuildContext context, dynamic report) {
    final name = report['childsName']?.toString() ?? 'N/A';
    final age = report['age']?.toString() ?? 'N/A';
    final submittedAt = report['submittedAt']?.toString() ?? '';
    final formattedDate = formatRelativeDate(submittedAt);
    final needsLabeling = report['flagforlabel'] != true;
    bool isUrgent = false;

    if (needsLabeling && submittedAt.isNotEmpty) {
      try {
        final date = DateTime.parse(submittedAt).toLocal();
        final now = DateTime.now();
        final difference = now.difference(date);
        isUrgent = difference.inDays > 3;
      } catch (e) {
        isUrgent = false;
      }
    }

    // ✅ GET SECTION SCORES — MANUAL FIRST, THEN AI
    final houseDisplayScore =
        report['houseManualScore'] ?? report['houseScore'];
    final treeDisplayScore = report['treeManualScore'] ?? report['treeScore'];
    final personDisplayScore =
        report['personManualScore'] ?? report['personScore'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 1, // 👈 Reduced elevation for cleaner look
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            final userDetails = await SharedPrefsHelper.getUserDetails();
            final role = userDetails['role'] ?? '';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportDetailsScreen(
                  reportId: report['_id'],
                  userRole: role,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(kSpacingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👉 COMPACT HEADER: Needs Labeling + Date + Urgent
                Row(
                  children: [
                    // "Needs Labeling" badge
                    if (needsLabeling)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: kSpacingTiny),
                        decoration: BoxDecoration(
                          color: Colors.red[50]!,
                          borderRadius:
                              BorderRadius.circular(8), // 👈 Smaller radius
                          border: Border.all(color: Colors.red[200]!, width: 1),
                        ),
                        child: Text(
                          "Needs Labeling",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 11, // 👈 Smaller font
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    // Spacer
                    if (needsLabeling) SizedBox(width: 8),
                    // Submitted Date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          "$formattedDate",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12, // 👈 Optimized for mobile
                          ),
                        ),
                      ],
                    ),
                    // Urgent tag (inline, compact)
                    if (isUrgent)
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: kSpacingTiny),
                          decoration: BoxDecoration(
                            color: Colors.orange[100]!,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Urgent",
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: kSpacingMedium),
                // 👉 Progress Section
                if (report['score'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progress: ${report['score']}/100",
                        style: TextStyle(
                            fontSize: 12, // 👈 Smaller
                            color: Colors.grey[600]),
                      ),
                      SizedBox(height: kSpacingTiny),
                      LinearProgressIndicator(
                        value: (report['score'] ?? 0) / 100,
                        backgroundColor: Colors.grey[200],
                        color: getColorByScore(report['score'] ?? 0),
                        minHeight: 4, // 👈 Thinner bar
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                SizedBox(height: kSpacingMedium),
                // 👉 Section Scores
                if (houseDisplayScore != null ||
                    treeDisplayScore != null ||
                    personDisplayScore != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sections",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                      SizedBox(height: kSpacingTiny),
                      Wrap(
                        spacing: 6, // 👈 Tighter spacing
                        runSpacing: 4,
                        children: [
                          if (houseDisplayScore != null)
                            _buildSectionChip("🏠", houseDisplayScore),
                          if (treeDisplayScore != null)
                            _buildSectionChip("🌳", treeDisplayScore),
                          if (personDisplayScore != null)
                            _buildSectionChip("👤", personDisplayScore),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionChip(String emoji, dynamic score) {
    final displayScore = parseScore(score);
    final color = getColorByScore(displayScore);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 8, vertical: 4), // 👈 Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8), // 👈 Smaller radius
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        "$emoji ${displayScore}%",
        style: TextStyle(
          fontSize: 11, // 👈 Smaller font
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Label Previous Data",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold), // 👈 Slightly smaller
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                futureReports = fetchReports();
                allReports = [];
              });
            },
            tooltip: "Refresh",
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(kSpacingMedium),
          child: Column(
            children: [
              // 🔍 Search Bar — Optimized Height
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search child or ID",
                  hintStyle: TextStyle(
                      fontSize: 14, color: Colors.grey[500]), // 👈 Smaller
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: 18, color: Colors.grey),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), // 👈 Smaller radius
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12), // 👈 Tighter
                ),
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: kSpacingLarge),
              // 📋 Reports List
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: futureReports,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Error: ${snapshot.error.toString()}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No reports available."));
                    }

                    if (allReports.isEmpty) {
                      allReports = snapshot.data!;
                    }

                    List<dynamic> filteredReports = allReports;
                    final query = _searchController.text.toLowerCase();
                    if (query.isNotEmpty) {
                      filteredReports = allReports.where((report) {
                        final name = (report['childsName']?.toString() ?? '')
                            .toLowerCase();
                        final id =
                            (report['_id']?.toString() ?? '').toLowerCase();
                        return name.contains(query) || id.contains(query);
                      }).toList();
                    }

                    if (query.isNotEmpty && filteredReports.isEmpty) {
                      return Center(child: Text("No match found."));
                    }

                    final grouped = groupReportsByChild(filteredReports);

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          futureReports = fetchReports();
                          allReports = [];
                        });
                        await futureReports;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                            bottom: 20), // 👈 Add bottom padding
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, index) {
                          final key = grouped.keys.elementAt(index);
                          final reportsInGroup = grouped[key]!;

                          final hasUnlabeled = reportsInGroup
                              .any((report) => report['flagforlabel'] != true);
                          final hasUrgent = reportsInGroup.any((report) {
                            if (report['flagforlabel'] == true) return false;
                            final submittedAt =
                                report['submittedAt']?.toString() ?? '';
                            if (submittedAt.isEmpty) return false;
                            try {
                              final date =
                                  DateTime.parse(submittedAt).toLocal();
                              final now = DateTime.now();
                              return now.difference(date).inDays > 3;
                            } catch (_) {
                              return false;
                            }
                          });

                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.all(kSpacingMedium),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      key,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15, // 👈 Slightly smaller
                                        color: AppColors.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  if (hasUnlabeled)
                                    Tooltip(
                                      message: hasUrgent
                                          ? "Contains urgent unlabeled reports"
                                          : "Contains unlabeled reports",
                                      child: Container(
                                        width: 10, // 👈 Slightly smaller dot
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: hasUrgent
                                              ? Colors.red[700]!
                                              : Colors.orange[600]!,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    "${reportsInGroup.length} ${reportsInGroup.length == 1 ? 'report' : 'reports'}", // 👈 Shorter text
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (hasUrgent)
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red[100]!,
                                          borderRadius: BorderRadius.circular(
                                              6), // 👈 Smaller
                                        ),
                                        child: Text(
                                          "URGENT",
                                          style: TextStyle(
                                            color: Colors.red[800]!,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              childrenPadding: EdgeInsets.only(
                                  left: kSpacingMedium,
                                  right: kSpacingMedium,
                                  bottom: kSpacingMedium),
                              children: reportsInGroup
                                  .map((report) =>
                                      buildReportCard(context, report))
                                  .toList(),
                            ),
                          );
                        },
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

int parseScore(dynamic score) {
  if (score == null) return 0;
  if (score is num) return score.round();
  if (score is String) {
    final parsed = double.tryParse(score);
    return parsed != null ? parsed.round() : 0;
  }
  return 0;
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mindseye/shared_prefs_helper.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';

// import 'reportDetails.dart';

// // 🎨 App-Wide Design Tokens
// class AppColors {
//   static const Color primary = Color(0xFF4361EE);
//   static const Color secondary = Color(0xFF3A0CA3);
//   static const Color success = Color(0xFF4CC9F0);
//   static const Color warning = Color(0xFFF72585);
//   static const Color background = Color(0xFFF8F9FA);
//   static const Color surface = Colors.white;
//   static const Color onSurface = Color(0xFF212529);
//   static const Color divider = Color(0xFFE9ECEF);
// }

// // 📐 Spacing Tokens
// const kSpacingSmall = 8.0;
// const kSpacingMedium = 16.0;
// const kSpacingLarge = 24.0;

// class LabelPreviousDataScreen extends StatefulWidget {
//   const LabelPreviousDataScreen({super.key});

//   @override
//   _LabelPreviousDataScreenState createState() =>
//       _LabelPreviousDataScreenState();
// }

// class _LabelPreviousDataScreenState extends State<LabelPreviousDataScreen> {
//   late Future<List<dynamic>> futureReports;
//   List<dynamic> allReports = [];
//   String backendUrl = "http://localhost:3001";
//   final TextEditingController _searchController = TextEditingController();

//   // ✅ NEW: Track how many reports to show per group
//   final Map<String, int> _loadedCount = {};

//   @override
//   void initState() {
//     super.initState();
//     futureReports = fetchReports();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<List<dynamic>> fetchReports() async {
//     try {
//       final userDetails = await SharedPrefsHelper.getUserDetails();
//       final professionalId = userDetails['phoneNumber'];

//       if (professionalId == null) {
//         throw Exception('Professional ID not found');
//       }

//       final uri = Uri.parse(
//           '$backendUrl/api/reports/get-professional-reports?professionalId=$professionalId');

//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final mappedReports =
//             (data as List).map<Map<String, dynamic>>((report) {
//           final images = report['images'] ?? {};
//           final houseScore = images['house']?['score'];
//           final treeScore = images['tree']?['score'];
//           final personScore = images['person']?['score'];

//           final houseManualScore = images['house']?['manualScore'];
//           final treeManualScore = images['tree']?['manualScore'];
//           final personManualScore = images['person']?['manualScore'];

//           int? displayScore;
//           if (houseManualScore != null ||
//               treeManualScore != null ||
//               personManualScore != null) {
//             int total = 0;
//             int count = 0;
//             if (houseManualScore != null) {
//               total += (houseManualScore as num).toInt();
//               count++;
//             }
//             if (treeManualScore != null) {
//               total += (treeManualScore as num).toInt();
//               count++;
//             }
//             if (personManualScore != null) {
//               total += (personManualScore as num).toInt();
//               count++;
//             }
//             displayScore = count > 0 ? (total / count).round() : null;
//           } else if (houseScore != null ||
//               treeScore != null ||
//               personScore != null) {
//             int total = 0;
//             int count = 0;
//             if (houseScore != null) {
//               total += (houseScore as num).toInt();
//               count++;
//             }
//             if (treeScore != null) {
//               total += (treeScore as num).toInt();
//               count++;
//             }
//             if (personScore != null) {
//               total += (personScore as num).toInt();
//               count++;
//             }
//             displayScore = count > 0 ? (total / count).round() : null;
//           }

//           final submittedBy = report['submittedBy'] ?? {};
//           final role = submittedBy['role']?.toString();

//           return {
//             '_id': report['_id']?.toString() ?? '',
//             'childsName': report['childsName']?.toString() ?? 'N/A',
//             'score': displayScore,
//             'flagforlabel': report['flagforlabel'] == true,
//             'schoolName': report['schoolName']?.toString() ??
//                 (report['schoolId'] is Map
//                     ? report['schoolId']['schoolName']?.toString()
//                     : 'Unknown School'),
//             'age': report['age']?.toString() ?? 'N/A',
//             'submittedAt': report['submittedAt']?.toString() ?? '',
//             'submittedByRole': role ?? 'Unknown Role',
//             'houseScore': houseScore,
//             'treeScore': treeScore,
//             'personScore': personScore,
//           };
//         }).toList();

//         return mappedReports;
//       } else {
//         throw Exception('Failed to load reports: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching reports: $e');
//       rethrow;
//     }
//   }

//   void _onSearchChanged() {
//     setState(() {});
//   }

//   String formatRelativeDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString).toLocal();
//       final now = DateTime.now();
//       final difference = now.difference(date);

//       if (difference.inDays == 0) return "Today";
//       if (difference.inDays == 1) return "Yesterday";
//       if (difference.inDays < 7) return "${difference.inDays} days ago";
//       return DateFormat('MMM d, yyyy').format(date);
//     } catch (e) {
//       return 'N/A';
//     }
//   }

//   Map<String, List<dynamic>> groupReportsByChild(List<dynamic> reports) {
//     final Map<String, List<dynamic>> grouped = {};

//     for (var report in reports) {
//       final name = report['childsName']?.toString() ?? '';
//       final age = report['age']?.toString() ?? 'N/A';
//       final key = "$name ($age)";
//       grouped.putIfAbsent(key, () => []);
//       grouped[key]!.add(report);
//     }

//     return grouped;
//   }

//   Color getColorByScore(int score) {
//     if (score >= 80) return Colors.green[700]!;
//     if (score >= 50) return Colors.orange[700]!;
//     return Colors.red[700]!;
//   }

//   Widget buildReportCard(BuildContext context, dynamic report) {
//     final name = report['childsName']?.toString() ?? 'N/A';
//     final age = report['age']?.toString() ?? 'N/A';
//     final submittedAt = report['submittedAt']?.toString() ?? '';
//     final formattedDate = formatRelativeDate(submittedAt);
//     final needsLabeling = report['flagforlabel'] != true;

//     bool isUrgent = false;
//     if (needsLabeling && submittedAt.isNotEmpty) {
//       try {
//         final date = DateTime.parse(submittedAt).toLocal();
//         final now = DateTime.now();
//         final difference = now.difference(date);
//         isUrgent = difference.inDays > 3;
//       } catch (e) {
//         isUrgent = false;
//       }
//     }

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: () async {
//             final userDetails = await SharedPrefsHelper.getUserDetails();
//             final role = userDetails['role'] ?? '';
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ReportDetailsScreen(
//                   reportId: report['_id'],
//                   userRole: role,
//                 ),
//               ),
//             );
//           },
//           child: Container(
//             padding: EdgeInsets.all(kSpacingMedium),
//             decoration: BoxDecoration(
//               color: Colors.white,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Text(
//                         "Child: $name",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: AppColors.onSurface,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     if (needsLabeling)
//                       Container(
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.red[50],
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.red[200]!, width: 1),
//                         ),
//                         child: Text(
//                           "Needs Labeling",
//                           style: TextStyle(
//                             color: Colors.red[700],
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: kSpacingSmall),
//                 Text(
//                   "Age: $age",
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
//                     SizedBox(width: 4),
//                     Flexible(
//                       child: Text(
//                         "Submitted: $formattedDate",
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                     if (isUrgent)
//                       Padding(
//                         padding: EdgeInsets.only(left: 8),
//                         child: Container(
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.orange[100],
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             "Urgent",
//                             style: TextStyle(
//                               color: Colors.orange[800],
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: kSpacingSmall),
//                 Wrap(
//                   spacing: 8,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.blue[200]!, width: 1),
//                       ),
//                       child: Text(
//                         report['schoolName'] ?? 'Unknown School',
//                         style: TextStyle(
//                           color: Colors.blue[700],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.purple[50],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.purple[200]!, width: 1),
//                       ),
//                       child: Text(
//                         report['submittedByRole'] ?? 'Unknown Role',
//                         style: TextStyle(
//                           color: Colors.purple[700],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: kSpacingMedium),
//                 if (report['score'] != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Progress: ${report['score']}/100",
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       SizedBox(height: 4),
//                       LinearProgressIndicator(
//                         value: (report['score'] ?? 0) / 100,
//                         backgroundColor: Colors.grey[200],
//                         color: getColorByScore(report['score'] ?? 0),
//                         minHeight: 6,
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                     ],
//                   ),
//                 SizedBox(height: kSpacingMedium),
//                 if (report['houseScore'] != null ||
//                     report['treeScore'] != null ||
//                     report['personScore'] != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Sections",
//                           style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.grey[700])),
//                       SizedBox(height: 4),
//                       Wrap(
//                         spacing: 12,
//                         runSpacing: 4,
//                         children: [
//                           if (report['houseScore'] != null)
//                             _buildSectionChip("🏠", report['houseScore']),
//                           if (report['treeScore'] != null)
//                             _buildSectionChip("🌳", report['treeScore']),
//                           if (report['personScore'] != null)
//                             _buildSectionChip("👤", report['personScore']),
//                         ],
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionChip(String emoji, dynamic score) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         "$emoji ${score}%",
//         style: TextStyle(fontSize: 12, color: Colors.grey[800]),
//       ),
//     );
//   }

//   // ✅ NEW: Reset all loaded counts
//   void _collapseAll() {
//     setState(() {
//       _loadedCount.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           "Label Previous Data",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh, color: Colors.white),
//             onPressed: () {
//               setState(() {
//                 futureReports = fetchReports();
//                 allReports = [];
//                 _loadedCount.clear(); // ✅ Reset on refresh
//               });
//             },
//             tooltip: "Refresh",
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.all(kSpacingMedium),
//           child: Column(
//             children: [
//               // 🔍 Enhanced Search Bar
//               TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search child name or report ID",
//                   hintStyle: TextStyle(fontSize: 15, color: Colors.grey[500]),
//                   prefixIcon: Icon(Icons.search, color: Colors.grey),
//                   suffixIcon: _searchController.text.isNotEmpty
//                       ? IconButton(
//                           icon: Icon(Icons.clear, size: 18, color: Colors.grey),
//                           onPressed: () => _searchController.clear(),
//                         )
//                       : null,
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding:
//                       EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                 ),
//                 style: TextStyle(fontSize: 16),
//               ),

//               SizedBox(height: kSpacingMedium),

//               // ✅ NEW: Collapse All Button
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton(
//                     onPressed: _collapseAll,
//                     child: Text(
//                       "Collapse All",
//                       style: TextStyle(
//                         color: Colors.red[700],
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: kSpacingLarge),

//               // 📋 Reports List
//               Expanded(
//                 child: FutureBuilder<List<dynamic>>(
//                   future: futureReports,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(
//                           child: Text("Error: ${snapshot.error.toString()}"));
//                     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return Center(child: Text("No reports available."));
//                     }

//                     if (allReports.isEmpty) {
//                       allReports = snapshot.data!;
//                     }

//                     List<dynamic> filteredReports = allReports;
//                     final query = _searchController.text.toLowerCase();
//                     if (query.isNotEmpty) {
//                       filteredReports = allReports.where((report) {
//                         final name = (report['childsName']?.toString() ?? '')
//                             .toLowerCase();
//                         final id =
//                             (report['_id']?.toString() ?? '').toLowerCase();
//                         return name.contains(query) || id.contains(query);
//                       }).toList();
//                     }

//                     if (query.isNotEmpty && filteredReports.isEmpty) {
//                       return Center(child: Text("No match found."));
//                     }

//                     final grouped = groupReportsByChild(filteredReports);

//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         setState(() {
//                           futureReports = fetchReports();
//                           allReports = [];
//                           _loadedCount.clear();
//                         });
//                         await futureReports;
//                       },
//                       child: ListView.builder(
//                         itemCount: grouped.keys.length,
//                         itemBuilder: (context, index) {
//                           final key = grouped.keys.elementAt(index);
//                           final reportsInGroup = grouped[key]!;
//                           final initialLoadCount = _loadedCount[key] ?? 5;
//                           final hasMore = reportsInGroup.length > initialLoadCount;

//                           return Card(
//                             margin: EdgeInsets.only(bottom: 8),
//                             elevation: 1,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: ExpansionTile(
//                               tilePadding: EdgeInsets.all(kSpacingMedium),
//                               title: Text(
//                                 key,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                   color: AppColors.onSurface,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 "${reportsInGroup.length} ${reportsInGroup.length == 1 ? 'submission' : 'submissions'}",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               childrenPadding: EdgeInsets.only(
//                                   left: kSpacingMedium,
//                                   right: kSpacingMedium,
//                                   bottom: kSpacingMedium),
//                               children: [
//                                 ...reportsInGroup
//                                     .take(initialLoadCount)
//                                     .map((report) =>
//                                         buildReportCard(context, report))
//                                     .toList(),
//                                 if (hasMore)
//                                   Padding(
//                                     padding: EdgeInsets.symmetric(vertical: 12),
//                                     child: Center(
//                                       child: ElevatedButton.icon(
//                                         onPressed: () {
//                                           setState(() {
//                                             _loadedCount[key] =
//                                                 initialLoadCount + 5;
//                                           });
//                                         },
//                                         icon: Icon(Icons.expand_more, size: 18),
//                                         label: Text("Load More Reports"),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.grey[200],
//                                           foregroundColor: AppColors.onSurface,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           padding: EdgeInsets.symmetric(
//                                               horizontal: 24, vertical: 12),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
