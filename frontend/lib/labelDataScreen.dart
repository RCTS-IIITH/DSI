import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Assuming these are your imports
import 'package:mindseye/shared_prefs_helper.dart'; // SharedPrefsHelper
// Report model/controller

class LabelDataScreen extends StatefulWidget {
  final String reportId;

  const LabelDataScreen({super.key, required this.reportId});

  @override
  _LabelDataScreenState createState() => _LabelDataScreenState();
}

class _LabelDataScreenState extends State<LabelDataScreen> {
  final TextEditingController _manualScoreController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  // Add new state variables
  int? modelScore;
  int? existingManualScore;

  Future<void> _fetchScores() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
          'http://localhost:3000/api/reports/get-report-data-clinic/${widget.reportId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          modelScore = data['score'];
          existingManualScore = data['manualScore'];
          if (existingManualScore != null) {
            _manualScoreController.text = existingManualScore.toString();
          }
        });
      }
    } catch (e) {
      setState(() => _error = "Failed to fetch scores: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAndUpdate() async {
    final manualScore = _manualScoreController.text.trim();

    if (manualScore.isEmpty) {
      setState(() {
        _error = "Please enter a valid score";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final submittedByPhone = userDetails['phoneNumber'] ?? '';
      String backendUrl = dotenv.env['BACKEND_URL']!;
      // Remove any colon from reportId if present
      final cleanReportId = widget.reportId.replaceAll(':', '');

      final url =
          Uri.parse('$backendUrl/api/child-data/update-score/$cleanReportId');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'manualScore': int.parse(manualScore),
          'labeledBy': submittedByPhone,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Score updated successfully")),
        );
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['error'] ?? "Failed to update score";
        setState(() {
          _error = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to update score: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _manualScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Label Data',
          style: TextStyle(color: Colors.black87, fontSize: 20),
        ),
        centerTitle: true,
      ),
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
                'Report ID: ${widget.reportId}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 32),
              Text(
                'Model Predicted Score: 87',
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
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
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
