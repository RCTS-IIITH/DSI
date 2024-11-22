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
import 'package:mindseye/NGOdashboard.dart';
import 'package:http/http.dart' as http;
import 'package:envied/envied.dart';

class AssignAdminToSchoolScreen extends StatefulWidget {
  @override
  _AssignAdminToSchoolScreenState createState() =>
      _AssignAdminToSchoolScreenState();
}

class _AssignAdminToSchoolScreenState extends State<AssignAdminToSchoolScreen> {
  // Controllers for autofill fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _assignedSchoolsController =
      TextEditingController();

  // Variables for dropdown selection
  String? selectedAdmin;
  String? selectedSchoolToAssign;
  String backendUrl = dotenv.env['BACKEND_URL']!;
  // Example data for dropdowns

  List<String> admins = [];
  List<String> schools = [];
  List<String> dispalyschools = [];

  // create a dictionary to store the admin name and phone number and assigned schools
  Map<String, Map<String, String>> adminData = {};
  @override
  // Future<void> initState() async {
  //   super.initState();

  Future<void> MyinitState() async {
    // final adminUri = Uri.parse('http://localhost:3000/api/users/get-admins');
    final adminUri = Uri.parse('${backendUrl}/api/users/get-admins');
    // final schoolUri = Uri.parse('http://localhost:3000/api/users/get-schools');
    final schoolUri = Uri.parse('${backendUrl}/api/users/get-schools');

    // Fetch data from the server
    await http.get(adminUri).then((response) {
      //  data = response.body;
      final List<dynamic> data = json.decode(response.body);
      print(data);
      for (var admin in data) {
        setState(() {
          admins.add(admin['name']);
        });
      }

      // Store admin data in a dictionary
      for (var admin in data) {
        setState(() {
          adminData[admin['name']] = {
            'phone': admin['number'],
            'assignedSchools': admin['assignedSchoolList'].join(', '),
          };
        });
      }
    });

    await http.get(schoolUri).then((response) {
      //  data = response.body;
      final List<dynamic> data = json.decode(response.body);
      print(data);
      for (var school in data) {
        setState(() {
          schools.add(school['schoolName']);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch data from the server
    // final adminUri = Uri.parse('http://localhost:3000/api/users/get-admins');
    // final schoolUri =
    //     Uri.parse('http://localhost:3000/api/schools/get-schools');

    // // Fetch data from the server
    // http.get(adminUri).then((response) {
    //   //  data = response.body;
    //   final List<dynamic> data = json.decode(response.body);
    //   for (var admin in data) {
    //     admins.add(admin['name']);
    //   }

    //   // Store admin data in a dictionary
    //   for (var admin in data) {
    //     adminData[admin['name']] = {
    //       'phone': admin['phone'],
    //       'assignedSchools': admin['assignedSchools'].join(', '),
    //     };
    //   }
    // });

    // http.get(schoolUri).then((response) {
    //   //  data = response.body;
    //   final List<dynamic> data = json.decode(response.body);
    //   for (var school in data) {
    //     schools.add(school['name']);
    //   }
    // });

    MyinitState();

    // Initialize controllers with default values
    // _phoneController.text = '123-456-7890'; // Example phone number
    // _assignedSchoolsController.text =
    //     'School A, School B'; // Example assigned schools
  }

  @override
  void dispose() {
    // Dispose of controllers when no longer needed
    _phoneController.dispose();
    _assignedSchoolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Admin To School'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Admin (Dropdown)',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              value: selectedAdmin,
              isExpanded: true,
              items: admins.map((admin) {
                return DropdownMenuItem<String>(
                  value: admin,
                  child: Text(admin),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAdmin = value;

                  // remove the schools that are already assigned to the admin
                  List<String> assignedSchools =
                      adminData[value]!['assignedSchools']!.split(', ');
                  dispalyschools = schools
                      .where((school) => !assignedSchools.contains(school))
                      .toList();
                  _phoneController.text = adminData[value]!['phone'] as String;
                  _assignedSchoolsController.text =
                      adminData[value]!['assignedSchools'] as String;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Phone Number (autofill)',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _phoneController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Assigned Schools (autofill)',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _assignedSchoolsController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Select School to Assign',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              value: selectedSchoolToAssign,
              isExpanded: true,
              items: dispalyschools.map((school) {
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
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Handle save changes action
                  await http.post(
                    // Uri.parse('http://localhost:3000/api/users/assign-admin-to-school'),
                    Uri.parse('${backendUrl}/api/users/assign-admin-to-school'),
                    body: {
                      'adminName': selectedAdmin,
                      'schoolName': selectedSchoolToAssign,
                    },
                  );

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
