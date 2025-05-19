import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart'; // Ensure this path is correct

class AssignSchoolToProfessionalScreen extends StatefulWidget {
  const AssignSchoolToProfessionalScreen({super.key});

  @override
  State<AssignSchoolToProfessionalScreen> createState() =>
      _AssignSchoolToProfessionalScreenState();
}

class _AssignSchoolToProfessionalScreenState
    extends State<AssignSchoolToProfessionalScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _assignedSchoolsController =
      TextEditingController();

  String? selectedProfessional;
  String? selectedSchoolToAssign;
  String backendUrl = dotenv.env['BACKEND_URL'] ?? '';
  List<String> displaySchools = [];
  Map<String, String> professionalIdMap = {}; // Map name -> ProfessionalID
  Map<String, Map<String, String>> professionalData = {};
  bool _isLoading = false;

  List<String> professionals = [];
  List<String> schools = [];

  Future<void> _fetchInitialData() async {
    if (backendUrl.isEmpty) {
      _showSnackBar("Backend URL not configured.");
      return;
    }

    final professionalUri =
        Uri.parse('$backendUrl/api/users/getProfessionalIds');
    final schoolUri = Uri.parse('$backendUrl/api/users/get-schools');

    try {
      final professionalRes = await http.get(professionalUri);
      final schoolRes = await http.get(schoolUri);

      if (professionalRes.statusCode == 200 && schoolRes.statusCode == 200) {
        final List<dynamic> professionalList = jsonDecode(professionalRes.body);
        final List<dynamic> schoolList = jsonDecode(schoolRes.body);

        setState(() {
          professionalIdMap.clear();
          professionals = professionalList
              .where((p) => p['name'] != null && p['ProfessionalID'] != null)
              .map((p) {
            String name = p['name'].toString();
            String id = p['ProfessionalID'].toString();
            professionalIdMap[name] = id;
            return name;
          }).toList();

          schools = schoolList
              .where((s) => s['schoolName'] != null)
              .map((s) => s['schoolName'].toString())
              .toList();

          // Build professional data map
          professionalData.clear();
          for (var p in professionalList) {
            var name = p['name']?.toString() ?? 'Unknown Professional';
            var number = p['Number']?.toString() ?? 'N/A';
            List assignedSchools = p['assignedSchools'] ?? [];
            String assignedSchoolsStr =
                assignedSchools.map((s) => s.toString()).join(', ');
            professionalData[name] = {
              'phone': number,
              'assignedSchools': assignedSchoolsStr,
            };
          }
        });

        if (professionals.isNotEmpty) {
          _onProfessionalSelected(professionals.first);
        }
      } else {
        _showSnackBar("Failed to load data.");
      }
    } catch (e) {
      _showSnackBar("Network Error: $e");
    }
  }

  void _onProfessionalSelected(String? value) {
    if (value == null || !professionalData.containsKey(value)) return;

    final data = professionalData[value]!;
    final phone = data['phone'] ?? 'N/A';
    final schoolsAssigned = data['assignedSchools'] ?? "";
    List<String> assignedList = schoolsAssigned
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      selectedProfessional = value;
      _phoneController.text = phone;
      _assignedSchoolsController.text = schoolsAssigned;
      displaySchools =
          schools.where((school) => !assignedList.contains(school)).toList();
      selectedSchoolToAssign =
          displaySchools.isNotEmpty ? null : selectedSchoolToAssign;
    });
  }

  Future<void> _assignSchoolToProfessional() async {
    if (selectedProfessional == null || selectedSchoolToAssign == null) {
      _showSnackBar("Please select both a professional and a school.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final professionalId = professionalIdMap[selectedProfessional!]!;
      final response = await http.post(
        Uri.parse('$backendUrl/api/users/assign-school-to-professional'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'professionalId': professionalId,
          'schoolName': selectedSchoolToAssign,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _showSnackBar("School assigned successfully!");

          // ✅ Redirect to NGO Dashboard with fade transition
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  NGODashboard(data: selectedProfessional!),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          _showSnackBar(responseData['message'] ?? "Assignment failed.");
        }
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Not found");
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Failed to assign school");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _assignedSchoolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign School to Professional"),
        backgroundColor: Colors.blue, // Consistent with NGO Dashboard
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
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchInitialData, // Refresh data
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                "Select Professional",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedProfessional,
                items: professionals.map((p) {
                  return DropdownMenuItem<String>(
                    value: p,
                    child: Text(p),
                  );
                }).toList(),
                onChanged: _onProfessionalSelected,
                decoration: _inputDecoration("Select Professional *"),
                validator: (value) =>
                    value == null ? "Please select a professional" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                readOnly: true,
                decoration: _inputDecoration("Phone Number"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _assignedSchoolsController,
                readOnly: true,
                maxLines: 2,
                decoration: _inputDecoration("Assigned Schools"),
              ),
              const SizedBox(height: 16),
              const Text(
                "Select School to Assign",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (displaySchools.isEmpty)
                const Text(
                  "No available schools to assign.",
                  style: TextStyle(color: Colors.grey),
                ),
              if (displaySchools.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedSchoolToAssign,
                  hint: Text("Choose a school"),
                  items: displaySchools.map((school) {
                    return DropdownMenuItem<String>(
                      value: school,
                      child: Text(school),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSchoolToAssign = value;
                    });
                  },
                  decoration: _inputDecoration("Select School *"),
                  validator: (value) =>
                      value == null ? "Please select a school" : null,
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: (!_isLoading &&
                        selectedProfessional != null &&
                        selectedSchoolToAssign != null &&
                        displaySchools.isNotEmpty)
                    ? _assignSchoolToProfessional
                    : null,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.hail),
                label: Text(
                  _isLoading ? "Assigning..." : "Assign School",
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
