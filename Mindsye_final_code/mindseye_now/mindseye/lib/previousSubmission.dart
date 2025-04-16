import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PreviousSubmissionsScreen extends StatefulWidget {
  final String data;
  final String phone;
  final String role;

  const PreviousSubmissionsScreen({
    super.key,
    required this.data,
    required this.phone,
    required this.role,
  });

  @override
  _PreviousSubmissionsScreenState createState() =>
      _PreviousSubmissionsScreenState();
}

class _PreviousSubmissionsScreenState extends State<PreviousSubmissionsScreen> {
  List<dynamic> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    final role = widget.role;
    final phone = widget.phone;
    final url =
        'http://localhost:3000/api/reports/get-submissions?role=$role&phone=$phone';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          submissions = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load submissions');
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
        title: const Text('Previous Submissions'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions found"))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: submission['imageUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        submission['imageUrl'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  submission['childName'] ?? 'Unknown Child',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  submission['submittedAt'] != null
                                      ? DateTime.parse(
                                              submission['submittedAt'])
                                          .toLocal()
                                          .toString()
                                          .split(' ')
                                          .first
                                      : '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
