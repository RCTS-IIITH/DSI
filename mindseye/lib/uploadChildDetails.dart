import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';

class UploadChildDetails extends StatefulWidget {
  final String role;
  final String? assignedSchool;

  const UploadChildDetails({required this.role, this.assignedSchool});

  @override
  _UploadChildDetailsState createState() => _UploadChildDetailsState();
}

class _UploadChildDetailsState extends State<UploadChildDetails>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _classController = TextEditingController();
  final _ageController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;
  bool _isSuccess = false;
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
      _schoolIdController.text = widget.assignedSchool!;
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
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/api/users/get-admins?phone=$phone'),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final List<String> assignedSchools =
            List<String>.from(userData['assignedSchoolList'] ?? []);

        setState(() {
          _ngoSchools = assignedSchools;
          _selectedSchool =
              assignedSchools.isNotEmpty ? assignedSchools.first : null;
        });
      } else {
        _showSnackBar("Failed to fetch schools.");
      }
    } catch (e) {
      _showSnackBar("Error fetching schools: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        controller: _schoolIdController,
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

  Future<void> _submitChildDetails() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please complete all required fields.");
      return;
    }

    setState(() {
      _isLoading = true;
      _buttonScale = 0.95;
    });

    try {
      // Get current user details
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final adminNumber = userDetails['phoneNumber'];

      if (adminNumber == null || adminNumber == 'N/A') {
        _showSnackBar("Admin authentication failed. Please login again.");
        return;
      }

      final String schoolName = widget.role == "SchoolAdmin"
          ? widget.assignedSchool!
          : _selectedSchool!;

      final backendUrl = dotenv.env['BACKEND_URL']!;
      final url = '$backendUrl/api/users/childupload';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'rollNumber': _rollNumberController.text,
          'schoolID': schoolName,
          'parentName': _parentNameController.text,
          'parentPhoneNumber': _parentPhoneController.text,
          'class': _classController.text,
          'age': _ageController.text,
          'adminNumber': adminNumber, // Add admin phone for verification
          'role': widget.role, // Add role for verification
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        _showSnackBar("Child uploaded successfully!");

        if (widget.role == "SchoolAdmin") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => SchoolAdminDashboard()),
            (route) => false,
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Failed to upload child");
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

  // Add this debug code temporarily to check stored values

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _rollNumberController.dispose();
    _schoolIdController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _classController.dispose();
    _ageController.dispose();
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
          title: const Text(
            'Upload Child Details', // Shorter title for better fit
            style: TextStyle(fontSize: 20),
          ),
          titleSpacing: 0,
          backgroundColor: Colors.blue,
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
                    _buildTextField(_nameController, 'Name', isRequired: true),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _ageController,
                      'Age',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildSchoolSelector(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _parentNameController,
                      'Parent Name',
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _parentPhoneController,
                      'Parent Phone',
                      keyboardType: TextInputType.phone,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _classController,
                      'Class',
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _rollNumberController,
                      'Roll Number',
                    ),
                    const SizedBox(height: 32),
                    Transform.scale(
                      scale: _buttonScale,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitChildDetails,
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
                              : Text(
                                  _isSuccess ? 'Success!' : 'Upload',
                                  style: const TextStyle(
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '$labelText is required';
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

class SchoolAdminDashboard extends StatelessWidget {
  const SchoolAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text("School Admin Dashboard"),
        ),
      ),
    );
  }
}
