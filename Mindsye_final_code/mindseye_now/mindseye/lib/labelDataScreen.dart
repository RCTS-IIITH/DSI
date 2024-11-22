import 'package:flutter/material.dart';
import 'package:mindseye/professionalDashboard.dart';

class LabelDataScreen extends StatefulWidget {
  @override
  _LabelDataScreenState createState() => _LabelDataScreenState();
}

class _LabelDataScreenState extends State<LabelDataScreen> {
  final TextEditingController _manualScoreController = TextEditingController();
  int modelPredictedScore = 87; // Example score, update as needed
  String reportId = "82736"; // Example report ID, update as needed

  @override
  void dispose() {
    _manualScoreController.dispose();
    super.dispose();
  }

  void _confirmAndUpdate() {
    String manualScore = _manualScoreController.text;
    if (manualScore.isNotEmpty) {
      // Here, add your logic to handle the manual score submission
      print("Manual Score: $manualScore"); // Placeholder for your action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Score Updated Successfully!')),
      );
      _manualScoreController.clear(); // Clear the input after submission
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a score')),
      );
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
              Text(
                'Label Previous Data',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Report ID: $reportId',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Model Predicted Score: $modelPredictedScore',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 32),
              Text(
                'Add Manual Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _manualScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Add Manual Score *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _confirmAndUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm & Update',
                    style: TextStyle(
                      fontSize: 18,
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
