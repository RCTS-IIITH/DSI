import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/createadminaccount.dart';
import 'package:mindseye/unified_login_screen.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class OrganizationAdminDashboard extends StatefulWidget {
  final String data;
  const OrganizationAdminDashboard({Key? key, required this.data}) : super(key: key);

  @override
  _OrganizationAdminDashboardState createState() => _OrganizationAdminDashboardState();
}

class _OrganizationAdminDashboardState extends State<OrganizationAdminDashboard> {
  bool _isCreateExpanded = false;
  bool _isManageExpanded = false;
  String _userName = 'Loading...';
  bool _isLoading = true;
  int _ngoAdminCount = 0;
  int _schoolCount = 0;
  int _professionalCount = 0;
  Map<String, String> userDetails = {};
  String? _organizationName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchOrganizationStats();
  }

  Future<void> _fetchUserName() async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/search-number'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usertype': 'OrganizationAdmin',
          'number': widget.data,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _userName = userData['name'] ?? 'Unknown Admin';
          _organizationName = userData['organizationName'] ?? 'Unknown Organization';
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

  Future<void> _fetchOrganizationStats() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final organizationId = userDetails['organizationId'];
      
      if (organizationId == null || organizationId.isEmpty) return;

      final backendUrl = dotenv.env['BACKEND_URL'] ?? "";
      if (backendUrl.isEmpty) return;

      // Get organization stats
      final statsRes = await http.get(
        Uri.parse('$backendUrl/api/organizations/$organizationId/stats'),
      );

      if (statsRes.statusCode == 200) {
        final statsData = jsonDecode(statsRes.body);
        setState(() {
          _schoolCount = statsData['data']['statistics']['schoolsCount'] ?? 0;
          _professionalCount = statsData['data']['statistics']['professionalsCount'] ?? 0;
        });
      }

      // Get NGO Admin count for this organization
      final adminsRes = await http.get(
        Uri.parse('$backendUrl/api/users/get-admins'),
      );

      if (adminsRes.statusCode == 200) {
        final adminsData = jsonDecode(adminsRes.body);
        final admins = List<Map<String, dynamic>>.from(adminsData);
        final orgAdmins = admins.where((admin) => 
          admin['organizationId'] == organizationId && 
          admin['role'] == 'NGOAdmin'
        ).toList();
        
        setState(() {
          _ngoAdminCount = orgAdmins.length;
        });
      }
    } catch (e) {
      print("Error fetching organization stats: $e");
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.business, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Organization Admin',
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
                        'Organization: $_organizationName',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 32),

                      // ✅ Create NGO Admin
                      _buildCollapsibleSection(
                        title: "Create NGO Admin",
                        icon: Icons.person_add,
                        isExpanded: _isCreateExpanded,
                        onToggle: () => setState(
                            () => _isCreateExpanded = !_isCreateExpanded),
                        content: Wrap(
                          children: [
                            _buildActionCard(
                              context,
                              title: "New NGO Admin",
                              icon: Icons.admin_panel_settings,
                              onTap: () => _navigateTo(
                                  context, CreateAdminAccountScreen()),
                              color: Colors.purple.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // ✅ Manage Organization
                      _buildCollapsibleSection(
                        title: "Manage Organization",
                        icon: Icons.manage_accounts,
                        isExpanded: _isManageExpanded,
                        onToggle: () => setState(
                            () => _isManageExpanded = !_isManageExpanded),
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildActionCard(
                              context,
                              title: "NGO Admins ($_ngoAdminCount)",
                              icon: Icons.admin_panel_settings,
                              onTap: () {
                                // TODO: Navigate to NGO Admins list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("NGO Admins list coming soon")),
                                );
                              },
                              color: Colors.blue.withOpacity(0.1),
                            ),
                            _buildActionCard(
                              context,
                              title: "Schools ($_schoolCount)",
                              icon: Icons.school,
                              onTap: () {
                                // TODO: Navigate to Schools list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Schools list coming soon")),
                                );
                              },
                              color: Colors.green.withOpacity(0.1),
                            ),
                            _buildActionCard(
                              context,
                              title: "Professionals ($_professionalCount)",
                              icon: Icons.engineering,
                              onTap: () {
                                // TODO: Navigate to Professionals list
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Professionals list coming soon")),
                                );
                              },
                              color: Colors.orange.withOpacity(0.1),
                            ),
                          ],
                        ),
                      ),

                      Spacer(),

                      // ✅ Organization Stats Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.business,
                                      color: Colors.purple, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Organization Overview",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text("$_ngoAdminCount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("NGO Admins", style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("$_schoolCount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("Schools", style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("$_professionalCount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("Professionals", style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
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
                      Icon(icon, color: Colors.purple),
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
}
