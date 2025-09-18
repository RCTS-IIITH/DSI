import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:http_parser/http_parser.dart';

class QuestionsScreen extends StatefulWidget {
  final String data;
  final String clinicName;
  final String childName;
  final String age;
  final String notes;
  final String labeledScore;
  final File houseImage;
  final File treeImage;
  final File personImage;

  const QuestionsScreen({
    Key? key,
    required this.data,
    required this.clinicName,
    required this.childName,
    required this.age,
    required this.notes,
    required this.labeledScore,
    required this.houseImage,
    required this.treeImage,
    required this.personImage,
  }) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for house questions
  final TextEditingController houseWhoLivesHereController =
      TextEditingController();
  String? houseSelectDropdown;
  final TextEditingController housePeopleVisitController =
      TextEditingController();
  final TextEditingController houseAdditionalNotesController =
      TextEditingController();

  // Controllers for person questions
  final TextEditingController personWhoIsController = TextEditingController();
  final TextEditingController personAgeController = TextEditingController();
  final TextEditingController personFavoriteThingController =
      TextEditingController();
  final TextEditingController personDislikeController = TextEditingController();

  // Controllers for tree questions
  final TextEditingController treeTypeController = TextEditingController();
  final TextEditingController treeAgeController = TextEditingController();
  final TextEditingController treeSeasonController = TextEditingController();
  String? treeCutDownDropdown;
  final TextEditingController treeNearbyController = TextEditingController();
  final TextEditingController treeWateredByController = TextEditingController();
  String? treeSunshineDropdown;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    // Field validation
    List<String> unfilledFields = [];
    if (houseWhoLivesHereController.text.isEmpty)
      unfilledFields.add("Who lives here?");
    if (houseSelectDropdown == null)
      unfilledFields.add("Are there happy people?");
    if (housePeopleVisitController.text.isEmpty)
      unfilledFields.add("Do people visit here?");
    if (personWhoIsController.text.isEmpty)
      unfilledFields.add("Who is this person?");
    if (personAgeController.text.isEmpty)
      unfilledFields.add("How old are they?");
    if (personFavoriteThingController.text.isEmpty)
      unfilledFields.add("What's their favorite thing to do?");
    if (personDislikeController.text.isEmpty)
      unfilledFields.add("What's something they do not like?");
    if (houseAdditionalNotesController.text.isEmpty)
      unfilledFields.add("What else do people want?");
    if (treeTypeController.text.isEmpty)
      unfilledFields.add("What kind of tree is this?");
    if (treeAgeController.text.isEmpty)
      unfilledFields.add("How old is the tree?");
    if (treeSeasonController.text.isEmpty)
      unfilledFields.add("What season is it?");
    if (treeCutDownDropdown == null)
      unfilledFields.add("Has anyone tried to cut it down?");
    if (treeNearbyController.text.isEmpty)
      unfilledFields.add("What else grows nearby?");
    if (treeWateredByController.text.isEmpty)
      unfilledFields.add("Who waters the tree?");
    if (treeSunshineDropdown == null)
      unfilledFields.add("Does the tree get enough sunshine?");

    if (unfilledFields.isNotEmpty) {
      _showValidationError("Incomplete Fields", unfilledFields);
      return;
    }

    // Image validation - check all three images are present
    if (!await widget.houseImage.exists() ||
        !await widget.treeImage.exists() ||
        !await widget.personImage.exists()) {
      _showError("Images Missing",
          "Please ensure all three images are captured before submitting.");
      return;
    }

