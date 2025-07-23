import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';

class QuestionsScreen extends StatefulWidget {
  final String data;
  final String clinicName;
  final String childName;
  final String age;
  final String notes;
  final String labeledScore;
  final File? imageFile;

  const QuestionsScreen({
    Key? key,
    required this.data,
    required this.clinicName,
    required this.childName,
    required this.age,
    required this.notes,
    required this.labeledScore,
    this.imageFile,
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
      unfilledFields.add("House Select Dropdown");
    if (housePeopleVisitController.text.isEmpty)
      unfilledFields.add("Do people visit here?");
    if (houseAdditionalNotesController.text.isEmpty)
      unfilledFields.add("Additional notes for house");
    if (personWhoIsController.text.isEmpty)
      unfilledFields.add("Who is this person?");
    if (personAgeController.text.isEmpty)
      unfilledFields.add("How old are they?");
    if (personFavoriteThingController.text.isEmpty)
      unfilledFields.add("What's their favorite thing to do?");
    if (personDislikeController.text.isEmpty)
      unfilledFields.add("What's something they do not like?");
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

    // Image validation
    if (widget.imageFile == null || !await widget.imageFile!.exists()) {
      _showError("Image Missing", "Please attach an image before submitting.");
      return;
    }

    try {
      print("Selected Child Name: ${widget.childName}");

      final selectedChildDetails =
          await SharedPrefsHelper.getSelectedChildDetails();
      print("Stored Child Details: ${jsonEncode(selectedChildDetails)}");
      // Get user details
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final userRole = userDetails['role'] ?? '';
      final userId = userDetails['phoneNumber'] ?? '';

      // Get child details with validation
      String? childsName;
      int? childAge;

      if (widget.data == "Professional") {
        childsName = widget.childName;
        childAge = int.tryParse(widget.age);
        print("Professional Mode - Child Name: $childsName");
      } else {
        final selectedChildDetails =
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
        print("Parent Mode - Child Name: $childsName, Age: $childAge");
      }

      // Validate child name
      if (childsName == null || childsName.trim().isEmpty) {
        _showError("Invalid Child Details", "Child name cannot be empty.");
        return;
      }

      final isProfessional = widget.data == "Professional";

      final data = {
        'clinicName': widget.clinicName,
        'childsName': childsName,
        'age': childAge,
        'optionalNotes': isProfessional ? widget.notes : "",
        'flagforlabel': widget.labeledScore.isNotEmpty,
        'labelling': widget.labeledScore,
        'imageurl': widget.imageFile?.path ?? "",
        'houseAns': {
          'Who_Lives_Here': houseWhoLivesHereController.text,
          'Are_there_Happy': houseSelectDropdown,
          'Do_People_Visit_Here': housePeopleVisitController.text,
          'What_else_people_want': houseAdditionalNotesController.text,
        },
        'personAns': {
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
        // Only include schoolId/schoolName for Parent/Teacher
        if (!isProfessional) ...{
          'schoolId': selectedChildDetails['schoolId'],
          'schoolName': selectedChildDetails['schoolName'],
        }
      };

      // Submit report
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      final response = await http.post(
        Uri.parse('$backendUrl/api/reports/store-report-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print("Backend Response: ${response.body}");

      // Navigate back after successful submission
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
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
      _buildDropdownQuestion("Select", (value) => houseSelectDropdown = value),
      _buildQuestionField(housePeopleVisitController, "Do people visit here?"),
      _buildQuestionField(houseAdditionalNotesController,
          "What else do the people in the house want to add?"),
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
