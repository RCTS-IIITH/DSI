import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mindseye/adminDahboard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadTeacherDetails extends StatefulWidget {
  @override
  _UploadTeacherDetailsState createState() => _UploadTeacherDetailsState();
}

class _UploadTeacherDetailsState extends State<UploadTeacherDetails> {
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _schoolController = TextEditingController();
  final _phoneController = TextEditingController();

  void _handleUpload() async {
    String name = _nameController.text;
    String teacherClass = _classController.text;
    String school = _schoolController.text;
    String phone = _phoneController.text;

    print("Name: $name");
    print("Class: $teacherClass");
    print("School: $school");
    print("Phone: $phone");

    // const url = 'http://localhost:3000/api/users/teacherupload';
    String backendUrl = dotenv.env['BACKEND_URL']!;

    final url = '${backendUrl}/api/users/teacherupload';

    // Constructing the JSON object
    // send a post request to url
    var response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'class': teacherClass,
        'school': school,
        'phone': phone,
      }),
    );

    Navigator.pop(context);
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
                'Upload Teacher Details',
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
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone *',
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
                  onPressed: _handleUpload,
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
    _classController.dispose();
    _schoolController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
