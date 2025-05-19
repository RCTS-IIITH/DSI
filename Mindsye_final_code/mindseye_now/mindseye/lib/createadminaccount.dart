import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'dart:convert';
import 'package:mindseye/shared_prefs_helper.dart';

class CreateAdminAccountScreen extends StatefulWidget {
  const CreateAdminAccountScreen({super.key});

  @override
  _CreateAdminAccountScreenState createState() =>
      _CreateAdminAccountScreenState();
}

class _CreateAdminAccountScreenState extends State<CreateAdminAccountScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late AnimationController _animationController;
  bool _isLoading = false;

  String _selectedRole = 'NGOAdmin';
  List<String> _selectedSchools = [];
  List<String> _availableSchools = []; // Should be fetched from backend

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fetchSchools(); // Implement this to get available schools
  }

  Future<void> _fetchSchools() async {
    try {
      final token = await SharedPrefsHelper.getToken();
      final url =
          Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/get-schools');

      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        setState(() {
          _availableSchools = (jsonDecode(response.body) as List)
              .map((item) => item['id'] as String)
              .toList();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _createAdminAccount() async {
    if (_formKey.currentState?.validate() != true) {
      _showSnackBar("Please fill all required fields.");
      return;
    }

    setState(() => _isLoading = true);

    final token = await SharedPrefsHelper.getToken();
    final currentUserDetails = await SharedPrefsHelper.getUserDetails();
    final currentAdminPhone = currentUserDetails['phoneNumber'] ?? 'Unknown';
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-ngo-admin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'number': _phoneController.text.trim(),
          'role': _selectedRole,
          'assignedSchoolList': _selectedRole == 'SchoolAdmin'
              ? (_selectedSchools.isNotEmpty ? [_selectedSchools.first] : [])
              : _selectedSchools,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showSnackBar("Admin account created successfully!");

        // ✅ Redirect to current NGO Admin dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => NGODashboard(data: currentAdminPhone)),
          (route) => false,
        );
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Failed to create admin");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Role *",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedRole,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: (String? value) {
              setState(() {
                _selectedRole = value!;
                if (_selectedRole == 'SchoolAdmin' &&
                    _selectedSchools.length > 1) {
                  _selectedSchools = _selectedSchools.sublist(0, 1);
                }
              });
            },
            items: ['NGOAdmin', 'SchoolAdmin'].map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSchoolSelector() {
    if (_availableSchools.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedRole == 'SchoolAdmin' ? "School *" : "Assigned Schools",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSchools.map((schoolId) {
            final isSelected = _selectedSchools.contains(schoolId);

            return FilterChip(
              label: Text(schoolId),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (_selectedRole == 'SchoolAdmin') {
                      _selectedSchools = [schoolId];
                    } else {
                      _selectedSchools.add(schoolId);
                    }
                  } else {
                    _selectedSchools.remove(schoolId);
                  }
                });
              },
            );
          }).toList(),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentUserDetails = await SharedPrefsHelper.getUserDetails();
        final currentAdminPhone =
            currentUserDetails['phoneNumber'] ?? 'Unknown';

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => NGODashboard(data: currentAdminPhone)),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              final currentUserDetails =
                  await SharedPrefsHelper.getUserDetails();
              final currentAdminPhone =
                  currentUserDetails['phoneNumber'] ?? 'Unknown';

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => NGODashboard(data: currentAdminPhone)),
                (route) => false,
              );
            },
          ),
          title: Text("Create Admin Account"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Admin Account",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration("Name *"),
                    validator: (value) =>
                        value?.isEmpty == true ? "Required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration("Phone Number *"),
                    validator: (value) =>
                        value?.isEmpty == true ? "Required" : null,
                  ),
                  const SizedBox(height: 24),
                  _buildRoleSelector(),
                  _buildSchoolSelector(),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, child) {
                      return Opacity(
                        opacity: _isLoading ? 0.5 : 1,
                        child: child!,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createAdminAccount,
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.admin_panel_settings),
                        label: Text(
                          _isLoading ? "Creating..." : "Create Admin Account",
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
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
