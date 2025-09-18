import 'package:flutter/material.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'dart:convert'; // Added for jsonEncode
import 'dart:io'; // Added for File
import 'package:http/http.dart' as http; // Added for http.MultipartRequest

class TagImageScreen extends StatefulWidget {
  const TagImageScreen({super.key});

  @override
  _TagImageScreenState createState() => _TagImageScreenState();
}

class _TagImageScreenState extends State<TagImageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _childIdController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();

  String clinicName = '';

  @override
  void initState() {
    super.initState();
    SharedPrefsHelper.getUserDetails().then((details) {
      setState(() {
        clinicName = details['clinicName'] ?? '';
      });
    });
  }

  @override
  void dispose() {
    _childIdController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission logic here
      print("Child ID: ${_childIdController.text}");
      print("Age: ${_ageController.text}");
      print("Notes: ${_notesController.text}");
    }
  }

  // Add a function for submitting the form with image using MultipartRequest
  Future<void> submitTagImageReport({
    required File imageFile,
    required Map<String, dynamic> reportFields,
  }) async {
    final backendUrl = 'http://localhost:3001/api/reports/store-report-data';
    var request = http.MultipartRequest('POST', Uri.parse(backendUrl));

    // Add all text fields
    reportFields.forEach((key, value) {
      if (value is Map || value is List) {
        request.fields[key] = jsonEncode(value);
      } else {
        request.fields[key] = value.toString();
      }
    });

    // Add the image file
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Tag image report submitted successfully!');
    } else {
      print('Failed to submit tag image report: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tag Image',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _childIdController,
                decoration: InputDecoration(
                  labelText: 'Child ID / Roll Number *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Child ID / Roll Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Age *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Optional Notes',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Submit for Processing',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Text("Clinic Name: $clinicName",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
