// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mindseye/shared_prefs_helper.dart';
// import 'dart:convert';

// import 'reportDetails.dart';

// class LabelPreviousDataScreen extends StatefulWidget {
//   const LabelPreviousDataScreen({super.key});

//   @override
//   _LabelPreviousDataScreenState createState() =>
//       _LabelPreviousDataScreenState();
// }

// class _LabelPreviousDataScreenState extends State<LabelPreviousDataScreen> {
//   late Future<List<dynamic>> futureReports;
//   List<dynamic> allReports = [];
//   List<dynamic> filteredReports = [];
//   final TextEditingController _searchController = TextEditingController();

//   String backendUrl = "http://localhost:3000";

//   @override
//   void initState() {
//     super.initState();
//     futureReports = fetchReports();
//     _searchController.addListener(_onSearchChanged);
//   }

//   Future<List<dynamic>> fetchReports() async {
//     try {
//       final userDetails = await SharedPrefsHelper.getUserDetails();
//       final professionalId = userDetails['phoneNumber'];

//       if (professionalId == null) {
//         throw Exception('Professional ID not found');
//       }

//       // Get reports directly using the working endpoint
//       final uri = Uri.parse('$backendUrl/api/reports/get-professional-reports')
//           .replace(queryParameters: {'professionalId': professionalId});

//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         setState(() {
//           allReports = (data as List).map<Map<String, dynamic>>((report) {
//             final manualScore = report['manualScore'];
//             final modelScore = report['score'];
//             final displayScore = manualScore != null
//                 ? parseScore(manualScore)
//                 : parseScore(modelScore);
//             final schoolName = report['schoolName'] ??
//                 (report['schoolId'] is Map
//                     ? report['schoolId']['schoolName']
//                     : 'N/A');

//             return {
//               '_id': report['_id'],
//               'childsName': report['childsName'] ?? 'N/A',
//               'age': report['age'],
//               'score': displayScore,
//               'manualScore': manualScore,
//               'modelScore': modelScore,
//               'flagforlabel': report['flagforlabel'] == true,
//               'submittedAt': report['submittedAt'],
//               'schoolName': schoolName,
//               'schoolId':
//                   report['schoolId'] is Map ? report['schoolId']['_id'] : null,
//             };
//           }).toList();

//           filteredReports = [...allReports];
//           print('Fetched reports count: ${filteredReports.length}');
//         });

//         return allReports;
//       } else {
//         throw Exception('Failed to load reports: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching reports: $e');
//       setState(() {
//         filteredReports = [];
//       });
//       return [];
//     }
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         filteredReports = allReports;
//       } else {
//         filteredReports = allReports.where((report) {
//           final name = (report['childsName'] ?? '').toString().toLowerCase();
//           final id = (report['_id'] ?? '').toString().toLowerCase();
//           return name.contains(query) || id.contains(query);
//         }).toList();
//       }
//     });
//   }

//   Map<String, List<dynamic>> groupReportsByChild(List<dynamic> reports) {
//     final Map<String, List<dynamic>> grouped = {};

//     for (var report in reports) {
//       final name = report['childsName'] ?? '';
//       final age = report['age'] is int ? report['age'].toString() : 'N/A';
//       final key = "$name ($age)";
//       if (!grouped.containsKey(key)) {
//         grouped[key] = [];
//       }
//       grouped[key]?.add(report);
//     }

//     return grouped;
//   }

//   Widget buildReportCard(BuildContext context, dynamic report) {
//     final name = report['childsName'] ?? 'N/A';
//     final age = report['age'] is int ? report['age'].toString() : 'N/A';
//     final submittedAt = report['submittedAt'] != null
//         ? DateTime.parse(report['submittedAt']).toLocal()
//         : null;

