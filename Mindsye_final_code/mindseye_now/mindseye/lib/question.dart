import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/parentDashboard.dart';
import 'package:mindseye/professionalDashboard.dart';
import 'package:mindseye/schoolDashboard.dart';
import 'package:http/http.dart' as http;

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
  // const QuestionsScreen({Key? key, required this.data, required String clinicName, required String childName, required String age, required String notes, required String labeledScore, File? imageFile}) : super(key: key);

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
    print(widget.data);
    print(widget.clinicName);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    List<String> unfilledFields = [];

    // Validate house questions
    if (houseWhoLivesHereController.text.isEmpty)
      unfilledFields.add("Who lives here?");
    if (houseSelectDropdown == null)
      unfilledFields.add("House Select Dropdown");
    if (housePeopleVisitController.text.isEmpty)
      unfilledFields.add("Do people visit here?");
    if (houseAdditionalNotesController.text.isEmpty)
      unfilledFields.add("Additional notes for house");

    // Validate person questions
    if (personWhoIsController.text.isEmpty)
      unfilledFields.add("Who is this person?");
    if (personAgeController.text.isEmpty)
      unfilledFields.add("How old are they?");
    if (personFavoriteThingController.text.isEmpty)
      unfilledFields.add("What's their favorite thing to do?");
    if (personDislikeController.text.isEmpty)
      unfilledFields.add("What's something they do not like?");

    // Validate tree questions
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

    String backendUrl = dotenv.env['BACKEND_URL']!;

    if (unfilledFields.isEmpty) {
      final uri = Uri.parse('${backendUrl}/api/reports/store-report-data');

      // Send a POST request to the server
      final data = {
        'clinicsName': widget.clinicName,
        'childsName': widget.childName,
        'age': widget.age,
        'optionalNotes': widget.notes,
        'flagforlabel': widget.labeledScore == "" ? "false" : "true",
        'labelling': widget.labeledScore,
        'imageurl': widget.imageFile!.path,
        'houseAns': {
          'WhoLivesHere': houseWhoLivesHereController.text,
          'ArethereHappy': houseSelectDropdown,
          'DoPeopleVisitHere': housePeopleVisitController.text,
          'Whatelsepeoplewant': houseAdditionalNotesController.text,
        },
        'personAns': {
          'Whoisthisperson': personWhoIsController.text,
          'Howoldarethey': personAgeController.text,
          'Whatsthierfavthing': personFavoriteThingController.text,
          'Whattheydontlike': personDislikeController.text,
        },
        'treeAns': {
          'Whatkindoftree': treeTypeController.text,
          'howoldisit': treeAgeController.text,
          'whatseasonisit': treeSeasonController.text,
          'anyonetriedtocut': treeCutDownDropdown,
          'whatelsegrows': treeNearbyController.text,
          'whowaters': treeWateredByController.text,
          'doesitgetenoughsunshine': treeSunshineDropdown,
        }
      };
      print(data);
      await http.post(uri, body: {
        'clinicsName': widget.clinicName,
        'childsName': widget.childName,
        'age': widget.age,
        'optionalNotes': widget.notes,
        'flagforlabel': widget.labeledScore == "" ? "false" : "true",
        'labelling': widget.labeledScore,
        'imageurl': widget.imageFile!.path,
        'WhoLivesHere': houseWhoLivesHereController.text,
        'ArethereHappy': houseSelectDropdown,
        'DoPeopleVisitHere': housePeopleVisitController.text,
        'Whatelsepeoplewant': houseAdditionalNotesController.text,
        'Whoisthisperson': personWhoIsController.text,
        'Howoldarethey': personAgeController.text,
        'Whatsthierfavthing': personFavoriteThingController.text,
        'Whattheydontlike': personDislikeController.text,
        'Whatkindoftree': treeTypeController.text,
        'howoldisit': treeAgeController.text,
        'whatseasonisit': treeSeasonController.text,
        'anyonetriedtocut': treeCutDownDropdown,
        'whatelsegrows': treeNearbyController.text,
        'whowaters': treeWateredByController.text,
        'doesitgetenoughsunshine': treeSunshineDropdown,
      });

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Incomplete Fields"),
          content: SingleChildScrollView(
            child: ListBody(
              children: unfilledFields.map((field) => Text(field)).toList(),
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
