// import 'package:flutter/material.dart';
// import 'package:mindseye/NGOdashboard.dart';

// class AssignAdminToSchoolScreen extends StatefulWidget {
//   @override
//   _AssignAdminToSchoolScreenState createState() =>
//       _AssignAdminToSchoolScreenState();
// }

// class _AssignAdminToSchoolScreenState extends State<AssignAdminToSchoolScreen> {
//   String? selectedAdmin;
//   String phoneNumber = '123-456-7890'; // Example phone number
//   String assignedSchools = 'School A, School B'; // Example assigned schools
//   String? selectedSchoolToAssign;
//   List<String> admins = ['Admin 1', 'Admin 2', 'Admin 3'];
//   List<String> schools = ['School X', 'School Y', 'School Z'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Assign Admin To School'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Select Admin (Dropdown)',
//               style: TextStyle(fontSize: 16),
//             ),
//             DropdownButton<String>(
//               value: selectedAdmin,
//               isExpanded: true,
//               items: admins.map((admin) {
//                 return DropdownMenuItem<String>(
//                   value: admin,
//                   child: Text(admin),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedAdmin = value;
//                   // Update phoneNumber and assignedSchools if needed
//                 });
//               },
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Phone Number (autofill)',
//               style: TextStyle(fontSize: 16),
//             ),
//             TextField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 hintText: phoneNumber,
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Assigned Schools (autofill)',
//               style: TextStyle(fontSize: 16),
//             ),
//             TextField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 hintText: assignedSchools,
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Select School to Assign',
//               style: TextStyle(fontSize: 16),
//             ),
//             DropdownButton<String>(
//               value: selectedSchoolToAssign,
//               isExpanded: true,
//               items: schools.map((school) {
//                 return DropdownMenuItem<String>(
//                   value: school,
//                   child: Text(school),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedSchoolToAssign = value;
//                 });
//               },
//             ),
//             SizedBox(height: 32),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Handle save changes action
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => NGODashboard(),
//                     ),
//                     (Route<dynamic> route) => false,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   minimumSize: Size(double.infinity, 50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Save Changes',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignSchoolToAdminScreen extends StatefulWidget {
  const AssignSchoolToAdminScreen({super.key});

  @override
  State<AssignSchoolToAdminScreen> createState() =>
      _AssignSchoolToAdminScreenState();
}

