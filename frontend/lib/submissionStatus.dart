// import 'package:flutter/material.dart';

// class SubmissionStatusScreen extends StatefulWidget {
//   const SubmissionStatusScreen({super.key});

//   @override
//   _SubmissionStatusScreenState createState() => _SubmissionStatusScreenState();
// }

// class _SubmissionStatusScreenState extends State<SubmissionStatusScreen> {
//   final List<Map<String, String>> submissions = [
//     {'name': 'Student A', 'status': 'Submitted'},
//     {'name': 'Student B', 'status': 'Processing'},
//     {'name': 'Student C', 'status': 'Report is Ready'},
//     {'name': 'Student D', 'status': 'Sent to Professional'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Submission Status'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Submission Status',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: submissions.length,
//                 itemBuilder: (context, index) {
//                   final submission = submissions[index];
//                   return ListTile(
//                     leading: Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     title: Text(
//                       submission['name']!,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     subtitle: Text(submission['status']!),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SubmissionStatusScreen extends StatefulWidget {
  const SubmissionStatusScreen({super.key});

  @override
  _SubmissionStatusScreenState createState() => _SubmissionStatusScreenState();
}

class _SubmissionStatusScreenState extends State<SubmissionStatusScreen> {
  List<Map<String, dynamic>> submissions = [];
  List<dynamic> filteredSubmissions = [];

  bool isLoading = true;
  String? error;

  String backendUrl = dotenv.env['BACKEND_URL']!;

  String _searchQuery = '';
  String _selectedStatusFilter = 'All';
  String _sortOrder = 'Newest First'; // or 'Oldest First'

  final statusOptions = [
    'All',
    'Manually Scored',
    'Model Score Ready',
    'Pending Manual Review',
    'Processing'
  ];

  final sortOptions = ['Newest First', 'Oldest First'];

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    try {
      setState(() => isLoading = true);

      final uri = Uri.parse('$backendUrl/api/reports/get-report-data-clinic');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          submissions =
              List<Map<String, dynamic>>.from(data.map((submission) => {
                    'id': submission['_id'],
                    'name': submission['childsName'] ?? 'N/A',
                    'status': _getSubmissionStatus(submission),
                    'submittedAt': submission['submittedAt'],
                    'modelScore': submission['score'],
                    'manualScore': submission['manualScore'],
                    'labeledBy': submission['labeledBy'],
                    'labeledAt': submission['labeledAt'],
                    'flagforlabel': submission['flagforlabel'],
                  }));

          _applyFiltersAndSorting();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFiltersAndSorting() {
    filteredSubmissions = submissions.where((submission) {
      final matchesSearch =
          submission['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatusFilter == 'All' ||
          submission['status'] == _selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    if (_sortOrder == 'Newest First') {
      filteredSubmissions.sort((a, b) => DateTime.parse(b['submittedAt'])
          .compareTo(DateTime.parse(a['submittedAt'])));
    } else {
      filteredSubmissions.sort((a, b) => DateTime.parse(a['submittedAt'])
          .compareTo(DateTime.parse(b['submittedAt'])));
    }

    setState(() {});
  }

  String _getSubmissionStatus(Map<String, dynamic> submission) {
    if (submission['manualScore'] != null) {
      return 'Manually Scored';
    } else if (submission['score'] != null) {
      return 'Model Score Ready';
    } else if (submission['flagforlabel'] == true) {
      return 'Pending Manual Review';
    } else {
      return 'Processing';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Manually Scored':
        return Colors.green;
      case 'Model Score Ready':
        return Colors.blue;
      case 'Pending Manual Review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Submission Status', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: fetchSubmissions),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchSubmissions,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                        _applyFiltersAndSorting();
                      },
                      decoration: InputDecoration(
                        labelText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedStatusFilter,
                    onChanged: (value) {
                      _selectedStatusFilter = value!;
                      _applyFiltersAndSorting();
                    },
                    items: statusOptions
                        .map((status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      '${filteredSubmissions.length} Submissions',
                      key: ValueKey(filteredSubmissions.length),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortOrder,
                    onChanged: (value) {
                      _sortOrder = value!;
                      _applyFiltersAndSorting();
                    },
                    items: sortOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.blue),
                      SizedBox(height: 10),
                      Text("Loading submissions..."),
                    ],
                  ),
                )
              else if (error != null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error!),
                      ElevatedButton(
                        onPressed: fetchSubmissions,
                        child: Text("Retry"),
                      )
                    ],
                  ),
                )
              else if (filteredSubmissions.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('No submissions found'),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredSubmissions.length,
                    itemBuilder: (context, index) {
                      final submission = filteredSubmissions[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _getStatusColor(submission['status']),
                            child: Text(
                              submission['name'][0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            submission['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(submission['status'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        _getStatusColor(submission['status']),
                                  ),
                                ),
                                child: Text(
                                  submission['status'],
                                  style: TextStyle(
                                    color:
                                        _getStatusColor(submission['status']),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat('MMM d, y').format(
                                    DateTime.parse(submission['submittedAt']),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_drop_down),
                          children: [
                            ListTile(
                              title: Text('Model Score'),
                              subtitle: Text(
                                '${submission['modelScore']?.toString() ?? 'Processing...'}%',
                              ),
                            ),
                            if (submission['manualScore'] != null)
                              ListTile(
                                title: Text('Manual Score'),
                                subtitle: Text(
                                  '${submission['manualScore']}%\nLabeled by: ${submission['labeledBy']}\non ${DateFormat('MMM d, y').format(DateTime.parse(submission['labeledAt']))}',
                                ),
                              ),
                          ],
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
