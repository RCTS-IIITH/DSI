import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UploadChildDetails extends StatefulWidget {
  @override
  _UploadChildDetailsState createState() => _UploadChildDetailsState();
}

class _UploadChildDetailsState extends State<UploadChildDetails> {
  final _nameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _classController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'Upload Child Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                _buildTextField(_nameController, 'Name *'),
                SizedBox(height: 16),
                _buildTextField(
                    _rollNumberController, 'Child UID (Roll Number) *'),
                SizedBox(height: 16),
                _buildTextField(_schoolIdController, 'School ID *'),
                SizedBox(height: 16),
                _buildTextField(_parentNameController, 'Parent Name *'),
                SizedBox(height: 16),
                _buildTextField(_parentPhoneController, 'Parent Phone *',
                    keyboardType: TextInputType.phone),
                SizedBox(height: 16),
                _buildTextField(_classController, 'Class *'),
                SizedBox(height: 16),
                _buildTextField(_ageController, 'Age *',
                    keyboardType: TextInputType.number),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitChildDetails,
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _submitChildDetails() async {
    final name = _nameController.text;
    final rollNumber = _rollNumberController.text;
    final schoolID = _schoolIdController.text;
    final parentName = _parentNameController.text;
    final parentPhoneNumber = _parentPhoneController.text;
    final classNum = _classController.text;
    final age = _ageController.text;

    print("Name: $name");
    print("Roll Number: $rollNumber");
    print("School ID: $schoolID");
    print("Parent Name: $parentName");
    print("Parent Phone: $parentPhoneNumber");
    print("Class: $classNum");
    print("Age: $age");

    final backendUrl = dotenv.env['BACKEND_URL']!;
    final url = '$backendUrl/api/users/childupload';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': name,
        'rollNumber': rollNumber,
        'schoolID': schoolID,
        'parentName': parentName,
        'parentPhoneNumber': parentPhoneNumber,
        'class': classNum,
        'age': age,
      }),
    );

    if (response.statusCode == 201) {
      print("Child details uploaded successfully!");
      Navigator.pop(context);
    } else {
      print("Failed to upload child details: ${response.body}");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _schoolIdController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _classController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
