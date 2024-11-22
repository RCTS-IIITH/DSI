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
import 'package:mindseye/NGOdashboard.dart';
import 'package:http/http.dart' as http;

class CreateSchoolAccount extends StatefulWidget {
  @override
  _CreateSchoolAccountState createState() => _CreateSchoolAccountState();
}

class _CreateSchoolAccountState extends State<CreateSchoolAccount> {
  bool _isPasswordVisible = false;
  String? _selectedProfessionalId; // Stores the selected value

  // TextEditingControllers for fields
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _udiseNumberController = TextEditingController();

  // List of options for Assigned Professional ID
  List<String> _professionalIds = [];

  // final uri = Uri.parse('http://localhost:3000/api/users/getProfessionalIds');
  final uri = Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/getProfessionalIds');

  Future<void> getProfessionalIds() async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<String> professionalIds = [];
        print(response.body);
        final List<dynamic> data = json.decode(response.body);
        print(data);
        for (var i = 0; i < data.length; i++) {
          final String display = data[i]["name"] + ' (' + data[i]["ProfessionalID"] + ')';
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
    // Dispose controllers to free up resources
    _schoolNameController.dispose();
    _addressController.dispose();
    _udiseNumberController.dispose();
    super.dispose();
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
              SizedBox(height: 40), // Space from top
              Text(
                'Create School Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32), // Space below title
              TextField(
                controller: _schoolNameController,
                decoration: InputDecoration(
                  labelText: 'School Name *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _udiseNumberController,
                decoration: InputDecoration(
                  labelText: 'School UDISE Number *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProfessionalId,
                items: _professionalIds
                    .map((id) => DropdownMenuItem<String>(
                          value: id,
                          child: Text(id),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProfessionalId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Assigned Professional ID *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedProfessionalId != null) {
                      // it is in form of fggy (ProfessionalID). parse it
                      _selectedProfessionalId = _selectedProfessionalId!.split(' ')[1].split('(')[1].split(')')[0];
                      print(_selectedProfessionalId);
                      final uri = Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-school');
                          // 'http://localhost:3000/api/users/create-school');

                      // Submit data to the server
                      await http.post(uri, body: {
                        'schoolName': _schoolNameController.text,
                        'address': _addressController.text,
                        'udiseNumber': _udiseNumberController.text,
                        'assignedProfessionalId': _selectedProfessionalId,
                      });

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a professional ID'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create School Account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
