import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/selectChild.dart';
import 'package:mindseye/previousSubmission.dart';
import 'package:mindseye/schoolLogin.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:flutter/foundation.dart';

class ParentDashboardScreen extends StatefulWidget {
  final String data;
  final String phone;

  const ParentDashboardScreen({
    super.key,
    required this.data,
    required this.phone,
  });

  @override
  _ParentDashboardScreenState createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _error;
  int imagesSubmittedToday = 0;
  Map<String, String> userDetails = {'role': 'Guest', 'phoneNumber': 'N/A'};
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Handle async operations
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserDetails();
    if (mounted) {
      await _fetchTodaysSubmissions();
    }
  }

  Future<void> _fetchTodaysSubmissions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final parentPhone = userDetails['phoneNumber'];

      if (parentPhone == null) {
        throw Exception('Phone number not found');
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day).toIso8601String();

      final uri = Uri.parse(
              '${dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000'}/api/reports/get-parent-submissions')
          .replace(queryParameters: {
        'parentPhone': parentPhone,
        'date': today,
      });

      final response = await http.get(uri);

      if (!mounted) return; // Add this check

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          imagesSubmittedToday = data['count'] ?? 0;
        });
      } else {
        throw Exception('Failed to fetch submissions: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return; // Add this check
      setState(() => _error = e.toString());
      print('Error fetching submissions: $e');
    } finally {
      if (mounted) {
        // Add this check
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserDetails() async {
    final details = await SharedPrefsHelper.getUserDetails();
    setState(() {
      userDetails = details;
    });
  }

  void _captureChildDrawing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChildScreen(
          data: "Parent",
          phone: widget.phone,
          role: "Parent",
        ),
      ),
    );
  }

  void _viewPreviousStatus() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviousSubmissionsScreen(
          data: widget.data,
          phone: widget.phone,
        ),
      ),
    );
  }

  void _logout() {
    showLogoutDialog(context);
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: userDetails),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
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
      onWillPop: () async => false,
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
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _fetchTodaysSubmissions,
              tooltip: "Refresh count",
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
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
                        const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideInAnimation(
                    delay: Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _captureChildDrawing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Capture Child's Drawing",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideInAnimation(
                    delay: Duration(milliseconds: 400),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _viewPreviousStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "View Previous Status",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideInAnimation(
                    delay: Duration(milliseconds: 500),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Image Submission Count
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : _error != null
                          ? Text(
                              'Error loading submissions',
                              style: TextStyle(color: Colors.red),
                            )
                          : Text(
                              '$imagesSubmittedToday ${imagesSubmittedToday == 1 ? "image" : "images"} submitted today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🎨 Helper Widgets

class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const SlideInAnimation({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: 100.0, end: 0.0),
      builder: (BuildContext context, double val, __) {
        return Transform.translate(
          offset: Offset(val, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}
