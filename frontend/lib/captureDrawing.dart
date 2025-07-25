import 'dart:io';
import 'dart:convert'; // Added for jsonEncode
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindseye/question.dart';
// QuestionsScreen
import 'package:mindseye/shared_prefs_helper.dart'; // SharedPrefsHelper
import 'package:http/http.dart' as http; // Added for http.MultipartRequest

class CaptureDrawingScreen extends StatefulWidget {
  final String clinicName; // Optional for non-professionals
  final String childName; // Optional for non-professionals
  final String age; // Optional for non-professionals
  final String notes; // Optional for non-professionals
  final String labeledScore; // Optional for non-professionals
  final String
      data; // Role of the user (e.g., "Professional", "Parent", "Teacher")
  final String? phoneNumber; // Optional phone number

  const CaptureDrawingScreen({
    super.key,
    this.clinicName = '', // Default value for non-professionals
    this.childName = '', // Default value for non-professionals
    this.age = '', // Default value for non-professionals
    this.notes = '', // Default value for non-professionals
    this.labeledScore = '', // Default value for non-professionals
    required this.data, // Required role
    this.phoneNumber, // Optional parameter
  });

  @override
  _CaptureDrawingScreenState createState() => _CaptureDrawingScreenState();
}

class _CaptureDrawingScreenState extends State<CaptureDrawingScreen> {
  File? _image;
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

  // Function to pick an image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to capture/upload image. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Replace the report submission logic (where you navigate to QuestionsScreen or submit the report) with the following pattern:

  Future<void> submitReportWithImage({
    required File imageFile,
    required Map<String, dynamic> reportFields,
  }) async {
    final backendUrl = 'http://localhost:3000/api/reports/store-report-data';
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
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Report submitted successfully!');
    } else {
      print('Failed to submit report: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Capture Drawing',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Conditionally display professional-specific fields
              if (widget.data == "Professional") ...[
                Text('Clinic Name: $clinicName'),
                Text('Child Name: ${widget.childName}'),
                Text('Age: ${widget.age}'),
                Text('Notes: ${widget.notes}'),
                Text('Labeled Score: ${widget.labeledScore}'),
              ],

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.contain),
                        )
                      : const Center(
                          child: Text(
                            'No Image Selected',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Capture Button
              if (_image == null) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Capture',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upload',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _image != null
                      ? () async {
                          // Only fetch stored child details for Parents and Teachers
                          Map<String, String> selectedChildDetails = {};
                          String finalChildName = '';
                          String finalAge = '';

                          if (widget.data == "Professional") {
                            // Use directly passed values for Professional
                            finalChildName = widget.childName;
                            finalAge = widget.age;
                            print(
                                'Professional Mode - Using passed details: $finalChildName, Age: $finalAge');
                          } else {
                            // Fetch from SharedPrefs for Parent/Teacher
                            selectedChildDetails = await SharedPrefsHelper
                                .getSelectedChildDetails();
                            finalChildName = selectedChildDetails['name'] ?? '';
                            finalAge = selectedChildDetails['age'] ?? '';
                            print(
                                'Parent/Teacher Mode - Using stored details: $finalChildName, Age: $finalAge');
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionsScreen(
                                clinicName: widget.data == "Professional"
                                    ? widget.clinicName
                                    : "",
                                childName: finalChildName,
                                age: finalAge,
                                notes: widget.notes,
                                labeledScore: widget.labeledScore,
                                imageFile: _image!,
                                data: widget.data,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _image != null ? Colors.black : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please ensure the drawing is centered.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