//     final shortDate = submittedAt?.toString().split(" ").first ?? 'N/A';
//     final score = report['score'] != null ? report['score'].toString() : 'N/A';
//     final manualScore = report['manualScore'];
//     final modelScore = report['modelScore'];
//     final flagged = report['flagforlabel'] == true;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: AnimatedOpacity(
//         duration: Duration(milliseconds: 300),
//         opacity: 1.0,
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           margin: EdgeInsets.zero,
//           child: InkWell(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ReportDetailsScreen(
//                     reportId: report['_id'],
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Child: $name",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                       if (flagged) Icon(Icons.warning, color: Colors.redAccent),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Age: $age",
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                   Text(
//                     "Submitted At: $shortDate",
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                   // Updated score display
//                   Text(
//                     manualScore != null
//                         ? "Manual Score: $score"
//                         : modelScore != null
//                             ? "Model Score: $score"
//                             : "Score: N/A",
//                     style: TextStyle(
//                         color: score == 'N/A'
//                             ? Colors.grey
//                             : score == '0'
//                                 ? Colors.orange
//                                 : Colors.green),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.black,
//         elevation: 0,
//         title: Text(
//           "Label Previous Data",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: "Search by name or report ID",
//                   hintStyle: TextStyle(fontSize: 15),
//                   prefixIcon: Icon(Icons.search_outlined),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(height: 16),
//               Expanded(
//                 child: FutureBuilder(
//                   future: futureReports,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text("Error fetching reports."));
//                     } else if (_searchController.text.isNotEmpty &&
//                         filteredReports.isEmpty) {
//                       return Center(child: Text("No match found."));
//                     } else if (filteredReports.isEmpty) {
//                       return Center(child: Text("No reports available."));
//                     } else {
//                       final grouped = groupReportsByChild(filteredReports);

//                       return ListView.builder(
//                         itemCount: grouped.keys.length,
//                         itemBuilder: (context, index) {
//                           final key = grouped.keys.elementAt(index);
//                           final reportsInGroup = grouped[key]!;
//                           return ExpansionTile(
//                             tilePadding: EdgeInsets.symmetric(horizontal: 8),
//                             title: Text(
//                               key,
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600, fontSize: 16),
//                             ),
//                             subtitle: Text(
//                               "${reportsInGroup.length} ${reportsInGroup.length == 1 ? 'submission' : 'submissions'}",
//                               style:
//                                   TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                             children: reportsInGroup.map((report) {
//                               return buildReportCard(context, report);
//                             }).toList(),
//                           );
//                         },
//                       );
//                     }
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

// int parseScore(dynamic score) {
//   if (score == null) return 0;
//   if (score is int) return score;
//   if (score is double) return score.round();
//   if (score is String) return int.tryParse(score) ?? 0;
//   return 0;
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/fullscreen_image_viewer.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'dart:convert';

import 'reportDetails.dart';

class LabelPreviousDataScreen extends StatefulWidget {
  const LabelPreviousDataScreen({super.key});

  @override
  _LabelPreviousDataScreenState createState() =>
      _LabelPreviousDataScreenState();
}

class _LabelPreviousDataScreenState extends State<LabelPreviousDataScreen> {
  late Future<List<dynamic>> futureReports;
  List<dynamic> allReports = [];
  List<dynamic> filteredReports = [];
  final TextEditingController _searchController = TextEditingController();

  String backendUrl = "http://localhost:3000";

  @override
  void initState() {
    super.initState();
    futureReports = fetchReports();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<dynamic>> fetchReports() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = userDetails['phoneNumber'];

      if (professionalId == null) {
        throw Exception('Professional ID not found');
      }

      // Get reports directly using the working endpoint
      final uri = Uri.parse('$backendUrl/api/reports/get-professional-reports')
          .replace(queryParameters: {'professionalId': professionalId});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          allReports = (data as List).map<Map<String, dynamic>>((report) {
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
              '_id': report['_id'],
              'childsName': report['childsName'] ?? 'N/A',
              'age': report['age'],
              'score': displayScore,
              'manualScore': manualScore,
              'modelScore': modelScore,
              'flagforlabel': report['flagforlabel'] == true,
              'submittedAt': report['submittedAt'],
              'schoolName': schoolName,
              'schoolId':
                  report['schoolId'] is Map ? report['schoolId']['_id'] : null,
            };
          }).toList();

