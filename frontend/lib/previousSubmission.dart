import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class PreviousSubmissionsScreen extends StatefulWidget {
  final String data;
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
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final role = userDetails['role'] ?? '';
      final phone = userDetails['phoneNumber'] ?? '';
      if (role.isEmpty) throw Exception("Role cannot be empty");
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      final uri = Uri.http(
        Uri.parse(backendUrl).authority,
        '/api/users/get-submission-summary',
        {
          'role': role,
          if (role == "Parent") 'phone': phone,
        },
      );
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
      setState(() => isLoading = false);
    }
  }

  Widget buildChildSummaryCard(String name, int count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.child_care, color: Colors.blue[800]),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text('$count submissions'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildSubmissionsScreen(
                role: widget.data,
                phone: widget.phone,
                childsName: name,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Submissions'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissionSummary.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  itemCount: submissionSummary.length,
                  itemBuilder: (context, index) {
                    final childSummary = submissionSummary[index];
                    return buildChildSummaryCard(
                      childSummary['childsName'] ?? 'Unknown Child',
                      childSummary['submissionCount'] ?? 0,
                    );
                  },
                ),
    );
  }
}

// -------------------- ChildSubmissionsScreen --------------------

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

class _ChildSubmissionsScreenState extends State<ChildSubmissionsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> submissions = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fetchSubmissions().then((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchSubmissions() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final role = userDetails['role'] ?? '';
      final phone = userDetails['phoneNumber'] ?? '';
      if (role.isEmpty) throw Exception("Role cannot be empty");
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
      setState(() => isLoading = false);
    }
  }

  Widget buildQuestionItem(String question, String? answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            answer ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget buildStyledExpansionTile({
    required String title,
    required IconData icon,
    required Map<String, dynamic> answers,
  }) {
    final List<Widget> answerWidgets = answers.entries
        .map((entry) => buildQuestionItem(
              entry.key.replaceAll('_', ' '),
              entry.value?.toString(),
            ))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Icon(icon, color: Colors.grey[800]),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: answerWidgets,
        ),
      ),
    );
  }

  Widget buildSubmissionCard(int index) {
    final submission = submissions[index];
    final formattedDate = DateFormat.yMd()
        .add_jm()
        .format(DateTime.parse(submission['submittedAt']));

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval((index / submissions.length), 1.0,
              curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval((index / submissions.length), 1.0,
              curve: Curves.easeOut),
        )),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    submission['childsName'] ?? 'Unknown Child',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text('Submitted At: $formattedDate'),
                ),
                ListTile(
                  title: Text('Age: ${submission['age'] ?? 'N/A'}'),
                ),
                ListTile(
                  title: Text('Image URL: ${submission['imageurl'] ?? 'N/A'}'),
                ),
                buildStyledExpansionTile(
                  title: 'House Answers',
                  icon: Icons.house_rounded,
                  answers: submission['houseAns'],
                ),
                buildStyledExpansionTile(
                  title: 'Person Answers',
                  icon: Icons.person_rounded,
                  answers: submission['personAns'],
                ),
                buildStyledExpansionTile(
                  title: 'Tree Answers',
                  icon: Icons.park_rounded,
                  answers: submission['treeAns'],
                ),
              ],
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
        title: Text("${widget.childsName}'s Submissions"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) => buildSubmissionCard(index),
                ),
    );
  }
}
