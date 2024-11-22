import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mindseye/adminDahboard.dart';

class UploadChildDetails extends StatefulWidget {
  @override
  _UploadChildDetailsState createState() => _UploadChildDetailsState();
}

class _UploadChildDetailsState extends State<UploadChildDetails> {
  final _nameController = TextEditingController();
  final _uidController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController(); // Added school controller
  final _dobController = TextEditingController();

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
                'Upload Child Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32), // Space below title
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
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
                controller: _uidController,
                decoration: InputDecoration(
                  labelText: 'Child UID *',
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
                controller: _parentPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Parent Phone *',
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
                controller: _classController,
                decoration: InputDecoration(
                  labelText: 'Class *',
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
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: 'School *',
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
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date Of Birth *',
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
                    // Get the values from the text fields
                    final name = _nameController.text;
                    final uid = _uidController.text;
                    final phone = _parentPhoneController.text;
                    final teacherClass = _classController.text;
                    final school = _schoolController.text;
                    final dob = _dobController.text;

                    // Print the values to the console
                    print("Name: $name");
                    print("UID: $uid");
                    print("Parent Phone: $phone");
                    print("Class: $teacherClass");
                    print("School: $school");
                    print("Date of Birth: $dob");

                    // Send post request to the backend
                    // const url = "http://localhost:3000/api/users/childupload";
                    String backendUrl = dotenv.env['BACKEND_URL']!;

                    final url = '${backendUrl}/api/users/childupload';
                    var response = await http.post(
                      Uri.parse(url),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{
                        'name': name,
                        'uid': uid,
                        'phone': phone,
                        'class': teacherClass,
                        'school': school,
                        'dob': dob,
                      }),
                    );

                    Navigator.pop(context);
                    // Handle response
                    if (response.statusCode == 201) {
                      print("Child details uploaded successfully!");
                    } else {
                      print(
                          "Failed to upload child details: ${response.body}");
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
                    'Upload',
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

  @override
  void dispose() {
    _nameController.dispose();
    _uidController.dispose();
    _parentPhoneController.dispose();
    _classController.dispose();
    _schoolController.dispose(); // Dispose the school controller
    _dobController.dispose();
    super.dispose();
  }
}