          filteredReports = [...allReports];
          print('Fetched reports count: ${filteredReports.length}');
        });

        return allReports;
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching reports: $e');
      setState(() {
        filteredReports = [];
      });
      return [];
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredReports = allReports;
      } else {
        filteredReports = allReports.where((report) {
          final name = (report['childsName'] ?? '').toString().toLowerCase();
          final id = (report['_id'] ?? '').toString().toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }
    });
  }

  Map<String, List<dynamic>> groupReportsByChild(List<dynamic> reports) {
    final Map<String, List<dynamic>> grouped = {};

    for (var report in reports) {
      final name = report['childsName'] ?? '';
      final age = report['age'] is int ? report['age'].toString() : 'N/A';
      final key = "$name ($age)";
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]?.add(report);
    }

    return grouped;
  }

  Widget buildReportCard(BuildContext context, dynamic report) {
    final name = report['childsName'] ?? 'N/A';
    final age = report['age'] is int ? report['age'].toString() : 'N/A';
    final submittedAt = report['submittedAt'] != null
        ? DateTime.parse(report['submittedAt']).toLocal()
        : null;

    final shortDate = submittedAt?.toString().split(" ").first ?? 'N/A';
    final score = report['score'] != null ? report['score'].toString() : 'N/A';
    final manualScore = report['manualScore'];
    final modelScore = report['modelScore'];
    final flagged = report['flagforlabel'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: 1.0,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
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
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Child: $name",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (flagged) Icon(Icons.warning, color: Colors.redAccent),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Age: $age",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    "Submitted At: $shortDate",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  // Display image if imagePath exists in buildReportCard
                  // Display image with tap-to-zoom using Hero and FullscreenImageViewer
                  if (report['imagePath'] != null &&
                      report['imagePath'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullscreenImageViewer(
                                imageUrl: 'http://localhost:3000/' +
                                    report['imagePath'],
                                heroTag: report['imagePath'], // unique tag
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: report['imagePath'],
                          child: Image.network(
                            'http://localhost:3000/' + report['imagePath'],
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Text('Image not found'),
                          ),
                        ),
                      ),
                    ),

                  // Updated score display
                  Text(
                    manualScore != null
                        ? "Manual Score: $score"
                        : modelScore != null
                            ? "Model Score: $score"
                            : "Score: N/A",
                    style: TextStyle(
                        color: score == 'N/A'
                            ? Colors.grey
                            : score == '0'
                                ? Colors.orange
                                : Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          "Label Previous Data",
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by name or report ID",
                  hintStyle: TextStyle(fontSize: 15),
                  prefixIcon: Icon(Icons.search_outlined),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Expanded(
                child: FutureBuilder(
                  future: futureReports,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error fetching reports."));
                    } else if (_searchController.text.isNotEmpty &&
                        filteredReports.isEmpty) {
                      return Center(child: Text("No match found."));
                    } else if (filteredReports.isEmpty) {
                      return Center(child: Text("No reports available."));
                    } else {
                      final grouped = groupReportsByChild(filteredReports);

                      return ListView.builder(
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, index) {
                          final key = grouped.keys.elementAt(index);
                          final reportsInGroup = grouped[key]!;
                          return ExpansionTile(
                            tilePadding: EdgeInsets.symmetric(horizontal: 8),
                            title: Text(
                              key,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            subtitle: Text(
                              "${reportsInGroup.length} ${reportsInGroup.length == 1 ? 'submission' : 'submissions'}",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            children: reportsInGroup.map((report) {
                              return buildReportCard(context, report);
                            }).toList(),
                          );
                        },
                      );
                    }
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
  if (score is int) return score;
  if (score is double) return score.round();
  if (score is String) return int.tryParse(score) ?? 0;
  return 0;
}
