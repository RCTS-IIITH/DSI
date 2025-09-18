import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class CreateSchoolAccount extends StatefulWidget {
  const CreateSchoolAccount({super.key});

  @override
  _CreateSchoolAccountState createState() => _CreateSchoolAccountState();
}

class _CreateSchoolAccountState extends State<CreateSchoolAccount>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProfessionalId;
  String? _selectedOrganizationId;
  bool isValidPhoneNumber(String? phone) {
    if (phone == null) return false;
    final phoneRegExp = RegExp(r'^[0-9]{10}$');
    return phoneRegExp.hasMatch(phone);
  }

  late AnimationController _animationController;

  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _udiseNumberController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  List<Map<String, dynamic>> _professionals = [];
  List<Map<String, dynamic>> _organizations = [];

  bool _isLoading = false;
  bool _isProfessionalLoading = false;
  bool _isOrganizationLoading = false;

  String get backendUrl => dotenv.env['BACKEND_URL'] ?? "";

  final Uri _fetchProfessionalsUri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/getProfessionalIds');
  final Uri _fetchOrganizationsUri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/organizations');
  final Uri _submitUri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-school');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    getProfessionalIds();
    getOrganizations();
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _udiseNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getProfessionalIds() async {
    setState(() => _isProfessionalLoading = true);
    try {
      final response = await http.get(_fetchProfessionalsUri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _professionals =
              data.map((item) => item as Map<String, dynamic>).toList();
        });
      } else {
        _showSnackBar("Failed to load professional IDs");
      }
    } catch (e) {
      _showSnackBar("Error fetching professionals: $e");
    } finally {
      setState(() => _isProfessionalLoading = false);
    }
  }

  Future<void> getOrganizations() async {
    setState(() => _isOrganizationLoading = true);
    try {
      final response = await http.get(_fetchOrganizationsUri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          setState(() {
            _organizations = (data['data'] as List)
                .map((item) => item as Map<String, dynamic>)
                .toList();
            _animationController.forward();
          });
        } else {
          _showSnackBar("Failed to load organizations");
        }
      } else {
        _showSnackBar("Failed to load organizations");
      }
    } catch (e) {
      _showSnackBar("Error fetching organizations: $e");
    } finally {
      setState(() => _isOrganizationLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> createSchoolAccount() async {
    if (_formKey.currentState?.validate() != true ||
        _selectedProfessionalId == null ||
        _selectedOrganizationId == null) {
      _showSnackBar("Please fill all required fields including organization.");
      return;
    }

    if (!isValidPhoneNumber(_contactNumberController.text)) {
      _showSnackBar("Please enter a valid 10-digit contact number");
      return;
    }

    if (_selectedProfessionalId == null) {
      _showSnackBar("Please select a professional ID");
      return;
    }

    if (_selectedOrganizationId == null) {
      _showSnackBar("Please select an organization");
      return;
    }

    setState(() => _isLoading = true);

    final String professionalId =
        _selectedProfessionalId!.split('(').last.replaceAll(')', '').trim();

    try {
      final response = await http.post(
        _submitUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schoolName': _schoolNameController.text.trim(),
          'address': _addressController.text.trim(),
          'udiseNumber': _udiseNumberController.text.trim(),
          'contactNumber': _contactNumberController.text.trim(),
          'assignedProfessionalId': professionalId,
          'organizationId': _selectedOrganizationId,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("School account created successfully!");
        _resetForm();

// ✅ Get current admin phone number from shared preferences
        final currentUserDetails = await SharedPrefsHelper.getUserDetails();
        final currentAdminPhone =
            currentUserDetails['phoneNumber'] ?? 'Unknown';

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
        _showSnackBar("Failed to create school account");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _schoolNameController.clear();
    _addressController.clear();
    _udiseNumberController.clear();
    setState(() {
      _selectedProfessionalId = null;
      _selectedOrganizationId = null;
    });
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
          backgroundColor: Colors.blue, // Match SchoolLoginScreen style
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
            "Create School Account", // Shorter title for better fit
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
                  TextFormField(
                    controller: _schoolNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration("School Name *").copyWith(
                      prefixIcon: Icon(Icons.school),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
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
                  TextFormField(
                    controller: _contactNumberController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration:
                        _inputDecoration("Point of contact number *").copyWith(
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
                  TextFormField(
                    controller: _udiseNumberController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("UDISE Number *").copyWith(
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      if (value!.length != 11) return 'UDISE must be 11 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Organization Selection
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _animationController,
                      child: DropdownButtonFormField<String>(
                        value: _selectedOrganizationId,
                        items: _organizations
                            .map<DropdownMenuItem<String>>((org) {
                          final String id = (org["_id"] ?? '').toString();
                          final String name = (org["name"] ?? 'Unnamed').toString();
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text(name),
                          );
                        }).toList(),
                        onChanged: _isOrganizationLoading || _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedOrganizationId = value;
                                });
                              },
                        decoration: _inputDecoration("Select Organization *").copyWith(
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) =>
                            value == null ? 'Please select an organization' : null,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Professional Selection
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _animationController,
                      child: DropdownButtonFormField<String>(
                        value: _selectedProfessionalId,
                        items: _professionals.map((p) {
                          final display =
                              "${p["name"]} (${p["ProfessionalID"]})";
                          return DropdownMenuItem(
                            value: display,
                            child: Text(display),
                          );
                        }).toList(),
                        onChanged: _isProfessionalLoading || _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedProfessionalId = value;
                                });
                              },
                        decoration:
                            _inputDecoration("Assigned Professional ID *")
                                .copyWith(
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value == null ? 'Please select one' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
                                if (_formKey.currentState?.validate() == true &&
                                    _selectedProfessionalId != null &&
                                    _selectedOrganizationId != null) {
                                  createSchoolAccount();
                                } else {
                                  _showSnackBar(
                                      "Please complete all required fields including organization");
                                }
                              },
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : Icon(Icons.school),
                        label: Text(
                          _isLoading ? "Creating..." : "Create School Account",
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
