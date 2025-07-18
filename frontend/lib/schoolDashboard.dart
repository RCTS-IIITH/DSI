import 'package:flutter/material.dart';
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/schoolLogin.dart';
import 'package:mindseye/selectChild.dart';
import 'package:mindseye/submissionStatus.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class SchoolDashboardScreen extends StatefulWidget {
  final String data;

  const SchoolDashboardScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _SchoolDashboardScreenState createState() => _SchoolDashboardScreenState();
}

class _SchoolDashboardScreenState extends State<SchoolDashboardScreen>
    with SingleTickerProviderStateMixin {
  Map<String, String> userDetails = {
    'role': 'Guest',
    'phoneNumber': 'N/A',
    'name': 'Unknown'
  };

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  int _todaySubmissions = 0;
  bool _isLoadingSubmissions = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _fetchSchoolSubmissions();

    // Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  Future<void> _loadUserDetails() async {
    final details = await SharedPrefsHelper.getUserDetails();
    setState(() {
      userDetails = {
        'role': details['role'] ?? 'Guest',
        'phoneNumber': details['phoneNumber'] ?? 'N/A',
        'name': details['name'] ?? 'Unknown', // 👈 Now used below
      };
    });
  }

  Future<void> _fetchSchoolSubmissions() async {
    setState(() => _isLoadingSubmissions = true);
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final schoolId = userDetails['schoolId']; // or however you store it
      final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3000";
      final today = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(today);

      final uri = Uri.parse('$backendUrl/api/reports/get-school-submissions')
          .replace(queryParameters: {
        'schoolId': schoolId,
        'date': dateStr,
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _todaySubmissions = data['count'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching school submissions: $e");
    } finally {
      setState(() => _isLoadingSubmissions = false);
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: userDetails),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => ScaleTransition(
        scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        child: AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await SharedPrefsHelper.clearUserDetails();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SchoolLoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 🚫 Disable system back press
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          automaticallyImplyLeading: false, // 👈 Hides back arrow
          title: Row(
            children: [
              Icon(Icons.home, color: Colors.white), // Optional home icon
              SizedBox(width: 8),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, size: 30, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(userData: userDetails),
                  ),
                );
              },
              tooltip: "Edit Profile",
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              onPressed: _logout,
              tooltip: "Logout",
            ),
            SizedBox(width: 16),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧾 User Info Card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              'Role: ${userDetails['role']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Text(
                              'Phone: ${userDetails['phoneNumber']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Capture Child's Drawing
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildButton("Capture Child's Drawing", context),
                ),
                SizedBox(height: 16),

                // View Submission Status
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildButton("View Submission Status", context),
                ),
                SizedBox(height: 16),

                // Logout Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildButton("Logout", context),
                ),

                Spacer(),

                // Image submission count (optional feature)
                Align(
                  alignment: Alignment.center,
                  child: _isLoadingSubmissions
                      ? CircularProgressIndicator()
                      : Text(
                          '$_todaySubmissions images submitted today',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (text == "Capture Child's Drawing") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectChildScreen(
                  data: widget.data,
                  phone: userDetails['phoneNumber'] ?? '',
                  role: "Teacher",
                ),
              ),
            );
          } else if (text == "View Submission Status") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmissionStatusScreen(),
              ),
            );
          } else if (text == "Logout") {
            _logout();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
