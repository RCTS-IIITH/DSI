import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/unified_login_screen.dart';
import 'package:mindseye/uploadChildDetails.dart';
import 'package:mindseye/uploadTeacherDetails.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:mindseye/schoolScreen.dart';
import 'package:mindseye/schoolAdminManage.dart';

class AdminDashboard extends StatefulWidget {
  final String data;

  const AdminDashboard(
    String mobileNumber, {
    super.key,
    required this.data,
  });

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoadingLogout = false;
  String? _role;
  String? _assignedSchool;
  Map<String, String> userDetails = {};

  @override
  void initState() {
    super.initState();
    _initializeRoleAndSchool();
  }

  Future<void> _initializeRoleAndSchool() async {
    final userDetails = await SharedPrefsHelper.getUserDetails();
    setState(() {
      _role = userDetails['role'];
      _assignedSchool = userDetails['assignedSchool'];
    });
  }

  Future<void> _navigateToUploadScreen(
      BuildContext context, String screenType) async {
    if (_role == null) {
      _showSnackBar("Role not found. Please log in again.");
      return;
    }

    String? assignedSchool;
    if (_role == "SchoolAdmin") {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      assignedSchool = userDetails['assignedSchool'];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screenType == 'child'
            ? UploadChildDetails(role: _role!, assignedSchool: assignedSchool)
            : UploadTeacherDetails(
                role: _role!, assignedSchool: assignedSchool),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Dismiss dialog
              setState(() => _isLoadingLogout = true);
              await Future.delayed(const Duration(seconds: 1));
              await SharedPrefsHelper.clearUserDetails();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => UnifiedLoginScreen()),
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
    return Scaffold(
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Container(), // Empty container to avoid bottom padding
          )),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 48 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _role ?? 'Admin',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(widget.data),
                      ],
                    ),
                  ],
                ),
              ),
              FadeInDown(
                duration: Duration(milliseconds: 600),
                child: Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 32),
              FadeInDown(
                delay: Duration(milliseconds: 200),
                child: _buildButton('Upload Child Details', Icons.child_care),
              ),
              SizedBox(height: 16),
              FadeInDown(
                delay: Duration(milliseconds: 300),
                child: _buildButton('Upload Teacher Details', Icons.school),
              ),
              SizedBox(height: 16),
              FadeInDown(
                delay: Duration(milliseconds: 350),
                child: _buildButton('Manage School (Students & Teachers)', Icons.manage_accounts),
              ),
              SizedBox(height: 16),
              FadeInDown(
                delay: Duration(milliseconds: 400),
                child: _buildLogoutButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.width > 600 ? 60 : 50,
      child: ElevatedButton(
        onPressed: () {
          if (label.contains('Manage School')) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SchoolAdminManageScreen()),
            );
            return;
          }
          _navigateToUploadScreen(
              context, label.contains('Child') ? 'child' : 'teacher');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue],
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: userDetails),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.width > 600 ? 60 : 50,
      child: ElevatedButton(
        onPressed: _isLoadingLogout ? null : _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.red, Colors.orange],
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoadingLogout
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
