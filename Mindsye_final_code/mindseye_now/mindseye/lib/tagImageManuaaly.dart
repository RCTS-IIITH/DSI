import 'package:flutter/material.dart';
import 'package:mindseye/captureDrawing.dart';

class TagImageManually extends StatefulWidget {
  final String data;

  const TagImageManually({Key? key, required this.data}) : super(key: key);

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
          title: Text("Validation Error"),
          content: Text("Please fill all the mandatory fields."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tag Image"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient ID : 682763894",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField("Clinic's Name *", clinicController),
            SizedBox(height: 16),
            _buildTextField("Child's Name *", childController),
            SizedBox(height: 16),
            _buildTextField("Age *", ageController),
            SizedBox(height: 16),
            _buildTextField("Optional Notes", notesController, maxLines: 3),
            SizedBox(height: 16),
            if (isLabeling) ...[
              Text(
                "Labeling",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildTextField("Add Labeled Score *", labeledScoreController),
            ],
            SizedBox(height: 16),
            if (!isLabeling)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: toggleLabeling,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: Text("Label Manually", style: TextStyle(color: Colors.white)),
                ),
              ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: validateAndProceed,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text("Continue", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
