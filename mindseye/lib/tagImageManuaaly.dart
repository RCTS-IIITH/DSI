import 'package:flutter/material.dart';
import 'package:mindseye/captureDrawing.dart';
import 'package:mindseye/shared_prefs_helper.dart'; // Import SharedPreferences helper
import 'dart:io'; // Import for File
import 'dart:convert'; // Import for jsonEncode
import 'package:http/http.dart' as http; // Import for http

class TagImageManually extends StatefulWidget {
  final String data;

  const TagImageManually(String s, {super.key, required this.data});

  @override
  _TagImageManuallyState createState() => _TagImageManuallyState();
}

class _TagImageManuallyState extends State<TagImageManually> {
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController childController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController labeledScoreController = TextEditingController();

  bool isLabeling = false;
  Map<String, String> userDetails = {
    'role': 'Guest',
    'phoneNumber': 'N/A'
  }; // Default values

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Load user details when the screen initializes
  }

  // Load user details from SharedPreferences
  Future<void> _loadUserDetails() async {
    final details = await SharedPrefsHelper.getUserDetails();
    print('Loaded user details: $details'); // <-- INSIDE a method
    setState(() {
      userDetails = details; // Update state with retrieved data
      clinicController.text = details['clinicName'] ?? '';
    });
  }

  @override
  void dispose() {
    clinicController.dispose();
    childController.dispose();
    ageController.dispose();
    notesController.dispose();
    labeledScoreController.dispose();
    super.dispose();
  }

  void toggleLabeling() {
    setState(() {
      isLabeling = !isLabeling;
    });
  }

  void validateAndProceed() {
    String clinicName = clinicController.text.trim();
    String childName = childController.text.trim();
    String age = ageController.text.trim();
    String labeledScore = isLabeling ? labeledScoreController.text.trim() : "";

    if (clinicName.isEmpty ||
        childName.isEmpty ||
        age.isEmpty ||
        (isLabeling && labeledScore.isEmpty)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Validation Error"),
          content: const Text("Please fill all the mandatory fields."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Proceed to next screen if validation passes
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaptureDrawingScreen(
          data: widget.data,
          clinicName: clinicController.text, // Pass the auto-filled value
          childName: childName,
          age: age,
          notes: notesController.text.trim(),
          labeledScore: labeledScore,
          phoneNumber: userDetails['phoneNumber'] ?? '', // Pass phone number
        ),
      ),
    );
  }

  // Add a function for submitting the form with image using MultipartRequest
  Future<void> submitTagImageManualReport({
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
      print('Tag image manual report submitted successfully!');
    } else {
      print('Failed to submit tag image manual report: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Tag Image ',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              const SizedBox(height: 16),
              const Text(
                "Please Fill the details",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: clinicController,
                decoration: InputDecoration(labelText: "Clinic Name"),
                enabled: false, // Optional: make it read-only for professionals
              ),
              const SizedBox(height: 16),
              _buildTextField("Child's Name *", childController),
              const SizedBox(height: 16),
              _buildTextField("Age *", ageController),
              const SizedBox(height: 16),
              _buildTextField("Optional Notes", notesController, maxLines: 3),
              const SizedBox(height: 16),
              if (isLabeling) ...[
                const Text(
                  "Labeling",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildTextField("Add Labeled Score *", labeledScoreController),
              ],
              const SizedBox(height: 16),
              if (!isLabeling)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: toggleLabeling,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("Label Manually",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: validateAndProceed,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Continue", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
