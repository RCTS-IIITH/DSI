import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/assignadmintoschool.dart';
import 'package:mindseye/createProfessionalAccount.dart';
import 'package:mindseye/createSchoolAccount.dart';
import 'package:mindseye/createadminaccount.dart';
import 'package:mindseye/AssignSchoolToProfessionalScreen.dart';
import 'package:mindseye/unified_login_screen.dart';
import 'package:mindseye/uploadChildDetails.dart';
import 'package:mindseye/uploadTeacherDetails.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:mindseye/createOrganizationAccount.dart';
import 'package:mindseye/organizationList.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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
  bool _isCreateSchoolExpanded = false; // For new "Create School" section
  bool _isOrganizationExpanded = false; // For organization management section
  String _userName = 'Loading...';
  bool _isLoading = true;
  int _schoolCount = 0;
  int _todaySubmissions = 0;
  int _totalSubmissions = 0;
  bool _isLoadingSubmissions = false;
  String? _submissionError;
  Map<String, String> userDetails = {};
  List<String> _assignedSchoolNames = [];

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
          _assignedSchoolNames = schools;
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

  Future<void> _deleteSchoolByName(String schoolName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete School'),
        content: Text('Delete "$schoolName"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
      if (backendUrl.isEmpty) return _showSnackBar('Missing backend URL');
      // Find school id by name
      final schoolsRes = await http.get(Uri.parse('$backendUrl/api/users/get-schools'));
      if (schoolsRes.statusCode != 200) return _showSnackBar('Failed to load schools');
      final body = jsonDecode(schoolsRes.body);
      final List list = (body is Map && body['data'] is List) ? body['data'] : body as List;
      final match = list.firstWhere(
        (e) => (e['schoolName'] ?? '') == schoolName,
        orElse: () => null,
      );
      if (match == null) return _showSnackBar('School not found');
      final id = match['_id'];
      final delRes = await http.delete(Uri.parse('$backendUrl/api/users/delete-school/$id'));
      if (delRes.statusCode == 200) {
        _showSnackBar('School deleted');
        _fetchAssignedSchools();
        _fetchSubmissions();
      } else {
        final err = delRes.body;
        _showSnackBar('Delete failed: $err');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _unassignProfessionalPrompt(String schoolName) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unassign Professional'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter ProfessionalID to unassign from this school'),
            const SizedBox(height: 8),
            TextField(controller: controller, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'ProfessionalID')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unassign')),
        ],
      ),
    );
    if (ok != true) return;
    final proId = controller.text.trim();
    if (proId.isEmpty) return _showSnackBar('ProfessionalID required');
    final backendUrl = dotenv.env['BACKEND_URL'] ?? '';
    final res = await http.post(
      Uri.parse('$backendUrl/api/users/unassign-professional-from-school'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'professionalId': proId, 'schoolName': schoolName}),
    );
    if (res.statusCode == 200) {
      _showSnackBar('Professional unassigned');
    } else {
      _showSnackBar('Failed to unassign professional');
    }
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
              onPressed: Navigator.of(context).pop,
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => UnifiedLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndUnassignAdmin(String schoolName) async {
    final phone = (await SharedPrefsHelper.getUserDetails())['phoneNumber'] ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unassign School'),
        content: Text('Unassign you from "$schoolName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unassign')),
        ],
      ),
    );
    if (ok != true) return;
    final backendUrl = dotenv.env['BACKEND_URL'] ?? 'http://localhost:3001';
    final res = await http.post(
      Uri.parse('$backendUrl/api/users/unassign-admin-from-school'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'adminNumber': phone, 'schoolName': schoolName}),
    );
    if (res.statusCode == 200) {
      _showSnackBar('Unassigned from $schoolName');
      _fetchAssignedSchools();
      _fetchSubmissions();
    } else {
      _showSnackBar('Failed to unassign');
    }
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
                      // Organization filter bar
                      FutureBuilder<Map<String, String>>(
                        future: SharedPrefsHelper.getUserDetails(),
                        builder: (context, snapshot) {
                          final selectedOrgId =
                              snapshot.data?['selectedOrganizationId'] ?? '';
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Navigate to organization list to pick, or reuse list screen
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OrganizationListScreen(),
                                      ),
                                    );
                                    // After returning, refresh assigned schools and submissions
                                    _fetchAssignedSchools();
                                    _fetchSubmissions();
                                  },
                                  icon: Icon(Icons.filter_list),
                                  label: Text(
                                    selectedOrgId.isEmpty
                                        ? 'Select Organization'
                                        : 'Org Selected',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 16),
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

                      // ✅ Create User
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

                      // ✅ Create School (Now collapsible)
                      _buildCollapsibleSection(
                        title: "Create School",
                        icon: Icons.school,
                        isExpanded: _isCreateSchoolExpanded,
                        onToggle: () => setState(() =>
                            _isCreateSchoolExpanded = !_isCreateSchoolExpanded),
                        content: Wrap(
                          children: [
                            _buildActionCard(
                              context,
                              title: "New School",
                              icon: Icons.add,
                              onTap: () =>
                                  _navigateTo(context, CreateSchoolAccount()),
                              color: Colors.green.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // ✅ Organization Management
                      _buildCollapsibleSection(
                        title: "Organization Management",
                        icon: Icons.business,
                        isExpanded: _isOrganizationExpanded,
                        onToggle: () => setState(() =>
                            _isOrganizationExpanded = !_isOrganizationExpanded),
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActionCard(
                              context,
                              title: "Create Organization",
                              icon: Icons.add_business,
                              onTap: () => _navigateTo(
                                  context, CreateOrganizationAccount()),
                              color: Colors.purple.withOpacity(0.1),
                            ),
                            _buildActionCard(
                              context,
                              title: "View Organizations",
                              icon: Icons.list,
                              onTap: () => _navigateTo(
                                  context, OrganizationListScreen()),
                              color: Colors.indigo.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // ✅ Assign User
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
                              title: "School → Pro",
                              icon: Icons.link,
                              onTap: () => _navigateTo(
                                  context, AssignSchoolToProfessionalScreen()),
                            ),
                            _buildActionCard(
                              context,
                              title: "Admin → School",
                              icon: Icons.assignment_turned_in,
                              onTap: () => _navigateTo(
                                  context, AssignSchoolToAdminScreen()),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // ✅ Manage Schools (Now consistent)
                      _buildCollapsibleSection(
                        title: "Manage Schools",
                        icon: Icons.school,
                        isExpanded: _isManageExpanded,
                        onToggle: () => setState(
                            () => _isManageExpanded = !_isManageExpanded),
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActionCard(
                              context,
                              title: "Upload Child ($_schoolCount)",
                              icon: Icons.child_care,
                              onTap: () {
                                if (_schoolCount == 0) {
                                  _showSnackBar("No schools assigned.");
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        UploadChildDetails(role: "NGOAdmin"),
                                  ),
                                );
                              },
                              color: Colors.pink.withOpacity(0.1),
                            ),
                            _buildActionCard(
                              context,
                              title: "Upload Teacher ($_schoolCount)",
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

                      Spacer(),

                      // ✅ Submissions Card
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

  // ✅ Reusable collapsible section
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

  // ✅ Responsive action card with max width
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.transparent,
  }) {
    final maxWidth = 300.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth < 600 ? double.infinity : maxWidth,
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
