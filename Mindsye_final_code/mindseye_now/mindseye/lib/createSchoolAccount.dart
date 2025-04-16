// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:mindseye/NGOdashboard.dart';
// import 'package:http/http.dart' as http;

// class CreateSchoolAccount extends StatefulWidget {
//   @override
//   _CreateSchoolAccountState createState() => _CreateSchoolAccountState();
// }

// class _CreateSchoolAccountState extends State<CreateSchoolAccount> {
//   bool _isPasswordVisible = false;
//   String? _selectedProfessionalId; // Stores the selected value

//   // List of options for Assigned Professional ID
//   // final List<String> _professionalIds = [
//   //   'Professional 1',
//   //   'Professional 2',
//   //   'Professional 3',
//   //   'Professional 4',
//   // ];

//   List<String> _professionalIds = [];

//   final uri = Uri.parse('http://localhost:3000/api/users/getProfessionalIds');

//   Future<void> getProfessionalIds() async {
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final List<String> professionalIds = [];
//         print(response.body);
//         final List<dynamic> data = json.decode(response.body);
//         print(data);
//         for (var i = 0; i < data.length; i++) {
//           final String display = data[i]["name"] + ' (' + data[i]["ProfessionalID"] + ')';
//           professionalIds.add(display);
//         }
//         setState(() {
//           _professionalIds = professionalIds;
//         });
//       } else {
//         print('Failed to load professional IDs');
//       }
//     } catch (e) {
//       print('Error loading professional IDs: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getProfessionalIds();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 40), // Space from top
//               Text(
//                 'Create School Account',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 32), // Space below title
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'School Name *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Address *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'School UDISE Number *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedProfessionalId,
//                 items: _professionalIds
//                     .map((id) => DropdownMenuItem<String>(
//                           value: id,
//                           child: Text(id),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedProfessionalId = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Assigned Professional ID *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_selectedProfessionalId != null) {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => NGODashboard(),
//                         ),
//                         (Route<dynamic> route) =>
//                             false, // Removes all previous routes
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Please select a professional ID'),
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Create School Account',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CreateSchoolAccount extends StatefulWidget {
  const CreateSchoolAccount({super.key});

  @override
  _CreateSchoolAccountState createState() => _CreateSchoolAccountState();
}

class _CreateSchoolAccountState extends State<CreateSchoolAccount> {
  String? _selectedProfessionalId;
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _udiseNumberController = TextEditingController();
  List<String> _professionalIds = [];

  final uri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/getProfessionalIds');

  Future<void> getProfessionalIds() async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<String> professionalIds = [];
        final List<dynamic> data = json.decode(response.body);
        for (var i = 0; i < data.length; i++) {
          final String display =
              "${data[i]["name"]} (${data[i]["ProfessionalID"]})";
          professionalIds.add(display);
        }
        setState(() {
          _professionalIds = professionalIds;
        });
      } else {
        print('Failed to load professional IDs');
      }
    } catch (e) {
      print('Error loading professional IDs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getProfessionalIds();
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _udiseNumberController.dispose();
    super.dispose();
  }

  void showAlertDialog(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> createSchoolAccount() async {
    String schoolName = _schoolNameController.text.trim();
    String address = _addressController.text.trim();
    String udiseNumber = _udiseNumberController.text.trim();

    if (schoolName.isEmpty ||
        address.isEmpty ||
        udiseNumber.isEmpty ||
        _selectedProfessionalId == null) {
      String missingFields = "";
      if (schoolName.isEmpty) missingFields += "- School Name\n";
      if (address.isEmpty) missingFields += "- Address\n";
      if (udiseNumber.isEmpty) missingFields += "- UDISE Number\n";
      if (_selectedProfessionalId == null)
        missingFields += "- Assigned Professional ID\n";

      showAlertDialog("Missing Information",
          "Please fill in the following fields:\n$missingFields");
      return;
    }

    _selectedProfessionalId =
        _selectedProfessionalId!.split(' ')[1].split('(')[1].split(')')[0];
    final uri =
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-school');
    try {
      final response = await http.post(uri, body: {
        'schoolName': schoolName,
        'address': address,
        'udiseNumber': udiseNumber,
        'assignedProfessionalId': _selectedProfessionalId,
      });

      if (response.statusCode == 200) {
        showAlertDialog("Success", "School account created successfully!",
            onOk: () {
          Navigator.pop(context);
        });
      } else {
        showAlertDialog(
            "Error", "Failed to create school account. Please try again.");
      }
    } catch (e) {
      showAlertDialog("Error", "Something went wrong: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Create School Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                  controller: _schoolNameController,
                  decoration: _inputDecoration("School Name *")),
              const SizedBox(height: 16),
              TextField(
                  controller: _addressController,
                  decoration: _inputDecoration("Address *")),
              const SizedBox(height: 16),
              TextField(
                  controller: _udiseNumberController,
                  decoration: _inputDecoration("School UDISE Number *")),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProfessionalId,
                items: _professionalIds
                    .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedProfessionalId = value),
                decoration: _inputDecoration("Assigned Professional ID *"),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: createSchoolAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Create School Account",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
