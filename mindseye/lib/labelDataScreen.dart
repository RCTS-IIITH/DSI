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
  // Controllers for all three scores
  final TextEditingController _houseScoreController = TextEditingController();
  final TextEditingController _treeScoreController = TextEditingController();
  final TextEditingController _personScoreController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  // Current scores from the report
  Map<String, dynamic>? currentScores;
  Map<String, dynamic>? existingManualScores;

  @override
  void initState() {
    super.initState();
    _fetchScores();
  }

  Future<void> _fetchScores() async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
          '${dotenv.env['BACKEND_URL'] ?? 'http://localhost:3001'}/api/reports/get-report-data-clinic/${widget.reportId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentScores = data['images'];
          existingManualScores = {
            'house': data['images']?['house']?['manualScore'],
            'tree': data['images']?['tree']?['manualScore'],
            'person': data['images']?['person']?['manualScore'],
          };

          // Pre-fill existing manual scores
          if (existingManualScores?['house'] != null) {
            _houseScoreController.text =
                existingManualScores!['house'].toString();
          }
          if (existingManualScores?['tree'] != null) {
            _treeScoreController.text =
                existingManualScores!['tree'].toString();
          }
          if (existingManualScores?['person'] != null) {
            _personScoreController.text =
                existingManualScores!['person'].toString();
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
    final houseScore = _houseScoreController.text.trim();
    final treeScore = _treeScoreController.text.trim();
    final personScore = _personScoreController.text.trim();

    // Validate that at least one score is provided
    if (houseScore.isEmpty && treeScore.isEmpty && personScore.isEmpty) {
      setState(() {
        _error = "Please enter at least one score";
      });
      return;
    }

    // Validate score ranges
    final scores = [
      if (houseScore.isNotEmpty) int.tryParse(houseScore),
      if (treeScore.isNotEmpty) int.tryParse(treeScore),
      if (personScore.isNotEmpty) int.tryParse(personScore),
    ];

    for (var score in scores) {
      if (score == null || score < 0 || score > 100) {
        setState(() {
          _error = "Scores must be numbers between 0 and 100";
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final submittedByPhone = userDetails['phoneNumber'] ?? '';
      String backendUrl = dotenv.env['BACKEND_URL']!;
      final cleanReportId = widget.reportId.replaceAll(':', '');

      final url = Uri.parse(
          '$backendUrl/api/child-data/update-all-scores/$cleanReportId');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'houseScore': houseScore.isNotEmpty ? int.parse(houseScore) : null,
          'treeScore': treeScore.isNotEmpty ? int.parse(treeScore) : null,
          'personScore': personScore.isNotEmpty ? int.parse(personScore) : null,
          'labeledBy': submittedByPhone,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Scores updated successfully")),
        );
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        String errorMsg = responseData['error'] ?? "Failed to update scores";
        setState(() => _error = errorMsg);
      }
    } catch (e) {
      setState(() => _error = "Error updating scores: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _houseScoreController.dispose();
    _treeScoreController.dispose();
    _personScoreController.dispose();
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
                'Model Predicted Scores',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'House: ${currentScores?['house']?['score'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Tree: ${currentScores?['tree']?['score'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Person: ${currentScores?['person']?['score'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 32),
              Text(
                'Add Manual Scores',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _houseScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'House Score (0-100)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _treeScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Tree Score (0-100)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _personScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Person Score (0-100)',
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
