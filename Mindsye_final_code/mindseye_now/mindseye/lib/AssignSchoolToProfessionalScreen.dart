import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

  List<String> professionals = [];
  List<String> schools = [];
  List<String> displaySchools = [];

  Map<String, Map<String, String>> professionalData = {};

  // ✅ Add this line
  Map<String, String> professionalIdMap = {};

  bool _isLoading = false;

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
        final List<dynamic> professionalList =
            json.decode(professionalRes.body);
        final List<dynamic> schoolList = json.decode(schoolRes.body);

        setState(() {
          // ❌ Remove: Map<String, String> professionalIdMap = {};
          // ✅ Use class-level map instead
          professionalIdMap.clear(); // Reset before populating

          professionals = professionalList
              .where((p) => p['name'] != null && p['ProfessionalID'] != null)
              .map((p) {
            String name = p['name'].toString();
            String id = p['ProfessionalID'].toString();
            professionalIdMap[name] = id; // Store ID against name
            return name;
          }).toList();

          schools = schoolList
              .where((s) => s['schoolName'] != null)
              .map((s) => s['schoolName'].toString())
              .toList();
        });

        // Build map of professional data
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
      } else {
        _showSnackBar(
            "Failed to load data: ${professionalRes.statusCode}, ${schoolRes.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Network Error: $e");
    }
  }

  void _onProfessionalSelected(String? value) {
    if (value == null || !professionalData.containsKey(value)) return;

    final phone = professionalData[value]!['phone'] ?? 'N/A';
    final schoolsAssigned = professionalData[value]!['assignedSchools'] ?? "";

    List<String> assignedList = schoolsAssigned
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      _phoneController.text = phone;
      _assignedSchoolsController.text = schoolsAssigned;

      displaySchools =
          schools.where((school) => !assignedList.contains(school)).toList();

      selectedSchoolToAssign = null;
      selectedProfessional = value;
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
        body: {
          'professionalId': professionalId, // Use ID from class-level map
          'schoolName': selectedSchoolToAssign!,
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar("Assignment successful!");

        // Update locally
        final currentSchools = _assignedSchoolsController.text;
        final updated = currentSchools.isEmpty
            ? selectedSchoolToAssign!
            : '$currentSchools, ${selectedSchoolToAssign!}';

        _assignedSchoolsController.text = updated;

        setState(() {
          displaySchools.remove(selectedSchoolToAssign);
          selectedSchoolToAssign = null;
        });
      } else {
        _showSnackBar("Server returned status ${response.statusCode}");
      }
    } catch (e) {
      _showSnackBar("Could not connect to server: $e");
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
      appBar: AppBar(title: Text('Assign School To Professional')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text('Select Professional', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedProfessional,
                decoration: _inputDecoration("Select Professional *"),
                items: professionals.map((p) {
                  return DropdownMenuItem<String>(
                    value: p,
                    child: Text(p),
                  );
                }).toList(),
                onChanged: _onProfessionalSelected,
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
              const Text('Select School to Assign',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              if (displaySchools.isEmpty)
                const Text("No available schools to assign",
                    style: TextStyle(color: Colors.grey)),
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
