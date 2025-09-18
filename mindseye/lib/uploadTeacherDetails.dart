import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';

class UploadTeacherDetails extends StatefulWidget {
  final String role;
  final String? assignedSchool;

  const UploadTeacherDetails({
    super.key,
    required this.role,
    this.assignedSchool,
  });

  @override
  _UploadTeacherDetailsState createState() => _UploadTeacherDetailsState();
}

class _UploadTeacherDetailsState extends State<UploadTeacherDetails>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;
  double _buttonScale = 1.0;
  List<String> _ngoSchools = [];
  String? _selectedSchool;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    if (widget.role == "SchoolAdmin" && widget.assignedSchool != null) {
      _schoolController.text = widget.assignedSchool!;
    } else {
      _fetchAssignedSchools();
    }
  }

  Future<void> _fetchAssignedSchools() async {
    final userDetails = await SharedPrefsHelper.getUserDetails();
    final phone = userDetails['phoneNumber'] ?? "";
    final backendUrl = dotenv.env['BACKEND_URL'] ?? "";

    if (phone.isEmpty || backendUrl.isEmpty) {
      _showSnackBar("Missing user details or backend URL.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/users/get-admins?phone=$phone'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        final assignedSchools = userData['assignedSchoolList'];
        List<String> schools = [];

        if (assignedSchools is String) {
          schools = assignedSchools
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (assignedSchools is List) {
          schools = List<String>.from(assignedSchools);
        } else {
          _showSnackBar("Invalid school list format");
          return;
        }

        setState(() {
          if (widget.role == "SchoolAdmin" && widget.assignedSchool != null) {
            _schoolController.text = widget.assignedSchool!;
          } else {
            _ngoSchools = schools;
            _selectedSchool = schools.isNotEmpty ? schools.first : null;
          }
        });
      } else {
        _showSnackBar("Failed to load schools.");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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

  Widget _buildSchoolSelector() {
    if (widget.role == "SchoolAdmin") {
      return TextFormField(
        controller: _schoolController,
        readOnly: true,
        decoration: _inputDecoration("Assigned School *"),
        validator: (value) => value?.isEmpty == true ? "Required" : null,
      );
    } else {
      return DropdownButtonFormField<String>(
        value: _selectedSchool,
        items: _ngoSchools.map((school) {
          return DropdownMenuItem<String>(
            value: school,
            child: Text(school),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedSchool = value);
        },
        decoration: _inputDecoration("Select School *"),
        validator: (value) => value == null ? "Please select a school" : null,
      );
    }
  }

  Future<void> _submitTeacherDetails() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please complete all required fields.");
      return;
    }

    setState(() {
      _isLoading = true;
      _buttonScale = 0.95;
    });

    final String schoolName = widget.role == "SchoolAdmin"
        ? widget.assignedSchool!
        : _selectedSchool!;

    final userDetails = await SharedPrefsHelper.getUserDetails();
    final adminPhone = userDetails['phoneNumber'] ?? "";

    if (adminPhone.isEmpty) {
      _showSnackBar("Admin phone number not found.");
      setState(() => _isLoading = false);
      return;
    }

    final backendUrl = dotenv.env['BACKEND_URL']!;
    final url = '$backendUrl/api/users/teacherupload';

    final body = jsonEncode({
      'name': _nameController.text,
      'class': int.tryParse(_classController.text),
      'school': schoolName,
      'phone': _phoneController.text,
      'adminNumber': adminPhone
    });

    print("📤 Request Body: $body"); // 📊 Debug logging

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print(
          "📥 Response Status: ${response.statusCode}"); // 📊 Log response code
      print("📥 Response Body: ${response.body}"); // 📊 Log server response

      if (response.statusCode == 200) {
        _showSnackBar("Teacher uploaded successfully!");
        Navigator.pop(context);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Validation failed");
      } else if (response.statusCode == 403) {
        _showSnackBar("Not authorized for this school");
      } else if (response.statusCode >= 500) {
        _showSnackBar("Server error. Please try again later.");
      } else {
        _showSnackBar("Upload failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() {
        _isLoading = false;
        _buttonScale = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _classController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
    "Upload Teacher Details", // Shorter title for better fit
    style: TextStyle(fontSize: 20),
  ),
  titleSpacing: 0, 
          backgroundColor: Colors.blue,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey[200]!],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 48 : 24,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    const SizedBox(height: 32),
                    _buildTextField(_nameController, 'Name',
                        isRequired: true, minLength: 2, maxLength: 50),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _classController,
                      'Class',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSchoolSelector(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _phoneController,
                      'Phone',
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                    ),
                    const SizedBox(height: 32),
                    Transform.scale(
                      scale: _buttonScale,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitTeacherDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
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

  Widget _buildTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType? keyboardType,
    bool isRequired = false,
    int minLength = 0,
    int maxLength = 100,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return '$labelText is required';
        }
        if (minLength > 0 && value != null && value.length < minLength) {
          return 'Must be at least $minLength characters';
        }
        if (maxLength > 0 && value != null && value.length > maxLength) {
          return 'Must not exceed $maxLength characters';
        }
        if (labelText == 'Phone' && value != null) {
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return 'Only numbers allowed';
          }
          if (value.length != 10) {
            return 'Must be exactly 10 digits';
          }
        }
        if (labelText == 'Class' && value != null) {
          final parsed = int.tryParse(value);
          if (parsed == null || parsed < 1 || parsed > 12) {
            return 'Enter class between 1–12';
          }
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: '$labelText${isRequired ? ' *' : ''}',
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        suffixIcon: Icon(Icons.edit, size: 18, color: Colors.grey),
      ),
    );
  }
}
