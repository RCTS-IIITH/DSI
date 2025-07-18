import 'package:flutter/material.dart';
import 'package:mindseye/captureDrawing.dart';
import 'package:mindseye/shared_prefs_helper.dart'; // Import SharedPreferences helper

class TagImageManually extends StatefulWidget {
  final String data;

  const TagImageManually({super.key, required this.data});

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
    setState(() {
      userDetails = details; // Update state with retrieved data
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
          clinicName: clinicName,
          childName: childName,
          age: age,
          notes: notesController.text.trim(),
          labeledScore: labeledScore,
          phoneNumber: userDetails['phoneNumber'] ?? '', // Pass phone number
        ),
      ),
    );
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
        centerTitle: true,
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

              // 🧾 User Info Card
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Role: ${userDetails['role']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Phone: ${userDetails['phoneNumber']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),
              const SizedBox(height: 16),

              const Text(
                "Please Fill the details",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 16),
              _buildTextField("Clinic's Name *", clinicController),
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
                  child: const Text("Continue",
                      style: TextStyle(color: Colors.white)),
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
