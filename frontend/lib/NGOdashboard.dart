import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/assignadmintoschool.dart';
import 'package:mindseye/createProfessionalAccount.dart';
import 'package:mindseye/createSchoolAccount.dart';
import 'package:mindseye/createadminaccount.dart';
import 'package:mindseye/login.dart';
import 'package:mindseye/AssignSchoolToProfessionalScreen.dart';
import 'package:mindseye/uploadChildDetails.dart';
import 'package:mindseye/uploadTeacherDetails.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class NGODashboard extends StatefulWidget {
  final String data;

  const NGODashboard({Key? key, required this.data}) : super(key: key);

  @override
  _NGODashboardState createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> {
  bool _isCreateExpanded = false;
  bool _isAssignExpanded = false;
  bool _isManageExpanded = false;
  String _userName = 'Loading...';
  bool _isLoading = true;
  int _schoolCount = 0;
  int _todaySubmissions = 0;
  int _totalSubmissions = 0;
  bool _isLoadingSubmissions = false;
  String? _submissionError;
  Map<String, String> userDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchAssignedSchools();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    if (_isLoadingSubmissions) return;

    setState(() {
      _isLoadingSubmissions = true;
      _submissionError = null;
    });

    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final ngoAdminPhone = userDetails['phoneNumber'];

      final now = DateTime.now();
      final today =
          DateTime(now.year, now.month, now.day).toUtc().toIso8601String();

      final uri = Uri.parse(
              '${dotenv.env['BACKEND_URL']}/api/reports/get-ngo-submissions')
          .replace(queryParameters: {
        'ngoAdminPhone': ngoAdminPhone,
        'date': today,
      });

      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _todaySubmissions = data['todayCount'] ?? 0;
          _totalSubmissions = data['totalCount'] ?? 0;
        });
      } else {
        throw Exception('Failed to fetch submissions');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submissionError = e.toString());
      print('Error fetching submissions: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubmissions = false);
      }
    }
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/search-number'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usertype': 'NGO Master',
          'number': widget.data,
        }),
      );
      print("Backend Response Status: ${response.statusCode}");
      print("Backend Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _userName = userData['name'] ?? 'Unknown Admin';
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'Error';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Network Error';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAssignedSchools() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final phone = userDetails['phoneNumber'] ?? "";
      final backendUrl = dotenv.env['BACKEND_URL'] ?? "";

      if (phone.isEmpty || backendUrl.isEmpty) return;

      final response = await http.get(
        Uri.parse('$backendUrl/api/users/get-admins?phone=$phone'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        List<String> schools = [];

        final assignedSchoolList = userData['assignedSchoolList'];
        if (assignedSchoolList is String) {
          schools = assignedSchoolList
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (assignedSchoolList is List) {
          schools = List<String>.from(assignedSchoolList);
        }

        setState(() {
          _schoolCount = schools.length;
        });
      }
    } catch (e) {
      print("Error fetching school list: $e");
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: Navigator.of(context).pop, child: Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.home, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Home',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $_userName',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Manage your organization with ease',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 32),
                      _buildCollapsibleSection(
                        title: "Create User",
                        icon: Icons.person_add,
                        isExpanded: _isCreateExpanded,
                        onToggle: () => setState(
                            () => _isCreateExpanded = !_isCreateExpanded),
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActionCard(
                              context,
                              title: "Professional",
                              icon: Icons.person_outline,
                              onTap: () => _navigateTo(
                                  context, CreateProfessionalAccount()),
                            ),
                            _buildActionCard(
                              context,
                              title: "Admin",
                              icon: Icons.admin_panel_settings,
                              onTap: () => _navigateTo(
                                  context, CreateAdminAccountScreen()),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildActionCard(
                        context,
                        title: "Create School",
                        icon: Icons.school,
                        onTap: () =>
                            _navigateTo(context, CreateSchoolAccount()),
                        color: Colors.green.withOpacity(0.1),
                      ),
                      SizedBox(height: 20),
                      _buildCollapsibleSection(
                        title: "Assign User",
                        icon: Icons.assignment_ind,
                        isExpanded: _isAssignExpanded,
                        onToggle: () => setState(
                            () => _isAssignExpanded = !_isAssignExpanded),
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActionCard(
                              context,
                              title: "School to Professional",
                              icon: Icons.link,
                              onTap: () => _navigateTo(
                                  context, AssignSchoolToProfessionalScreen()),
                            ),
                            _buildActionCard(
                              context,
                              title: "Admin to School",
                              icon: Icons.assignment_turned_in,
                              onTap: () => _navigateTo(
                                  context, AssignSchoolToAdminScreen()),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildManageSchoolsSection(),
                      Spacer(),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.image,
                                      color: Colors.blue, size: 20),
                                  SizedBox(width: 8),
                                  _isLoadingSubmissions
                                      ? SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : _submissionError != null
                                          ? Text(
                                              "Error loading submissions",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14),
                                            )
                                          : Text(
                                              "$_todaySubmissions ${_todaySubmissions == 1 ? 'image' : 'images'} submitted today",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                ],
                              ),
                              if (!_isLoadingSubmissions &&
                                  _submissionError == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Total submissions: $_totalSubmissions",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200]?.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.blue),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildManageSchoolsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200]?.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _isManageExpanded = !_isManageExpanded;
              });
            },
            child: SizedBox(
              width: double.infinity, // 👈 Ensure full width tap area
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.school, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Manage Schools",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isManageExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isManageExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionCard(
                    context,
                    title: "Upload Child Details ($_schoolCount schools)",
                    icon: Icons.child_care,
                    onTap: () {
                      if (_schoolCount == 0) {
                        _showSnackBar("No schools assigned.");
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UploadChildDetails(role: "NGOAdmin"),
                        ),
                      );
                    },
                    color: Colors.pink.withOpacity(0.1),
                  ),
                  _buildActionCard(
                    context,
                    title: "Upload Teacher Details ($_schoolCount schools)",
                    icon: Icons.school,
                    onTap: () {
                      if (_schoolCount == 0) {
                        _showSnackBar("No schools assigned.");
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UploadTeacherDetails(role: "NGOAdmin"),
                        ),
                      );
                    },
                    color: Colors.orange.withOpacity(0.1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.transparent,
  }) {
    final cardWidth = MediaQuery.of(context).size.width < 600
        ? double.infinity
        : (MediaQuery.of(context).size.width - 64) / 2;

    return SizedBox(
      width: cardWidth,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: Colors.grey[700]),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
