import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mindseye/shared_prefs_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> userData;

  const EditProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _classController;

  bool _isLoading = false;
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize controllers from userData
    _nameController =
        TextEditingController(text: widget.userData['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userData['phoneNumber'] ?? '');
    _emailController =
        TextEditingController(text: widget.userData['workEmail'] ?? '');
    _addressController =
        TextEditingController(text: widget.userData['Address'] ?? '');
    _classController =
        TextEditingController(text: widget.userData['class'] ?? '');
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse('http://localhost:3000/api/users/edit-profile');
    final role = widget.userData['role']!;
    final phone = widget.userData['phoneNumber']!;
    if (phone.isEmpty) {
      setState(() {
        _errorMessage = 'Phone number is required';
        _isLoading = false;
      });
      return;
    }

    final body = {
      'role': role,
      'phone': phone,
      'name': _nameController.text.trim(),
      'Number': _phoneController.text.trim(),
      'workEmail': _emailController.text.trim(),
      'Address': _addressController.text.trim(),
      'class': _classController.text.trim(),
    };

    try {
      final response = await http.put(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['updatedUser'];

        // Prepare updates for SharedPrefs
        final updates = <String, String>{};

        if (_nameController.text.trim().isNotEmpty)
          updates['name'] = _nameController.text.trim();

        if (_phoneController.text.trim().isNotEmpty)
          updates['phoneNumber'] = _phoneController.text.trim();

        if (_emailController.text.trim().isNotEmpty)
          updates['workEmail'] = _emailController.text.trim();

        if (_addressController.text.trim().isNotEmpty)
          updates['Address'] = _addressController.text.trim();

        if (_classController.text.trim().isNotEmpty)
          updates['class'] = _classController.text.trim();

        // ✅ Use your existing method
        await SharedPrefsHelper.updateUserDetails(updates);

        // Go back to dashboard
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully")),
          );
        }
      } else {
        setState(() {
          _errorMessage = "Failed to update profile";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInputField(
      String label, IconData icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        validator: (value) {
          if (label == "Name" && value!.isEmpty) return "Name is required";
          if (label == "Phone Number" &&
              value?.length != 10 &&
              (widget.userData['role'] == 'Professional' ||
                  widget.userData['role'] == 'SchoolAdmin')) {
            return "Enter valid 10-digit number";
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.indigo[900]),
          hintText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.userData['role'] ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  "Update Your Details",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),

                // Name Field
                _buildInputField("Name", Icons.person, _nameController,
                    enabled: true),

                // Phone Field (for Professionals/School Admins only)
                if (role == 'Professional' || role == 'SchoolAdmin')
                  _buildInputField(
                      "Phone Number", Icons.phone, _phoneController,
                      keyboardType: TextInputType.number,
                      enabled: role != 'Parent'),

                // Email Field (only for Professionals)
                if (role == 'Professional')
                  _buildInputField("Work Email", Icons.email, _emailController),

                // Address Field (only for Professionals)
                if (role == 'Professional')
                  _buildInputField(
                      "Address", Icons.location_on, _addressController),

                // Class Field (only for Teachers)
                if (role == 'Teacher')
                  _buildInputField("Class", Icons.class_, _classController,
                      keyboardType: TextInputType.number),

                SizedBox(height: 20),

                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),

                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white))
                      : Icon(Icons.save),
                  label: Text(_isLoading ? "Saving..." : "Save Changes"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _classController.dispose();
    super.dispose();
  }
}
