import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class CreateOrganizationAccount extends StatefulWidget {
  const CreateOrganizationAccount({super.key});

  @override
  _CreateOrganizationAccountState createState() => _CreateOrganizationAccountState();
}

class _CreateOrganizationAccountState extends State<CreateOrganizationAccount>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  String get backendUrl => dotenv.env['BACKEND_URL'] ?? "";

  final Uri _submitUri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/organizations');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return true; // Email is optional
    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegExp.hasMatch(email);
  }

  bool isValidPhoneNumber(String? phone) {
    if (phone == null) return false;
    final phoneRegExp = RegExp(r'^[0-9]{10}$');
    return phoneRegExp.hasMatch(phone);
  }

  Future<void> createOrganizationAccount() async {
    if (_formKey.currentState?.validate() != true) {
      _showSnackBar("Please fill all required fields.");
      return;
    }

    if (!isValidPhoneNumber(_contactNumberController.text)) {
      _showSnackBar("Please enter a valid 10-digit contact number");
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      _showSnackBar("Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user details
      final currentUserDetails = await SharedPrefsHelper.getUserDetails();
      final currentAdminPhone = currentUserDetails['phoneNumber'] ?? '';

      // Find the user ID by phone number (use get-admins which returns _id)
      final userRes = await http.get(
        Uri.parse('$backendUrl/api/users/get-admins?phone=$currentAdminPhone'),
      );
      if (userRes.statusCode != 200) {
        _showSnackBar("Failed to identify current user");
        return;
      }
      final userData = jsonDecode(userRes.body);
      final createdBy = userData['_id'] ?? userData['id'];

      final response = await http.post(
        _submitUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'address': _addressController.text.trim(),
          'contactNumber': _contactNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'createdBy': createdBy,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Organization created successfully!");
        _resetForm();

        // Navigate back to NGO Dashboard
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => NGODashboard(data: currentAdminPhone),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Validation failed");
      } else {
        _showSnackBar("Failed to create organization");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _contactNumberController.clear();
    _emailController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      NGODashboard(data: currentAdminPhone),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
          ),
          title: Text(
            "Create Organization",
            style: TextStyle(fontSize: 20),
          ),
          titleSpacing: 0,
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
                  const SizedBox(height: 20),
                  
                  // Organization Name
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration("Organization Name *").copyWith(
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration("Description").copyWith(
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration("Address *").copyWith(
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Contact Number
                  TextFormField(
                    controller: _contactNumberController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration:
                        _inputDecoration("Contact Number *").copyWith(
                      counterText: "",
                      prefixIcon: Icon(Icons.phone),
                      hintText: "Enter 10 digit mobile number",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact number is required';
                      }
                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                        return 'Please enter valid 10 digit mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration("Email").copyWith(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Enter email address (optional)",
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && !isValidEmail(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Create Button
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isLoading ? 0.5 : 1,
                        child: child!,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() == true) {
                                  createOrganizationAccount();
                                } else {
                                  _showSnackBar("Please complete all required fields");
                                }
                              },
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : Icon(Icons.business),
                        label: Text(
                          _isLoading ? "Creating..." : "Create Organization",
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