    try {
      print("Selected Child Name: ${widget.childName}");

      // Get user details
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final userRole = userDetails['role'] ?? '';
      final userId = userDetails['phoneNumber'] ?? '';

      print("🔍 DEBUG: User Role from SharedPrefs: $userRole");
      print("🔍 DEBUG: Widget.data value: ${widget.data}");
      print("🔍 DEBUG: User Details: $userDetails");

      // Get child details with validation - use actual user role, not widget.data
      String? childsName;
      int? childAge;
      Map<String, String>? selectedChildDetails;

      if (userRole == "Professional") {
        // Professional mode - use widget data, ignore stored child details
        childsName = widget.childName;
        childAge = int.tryParse(widget.age);
        print(
            "Professional Mode - Using widget data: Child Name: $childsName, Age: $childAge");
      } else {
        // Parent/Teacher mode - use stored child details
        selectedChildDetails =
            await SharedPrefsHelper.getSelectedChildDetails();

        // Add validation check
        if (selectedChildDetails == null ||
            selectedChildDetails['name'] == null ||
            selectedChildDetails['name'].toString().trim().isEmpty) {
          print("Error: Invalid child details from SharedPrefs");
          _showError("Missing Child Details",
              "Please select a valid child before submitting.");
          return;
        }

        childsName = selectedChildDetails['name'].toString().trim();
        childAge = int.tryParse(selectedChildDetails['age'].toString());
        print(
            "Parent/Teacher Mode - Using stored details: $childsName, Age: $childAge");
      }

      // Validate child name
      if (childsName == null || childsName.trim().isEmpty) {
        _showError("Invalid Child Details", "Child name cannot be empty.");
        return;
      }

      final isProfessional = userRole == "Professional";

      final data = {
        'clinicName': widget.clinicName,
        'childsName': childsName,
        'age': childAge,
        'optionalNotes': isProfessional ? widget.notes : "",
        'flagforlabel': widget.labeledScore.isNotEmpty,
        'labelling': widget.labeledScore,
        'houseAns': {
          'Who_Lives_Here': houseWhoLivesHereController.text,
          'Are_there_Happy': houseSelectDropdown,
          'Do_People_Visit_Here': housePeopleVisitController.text,
        },
        'personAns': {
          'What_else_people_want': houseAdditionalNotesController.text,
          'Who_is_this_person': personWhoIsController.text,
          'How_old_are_they': personAgeController.text,
          'Whats_thier_fav_thing': personFavoriteThingController.text,
          'What_they_dont_like': personDislikeController.text,
        },
        'treeAns': {
          'What_kind_of_tree': treeTypeController.text,
          'how_old_is_it': treeAgeController.text,
          'what_season_is_it': treeSeasonController.text,
          'anyone_tried_to_cut': treeCutDownDropdown,
          'what_else_grows': treeNearbyController.text,
          'who_waters': treeWateredByController.text,
          'does_it_get_enough_sunshine': treeSunshineDropdown,
        },
        'submittedBy': {
          'role': userDetails['role'],
          'phone': userDetails['phoneNumber']
        },
        // Only include schoolId/schoolName and childId for Parent/Teacher
        if (!isProfessional) ...{
          'schoolId': selectedChildDetails?['schoolId'],
          'schoolName': selectedChildDetails?['schoolName'],
          'childId':
              selectedChildDetails?['id'] ?? selectedChildDetails?['_id'],
        }
      };

      // Submit the report with all three images
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      var request = http.MultipartRequest(
          'POST', Uri.parse('$backendUrl/api/reports/store-report-data'));

      // Add all text fields
      data.forEach((key, value) {
        if (value is Map || value is List) {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      });

      // Add all three images with correct field names and MIME types
      try {
        // Validate images before upload
        if (!await widget.houseImage.exists()) {
          throw Exception('House image file does not exist');
        }
        if (!await widget.treeImage.exists()) {
          throw Exception('Tree image file does not exist');
        }
        if (!await widget.personImage.exists()) {
          throw Exception('Person image file does not exist');
        }

        // Get file extensions and determine MIME types
        String getMimeType(String filePath) {
          final extension = filePath.split('.').last.toLowerCase();
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              return 'image/jpeg';
            case 'png':
              return 'image/png';
            default:
              return 'image/jpeg'; // Default fallback
          }
        }

        // Add images with proper MIME types
        request.files.add(await http.MultipartFile.fromPath(
            'houseImage', widget.houseImage.path,
            contentType: MediaType.parse(getMimeType(widget.houseImage.path))));

        request.files.add(await http.MultipartFile.fromPath(
            'treeImage', widget.treeImage.path,
            contentType: MediaType.parse(getMimeType(widget.treeImage.path))));

        request.files.add(await http.MultipartFile.fromPath(
            'personImage', widget.personImage.path,
            contentType:
                MediaType.parse(getMimeType(widget.personImage.path))));

        print('Images added to request successfully');
      } catch (e) {
        print('Error adding images to request: $e');
        _showError("Image Error",
            "Failed to prepare images for upload. Please try again.");
        return;
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        print('Report submitted successfully!');
        // Navigate back after successful submission
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        print('Failed to submit report: ${response.statusCode}');
        final responseBody = await response.stream.bytesToString();
        print('Response body: $responseBody');

        String errorMessage = "Failed to submit report. Please try again.";

        // Parse backend error messages
        if (responseBody.contains("Invalid file type")) {
          errorMessage =
              "Invalid file type. Please ensure images are JPEG, PNG, or JPG format.";
        } else if (responseBody.contains("Missing required fields")) {
          errorMessage =
              "Missing required fields. Please check all questions are answered.";
        } else if (responseBody.contains("Validation failed")) {
          errorMessage = "Validation failed. Please check your input.";
        }

        _showError("Submission Failed", errorMessage);
      }
    } catch (e) {
      print("Error submitting report: $e");
      _showError("Submission Error",
          "An error occurred while submitting the report. Please try again.");
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showValidationError(String title, List<String> fields) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: fields.map((field) => Text(field)).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Answer the Questions"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "House"),
            Tab(text: "Person"),
            Tab(text: "Tree"),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  kTextTabBarHeight -
                  70,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHouseQuestions(),
                  _buildPersonQuestions(),
                  _buildTreeQuestions(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseQuestions() {
    return _buildScrollableForm([
      _buildQuestionField(houseWhoLivesHereController, "Who lives here?"),
      _buildDropdownQuestion(
          "Are there happy people?", (value) => houseSelectDropdown = value),
      _buildQuestionField(housePeopleVisitController, "Do people visit here?"),
    ]);
  }

  Widget _buildPersonQuestions() {
    return _buildScrollableForm([
      _buildQuestionField(personWhoIsController, "Who is this person?"),
      _buildQuestionField(personAgeController, "How old are they?"),
      _buildQuestionField(
          personFavoriteThingController, "What's their favorite thing to do?"),
      _buildQuestionField(
          personDislikeController, "What's something they do not like?"),
      _buildQuestionField(
          houseAdditionalNotesController, "What else do people want?"),
    ]);
  }

  Widget _buildTreeQuestions() {
    return _buildScrollableForm([
      _buildQuestionField(treeTypeController, "What kind of tree is this?"),
      _buildQuestionField(treeAgeController, "How old is it?"),
      _buildQuestionField(treeSeasonController,
          "What season is it? (Spring/Summer/Autumn/Winter)"),
      _buildDropdownQuestion("Has anyone tried to cut it down?",
          (value) => treeCutDownDropdown = value),
      _buildQuestionField(treeNearbyController, "What else grows nearby?"),
      _buildQuestionField(treeWateredByController, "Who waters the tree?"),
      _buildDropdownQuestion("Does it get enough sunshine?",
          (value) => treeSunshineDropdown = value),
    ]);
  }

  Widget _buildQuestionField(
      TextEditingController controller, String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: question,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdownQuestion(String label, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: <String>['Yes', 'No'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildScrollableForm(List<Widget> children) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
