import 'package:flutter/material.dart';
import 'package:mindseye/assignadmintoschool.dart';
import 'package:mindseye/createProfessionalAccount.dart';
import 'package:mindseye/createSchoolAccount.dart';
import 'package:mindseye/createadminaccount.dart';
import 'package:mindseye/login.dart';
import 'package:mindseye/AssignSchoolToProfessionalScreen.dart';

class NGODashboard extends StatefulWidget {
  final String data;

  const NGODashboard({Key? key, required this.data}) : super(key: key);

  @override
  _NGODashboardState createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> {
  bool _isCreateExpanded = false;
  bool _isAssignExpanded = false;

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("NGO Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${widget.data}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Manage your organization with ease',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 32),

              // Create User Section
              _buildCollapsibleSection(
                title: "Create User",
                icon: Icons.person_add,
                isExpanded: _isCreateExpanded,
                onToggle: () =>
                    setState(() => _isCreateExpanded = !_isCreateExpanded),
                content: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionCard(
                      context,
                      title: "Professional",
                      icon: Icons.person_outline,
                      onTap: () =>
                          _navigateTo(context, CreateProfessionalAccount()),
                    ),
                    _buildActionCard(
                      context,
                      title: "Admin",
                      icon: Icons.admin_panel_settings,
                      onTap: () =>
                          _navigateTo(context, CreateAdminAccountScreen()),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Create School
              _buildActionCard(
                context,
                title: "Create School",
                icon: Icons.school,
                onTap: () => _navigateTo(context, CreateSchoolAccount()),
                color: Colors.green.withOpacity(0.1),
              ),

              SizedBox(height: 20),

              // Assign User Section
              _buildCollapsibleSection(
                title: "Assign User",
                icon: Icons.assignment_ind,
                isExpanded: _isAssignExpanded,
                onToggle: () =>
                    setState(() => _isAssignExpanded = !_isAssignExpanded),
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
                      onTap: () =>
                          _navigateTo(context, AssignAdminToSchoolScreen()),
                    ),
                  ],
                ),
              ),

              Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.image, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("6 images submitted today"),
                    ],
                  ),
                ),
              ),
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey[700],
                ),
                onPressed: onToggle,
              ),
            ],
          ),
          if (isExpanded)
            Padding(padding: EdgeInsets.only(top: 12), child: content),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600
        ? (screenWidth - 48)
        : (screenWidth - 64) / 2; // Two cards per row on larger screens

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
          elevation: 0,
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
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
