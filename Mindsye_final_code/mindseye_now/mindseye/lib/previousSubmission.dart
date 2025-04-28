import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For environment variables
import 'package:mindseye/shared_prefs_helper.dart'; // Import SharedPreferences helper

class PreviousSubmissionsScreen extends StatefulWidget {
  final String data; // Role of the user
  final String phone;

  const PreviousSubmissionsScreen({
    Key? key,
    required this.data,
    required this.phone,
  }) : super(key: key);

  @override
  _PreviousSubmissionsScreenState createState() =>
      _PreviousSubmissionsScreenState();
}

class _PreviousSubmissionsScreenState extends State<PreviousSubmissionsScreen> {
  List<dynamic> submissionSummary = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissionSummary();
  }

  Future<void> fetchSubmissionSummary() async {
    try {
      // Fetch user details from SharedPreferences
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final role = userDetails['role'] ?? '';
      final phone = userDetails['phoneNumber'] ?? '';

      // Debugging: Print retrieved user details
      print("Retrieved User Details: $userDetails");

      // Validate role
      if (role.isEmpty) {
        throw Exception("Role cannot be empty");
      }

      // Construct the API URL
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      final uri = Uri.http(
        Uri.parse(backendUrl).authority,
        '/api/users/get-submission-summary',
        {
          'role': role,
          if (role == "Parent") 'phone': phone,
        },
      );

      // Debugging: Print constructed URL
      print("Fetching submission summary from: $uri");

      // Make the API call
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          submissionSummary = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load submission summary: ${response.body}");
      }
    } catch (e) {
      print("Error fetching submission summary: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Submissions'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissionSummary.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  itemCount: submissionSummary.length,
                  itemBuilder: (context, index) {
                    final childSummary = submissionSummary[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 2.0,
                      child: ListTile(
                        title:
                            Text(childSummary['childsName'] ?? 'Unknown Child'),
                        subtitle: Text(
                            '${childSummary['submissionCount']} submissions'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildSubmissionsScreen(
                                role: widget.data,
                                phone: widget.phone,
                                childsName: childSummary['childsName'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class ChildSubmissionsScreen extends StatefulWidget {
  final String role;
  final String? phone;
  final String childsName;

  const ChildSubmissionsScreen({
    Key? key,
    required this.role,
    this.phone,
    required this.childsName,
  }) : super(key: key);

  @override
  _ChildSubmissionsScreenState createState() => _ChildSubmissionsScreenState();
}

class _ChildSubmissionsScreenState extends State<ChildSubmissionsScreen> {
  List<dynamic> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    try {
      // Retrieve user details from SharedPreferences
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final role = userDetails['role'] ?? '';
      final phone = userDetails['phoneNumber'] ?? '';

      // Validate role
      if (role.isEmpty) {
        throw Exception("Role cannot be empty");
      }

      // Construct the API URL
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      final uri = Uri.http(
        Uri.parse(backendUrl).authority,
        '/api/users/get-submissions-by-child',
        {
          'role': role,
          if (role == "Parent") 'phone': phone,
          'childsName': widget.childsName,
        },
      );

      // Debugging: Print constructed URL
      print("Fetching submissions for child from: $uri");

      // Make the API call
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          submissions = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load submissions: ${response.body}");
      }
    } catch (e) {
      print("Error fetching submissions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.childsName}'s Submissions"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final submission = submissions[index];
                    final formattedDate = DateFormat.yMd()
                        .add_jm()
                        .format(DateTime.parse(submission['submittedAt']));
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      elevation: 2.0,
                      child: ExpansionTile(
                        title:
                            Text(submission['childsName'] ?? 'Unknown Child'),
                        subtitle: Text('Submitted At: $formattedDate'),
                        children: [
                          ListTile(
                            title: Text('Age: ${submission['age'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text(
                                'Clinic Name: ${submission['clinicsName'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text(
                                'Optional Notes: ${submission['optionalNotes'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text(
                                'Flag for Label: ${submission['flagforlabel'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text(
                                'Labelling Score: ${submission['labelling'] ?? 'N/A'}'),
                          ),
                          ListTile(
                            title: Text(
                                'Image URL: ${submission['imageurl'] ?? 'N/A'}'),
                          ),
                          ExpansionTile(
                            title: Text('House Answers'),
                            children: [
                              ListTile(
                                title: Text(
                                    'Who Lives Here: ${submission['houseAns']['WhoLivesHere'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Are They Happy: ${submission['houseAns']['ArethereHappy'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Do People Visit Here: ${submission['houseAns']['DoPeopleVisitHere'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'What Else Do They Want: ${submission['houseAns']['Whatelsepeoplewant'] ?? 'N/A'}'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('Person Answers'),
                            children: [
                              ListTile(
                                title: Text(
                                    'Who is This Person: ${submission['personAns']['Whoisthisperson'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'How Old Are They: ${submission['personAns']['Howoldarethey'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'What is Their Favorite Thing: ${submission['personAns']['Whatsthierfavthing'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'What Do They Dislike: ${submission['personAns']['Whattheydontlike'] ?? 'N/A'}'),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('Tree Answers'),
                            children: [
                              ListTile(
                                title: Text(
                                    'What Kind of Tree: ${submission['treeAns']['Whatkindoftree'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'How Old Is It: ${submission['treeAns']['howoldisit'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'What Season Is It: ${submission['treeAns']['whatseasonisit'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Has Anyone Tried to Cut It Down: ${submission['treeAns']['anyonetriedtocut'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'What Else Grows Nearby: ${submission['treeAns']['whatelsegrows'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Who Waters It: ${submission['treeAns']['whowaters'] ?? 'N/A'}'),
                              ),
                              ListTile(
                                title: Text(
                                    'Does It Get Enough Sunshine: ${submission['treeAns']['doesitgetenoughsunshine'] ?? 'N/A'}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
