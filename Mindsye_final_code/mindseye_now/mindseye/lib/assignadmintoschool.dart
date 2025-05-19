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
  Map<String, String> adminIdMap = {}; // Map name -> Number
  Map<String, Map<String, String>> adminData = {};

  bool _isLoading = false;

  List<String> admins = [];
  List<String> schools = [];

  Future<void> _fetchInitialData() async {
    if (backendUrl.isEmpty) {
      _showSnackBar("Backend URL not configured.");
      return;
    }

    final adminUri = Uri.parse('$backendUrl/api/users/get-admins');
    final schoolUri = Uri.parse('$backendUrl/api/users/get-schools');

    try {
      final adminRes = await http.get(adminUri);
      final schoolRes = await http.get(schoolUri);

      if (adminRes.statusCode == 200 && schoolRes.statusCode == 200) {
        final List<dynamic> adminList = jsonDecode(adminRes.body);
        final List<dynamic> schoolList = jsonDecode(schoolRes.body);

        setState(() {
          adminIdMap.clear();

          admins = adminList
              .where((p) => p['name'] != null && p['number'] != null)
              .map((p) {
            String name = p['name'].toString();
            String number = p['number'].toString();
            adminIdMap[name] = number;
            return name;
          }).toList();

          schools = schoolList
              .where((s) => s['schoolName'] != null)
              .map((s) => s['schoolName'].toString())
              .toList();

          // Build admin data map
          adminData.clear();
          for (var p in adminList) {
            var name = p['name']?.toString() ?? 'Unknown Admin';
            var number = p['number']?.toString() ?? 'N/A';
            List assignedSchools = p['assignedSchools'] ?? [];
            String assignedSchoolsStr =
                assignedSchools.map((s) => s.toString()).join(', ');
            adminData[name] = {
              'phone': number,
              'assignedSchools': assignedSchoolsStr,
            };
          }
        });

        if (admins.isNotEmpty) {
          _onAdminSelected(admins.first);
        }
      } else {
        _showSnackBar("Failed to load data.");
      }
    } catch (e) {
      _showSnackBar("Network Error: $e");
    }
  }

  void _onAdminSelected(String? value) {
    if (value == null || !adminData.containsKey(value)) return;
    final data = adminData[value]!;
    final phone = data['phone'] ?? 'N/A';
    final schoolsAssigned =
        data['assignedSchools'] ?? ""; // Get assigned schools
    List<String> assignedList = schoolsAssigned
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      selectedAdmin = value;
      _phoneController.text = phone;
      _assignedSchoolsController.text = schoolsAssigned;
      displaySchools =
          schools.where((school) => !assignedList.contains(school)).toList();
      selectedSchoolToAssign =
          displaySchools.isNotEmpty ? null : selectedSchoolToAssign;
    });
  }

  Future<void> _assignSchoolToAdmin() async {
    if (selectedAdmin == null || selectedSchoolToAssign == null) {
      _showSnackBar("Please select both an admin and a school.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminNumber = adminIdMap[selectedAdmin!]!;

      final response = await http.post(
        Uri.parse('$backendUrl/api/users/assign-school-to-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'adminNumber': adminNumber,
          'schoolName': selectedSchoolToAssign,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          _showSnackBar("School assigned successfully!");

          // ✅ Redirect to NGODashboard using original NGO Admin phone
          final currentUserDetails = await SharedPrefsHelper.getUserDetails();
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
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
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
                      child: Text(p),
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