class _AssignSchoolToAdminScreenState extends State<AssignSchoolToAdminScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _assignedSchoolsController =
      TextEditingController();

  String? selectedAdmin;
  String? selectedSchoolToAssign;

  String backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  List<String> displaySchools = [];
  Map<String, String> adminPhoneMap = {}; // Name -> Phone
  Map<String, Map<String, String>> adminData = {};

  bool _isLoading = false;
  bool _isDataLoading = true;
  bool _hasError = false;

  List<String> admins = [];
  List<String> schools = [];

  Future<void> _fetchInitialData() async {
    setState(() {
      _isDataLoading = true;
      _hasError = false;
    });

    if (backendUrl.isEmpty) {
      _showSnackBar("Backend URL not configured.");
      setState(() => _isDataLoading = false);
      return;
    }

    final adminUri = Uri.parse('$backendUrl/api/users/get-admins');
    final schoolUri = Uri.parse('$backendUrl/api/users/get-schools');

    try {
      // Step 1: Fetch all admins
      final adminRes = await http.get(adminUri);
      if (adminRes.statusCode != 200) {
        _showSnackBar("Failed to fetch admins");
        setState(() => _hasError = true);
        return;
      }
      final List<dynamic> adminList = jsonDecode(adminRes.body);

      // Step 2: Fetch all schools
      final schoolRes = await http.get(schoolUri);
      if (schoolRes.statusCode != 200) {
        _showSnackBar("Failed to fetch schools");
        setState(() => _hasError = true);
        return;
      }
      final List<dynamic> schoolList = jsonDecode(schoolRes.body);

      // Step 3: Prepare adminPhoneMap and list of admin names
      setState(() {
        adminPhoneMap.clear();
        admins = adminList
            .where((p) => p['name'] != null && p['number'] != null)
            .map((p) {
          String name = p['name'].toString();
          String number = p['number'].toString();
          adminPhoneMap[name] = number;
          return name;
        }).toList();

        schools = schoolList
            .where((s) => s['schoolName'] != null)
            .map((s) => s['schoolName'].toString())
            .toList();
      });

      // Step 4: For each admin, fetch their assigned schools
      adminData.clear();
      for (var p in adminList) {
        var name = p['name']?.toString() ?? 'Unknown Admin';
        var number = p['number']?.toString() ?? 'N/A';
        var role = p['role']?.toString() ?? '';

        // Step 5: Fetch assigned schools via the new endpoint
        final assignedSchoolsUri = Uri.parse(
            '$backendUrl/api/users/get-assigned-schools-for-admin?phoneNumber=$number');

        final assignedSchoolsRes = await http.get(assignedSchoolsUri);

        List<String> assignedSchools = [];

        if (assignedSchoolsRes.statusCode == 200) {
          final data = jsonDecode(assignedSchoolsRes.body);
          if (data['success'] == true && data['data'] is List) {
            assignedSchools = List<String>.from(data['data']);
          }
        }

        // Update adminData map
        adminData[name] = {
          'phone': number,
          'assignedSchools': assignedSchools.join(', '),
          'role': role,
        };
      }

      // Step 6: Update UI state
      setState(() {
        if (admins.isNotEmpty) {
          _onAdminSelected(admins.first);
        }
      });
    } catch (e) {
      _showSnackBar("Network Error: $e");
      setState(() => _hasError = true);
    } finally {
      setState(() => _isDataLoading = false);
    }
  }

  void _onAdminSelected(String? value) {
    if (value == null || !adminData.containsKey(value)) return;
    final data = adminData[value]!;
    final phone = data['phone'] ?? 'N/A';
    final schoolsAssigned = data['assignedSchools'];
    final role = data['role']?.toString() ?? "";

    List<String> assignedList = [];

    // ✅ Normalize assignedSchools (handle both string and list)
    if (schoolsAssigned is String) {
      assignedList = schoolsAssigned
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (schoolsAssigned is List) {
      assignedList = (schoolsAssigned as List)
          .map((s) => s.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    void _showAlreadyAssignedDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Assignment Not Allowed"),
          content: Text("School Admin already has an assigned school."),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: Text("OK"),
            ),
          ],
        ),
      );
    }

    setState(() {
      selectedAdmin = value;
      _phoneController.text = phone;
      _assignedSchoolsController.text = assignedList.join(', ');

      // ✅ Handle school display based on admin role
      if (role == "SchoolAdmin") {
        // School admin can only be assigned one school
        if (assignedList.isEmpty) {
          // If no schools assigned, show all available schools
          displaySchools = schools;
        } else {
          // If already has a school, show no schools
          displaySchools = [];
          _showAlreadyAssignedDialog(context);
        }
      } else {
        // NGO admin can be assigned multiple schools
        displaySchools =
            schools.where((school) => !assignedList.contains(school)).toList();
      }

      // Reset school selection when changing admin
      selectedSchoolToAssign = null;
    });
  }

  Future<void> _assignSchoolToAdmin() async {
    if (selectedAdmin == null || selectedSchoolToAssign == null) {
      _showSnackBar("Please select both an admin and a school.");
      return;
    }

    // ✅ Check admin role and existing assignments
    final role = adminData[selectedAdmin!]?['role']?.toString() ?? "";
    final currentAssignments =
        adminData[selectedAdmin!]?['assignedSchools']?.toString() ?? "";

    if (role == "SchoolAdmin" && currentAssignments.isNotEmpty) {
      _showSnackBar("School admin can only be assigned to one school");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminNumber = adminPhoneMap[selectedAdmin!]!;

      final response = await http.post(
        Uri.parse('$backendUrl/api/users/assign-admin-to-school'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'adminNumber': adminNumber,
          'schoolName': selectedSchoolToAssign,
          'role': role, // ✅ Send role to backend
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          _showSnackBar("School assigned successfully!");

          // ✅ Update shared preferences
          final prefs = await SharedPreferences.getInstance();
          final currentSchools =
              prefs.getStringList('assignedSchoolList') ?? [];

          if (role == "SchoolAdmin") {
            // For school admin, replace existing assignments
            await prefs
                .setStringList('assignedSchoolList', [selectedSchoolToAssign!]);
          } else {
            // For NGO admin, add to existing assignments
            final updatedSchools = [...currentSchools, selectedSchoolToAssign!];
            await prefs.setStringList('assignedSchoolList', updatedSchools);
          }

          // Refresh the UI
          await _fetchInitialData();
        } else {
          _showSnackBar(responseData['message'] ?? "Assignment failed.");
        }
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
      backgroundColor: Colors.green.shade600,
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
          title: const Text("Assign School to Admin"),
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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _isDataLoading ? null : _fetchInitialData,
            )
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isDataLoading
                ? Center(child: CircularProgressIndicator())
                : _hasError
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Failed to load data.",
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchInitialData,
                            icon: Icon(Icons.refresh),
                            label: Text("Try Again"),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          const Text(
                            "Select Admin",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: selectedAdmin,
                            items: admins.map((p) {
                              return DropdownMenuItem<String>(
                                value: p,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(p),
                                    Text(
                                      adminData[p]?['role'] ?? "",
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _onAdminSelected,
                            decoration: _inputDecoration("Select Admin *"),
                            validator: (value) =>
                                value == null ? "Please select an admin" : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _phoneController,
                            readOnly: true,
                            decoration:
                                _inputDecoration("Phone Number").copyWith(
                              filled: true,
                              fillColor: Colors.grey[300],
                              prefixIcon: Icon(Icons.lock,
                                  size: 18, color: Colors.grey),
                            ),
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _assignedSchoolsController,
                            readOnly: true,
                            maxLines: 2,
                            decoration:
                                _inputDecoration("Assigned Schools").copyWith(
                              filled: true,
                              fillColor: Colors.grey[300],
                              prefixIcon: Icon(Icons.lock,
                                  size: 18, color: Colors.grey),
                            ),
                            style: TextStyle(color: Colors.grey[700]),
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
                              validator: (value) => value == null
                                  ? "Please select a school"
                                  : null,
                            ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: (!_isLoading &&
                                    selectedAdmin != null &&
                                    selectedSchoolToAssign != null &&
                                    displaySchools.isNotEmpty)
                                ? _assignSchoolToAdmin
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
      ),
    );
  }
}
