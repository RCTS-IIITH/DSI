import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class CreateProfessionalAccount extends StatefulWidget {
  const CreateProfessionalAccount({super.key});

  @override
  _CreateProfessionalAccountState createState() =>
      _CreateProfessionalAccountState();
}

class _CreateProfessionalAccountState extends State<CreateProfessionalAccount>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();

  late String _professionalId; // Auto-generated
  bool _isLoading = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _generateProfessionalID(); // Generate on load
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  void _generateProfessionalID() {
    // You can generate unique logic here if needed
    // For now, just use a simple format like "PROF-1234"
    final randomNumber = DateTime.now().millisecondsSinceEpoch % 9999;
    _professionalId = "PROF-$randomNumber";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _clinicNameController.dispose();
    _animationController.dispose();

    super.dispose();
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

  Future<void> _createAccount() async {
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix errors before submitting.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Step 1: Check for duplicate phone number
      final checkPhoneResponse = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/search-number'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usertype': 'Professional',
          'number': _phoneController.text.trim(),
        }),
      );

      if (checkPhoneResponse.statusCode == 200) {
        final exists = jsonDecode(checkPhoneResponse.body)['exists'];
        if (exists) {
          _showErrorDialog("This phone number is already registered.");
          setState(() => _isLoading = false);
          return;
        }
      }

      // Step 2: Submit form
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-professional'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'Number': _phoneController.text.trim(),
          'Address': _addressController.text.trim(),
          'ProfessionalID': _professionalId,
          'workEmail': _emailController.text.trim(),
          'clinicName': _clinicNameController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? "Validation failed");
      } else {
        _showErrorDialog("Failed to create account. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() async {
    final userDetails = await SharedPrefsHelper.getUserDetails();
    final currentAdminPhone = userDetails['phoneNumber'] ?? 'Unknown';
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Professional account created successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => NGODashboard(data: currentAdminPhone),
                ),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
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
      child: FadeTransition(
        opacity: _animationController,
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
            title: Text("Create Professional Account"),
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
                      "Create Professional Account",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration("Name *"),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Name is required";
                        if (value.split(" ").length < 2)
                          return "Enter full name (e.g., John Doe)";
                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value))
                          return "Name must contain only letters";
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: _inputDecoration("Phone Number *"),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Phone number is required";
                        if (value.length != 10) return "Must be 10 digits";
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration("Address *"),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Address is required";
                        if (value.trim().length < 5)
                          return "Minimum 5 characters required";
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Work Email *"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Clinic Name Field
                    TextFormField(
                      controller: _clinicNameController,
                      decoration: _inputDecoration("Clinic Name *"),
                      validator: (value) => value == null || value.isEmpty ? "Required" : null,
                    ),

                    const SizedBox(height: 16),

                    // Professional ID (Auto-filled)
                    TextFormField(
                      enabled: false,
                      initialValue: _professionalId,
                      decoration: _inputDecoration("Professional ID"),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
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
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createAccount,
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.engineering),
                          label: Text(
                            _isLoading
                                ? "Creating..."
                                : "Create Professional Account",
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
      ),
    );
  }
}
