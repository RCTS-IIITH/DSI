import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:photo_view/photo_view.dart';

class PreviousSubmissionsScreen extends StatefulWidget {
  final String data;
  final String phone;

  const PreviousSubmissionsScreen({
    Key? key,
    required this.data,
    required this.phone,
  }) : super(key: key);

  @override
  _PreviousSubmissionsScreenState createState() =>
      _PreviousSubmissionsScreenState();
}

class _PreviousSubmissionsScreenState extends State<PreviousSubmissionsScreen> {
  List<dynamic> submissionSummary = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissionSummary();
  }

  Future<void> fetchSubmissionSummary() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final role = userDetails['role'] ?? '';
      final phone = userDetails['phoneNumber'] ?? '';
      if (role.isEmpty) throw Exception("Role cannot be empty");
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      final uri = Uri.http(
        Uri.parse(backendUrl).authority,
        '/api/users/get-submission-summary',
        {
          'role': role,
          if (role == "Parent") 'phone': phone,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          submissionSummary = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load submission summary: ${response.body}");
      }
    } catch (e) {
      print("Error fetching submission summary: $e");
      setState(() => isLoading = false);
    }
  }

  Widget buildChildSummaryCard(String name, int count) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.child_care, color: Colors.blue[800]),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text('$count submissions'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChildSubmissionsScreen(
                role: widget.data,
                phone: widget.phone,
                childsName: name,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Submissions'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissionSummary.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  itemCount: submissionSummary.length,
                  itemBuilder: (context, index) {
                    final childSummary = submissionSummary[index];
                    return buildChildSummaryCard(
                      childSummary['childsName'] ?? 'Unknown Child',
                      childSummary['submissionCount'] ?? 0,
                    );
                  },
                ),
    );
  }
}

// -------------------- ChildSubmissionsScreen --------------------

class ChildSubmissionsScreen extends StatefulWidget {
  final String role;
  final String? phone;
  final String childsName;

  const ChildSubmissionsScreen({
    Key? key,
    required this.role,
    this.phone,
    required this.childsName,
  }) : super(key: key);

  @override
  _ChildSubmissionsScreenState createState() => _ChildSubmissionsScreenState();
}

class _ChildSubmissionsScreenState extends State<ChildSubmissionsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> submissions = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    fetchSubmissions().then((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchSubmissions() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final role = userDetails['role'] ?? '';
      final phone = userDetails['phoneNumber'] ?? '';
      if (role.isEmpty) throw Exception("Role cannot be empty");
      final String backendUrl = dotenv.env['BACKEND_URL']!;
      final uri = Uri.http(
        Uri.parse(backendUrl).authority,
        '/api/users/get-submissions-by-child',
        {
          'role': role,
          if (role == "Parent") 'phone': phone,
          'childsName': widget.childsName,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          submissions = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load submissions: ${response.body}");
      }
    } catch (e) {
      print("Error fetching submissions: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildScoreRow(String label, String value, IconData icon,
      [Color? color]) {
    final iconColor = color ?? Colors.grey[700]!;
    final textColor = color ?? Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScoresSection(Map<String, dynamic> submission) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Icon(Icons.analytics, color: Colors.grey[800]),
        title: const Text(
          'Scores & Analysis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // House Drawing Scores
                _buildScoreRow(
                  'House Drawing',
                  _getScoreDisplay(submission['images']?['house']),
                  Icons.home,
                  Colors.blue,
                ),
                const Divider(),

                // Tree Drawing Scores
                _buildScoreRow(
                  'Tree Drawing',
                  _getScoreDisplay(submission['images']?['tree']),
                  Icons.park,
                  Colors.green,
                ),
                const Divider(),

                // Person Drawing Scores
                _buildScoreRow(
                  'Person Drawing',
                  _getScoreDisplay(submission['images']?['person']),
                  Icons.person,
                  Colors.orange,
                ),

                // Total Score
                if (_hasAnyManualScore(submission)) ...[
                  const Divider(),
                  _buildScoreRow(
                    'Total Score',
                    _calculateTotalScore(submission),
                    Icons.assessment,
                    Colors.purple,
                  ),
                ],

                // Reviewer Info
                if (_getAnyLabeledBy(submission) != null) ...[
                  const Divider(),
                  _buildScoreRow(
                    'Reviewed By',
                    _getAnyLabeledBy(submission) ?? 'N/A',
                    Icons.person,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreDisplay(Map<String, dynamic>? imageData) {
    if (imageData == null) return 'N/A';

    final manualScore = imageData['manualScore'];
    final aiScore = imageData['score'];

    if (manualScore != null) {
      return 'Professional: ${manualScore.toString()}% (AI: ${(aiScore ?? 0).toString()}%)';
    } else if (aiScore != null) {
      return 'AI: ${aiScore.toString()}% (Pending Review)';
    } else {
      return 'Pending Analysis';
    }
  }

  bool _hasAnyManualScore(Map<String, dynamic> submission) {
    final images = submission['images'];
    if (images == null) return false;

    return (images['house']?['manualScore'] != null) ||
        (images['tree']?['manualScore'] != null) ||
        (images['person']?['manualScore'] != null);
  }

  String _calculateTotalScore(Map<String, dynamic> submission) {
    final images = submission['images'];
    if (images == null) return 'N/A';

    int total = 0;
    int count = 0;

    final houseScore =
        images['house']?['manualScore'] ?? images['house']?['score'];
    final treeScore =
        images['tree']?['manualScore'] ?? images['tree']?['score'];
    final personScore =
        images['person']?['manualScore'] ?? images['person']?['score'];

    if (houseScore != null) {
      total += (houseScore as num).toInt();
      count++;
    }
    if (treeScore != null) {
      total += (treeScore as num).toInt();
      count++;
    }
    if (personScore != null) {
      total += (personScore as num).toInt();
      count++;
    }

    if (count == 0) return 'N/A';
    return '${(total / count).round()}%';
  }

  String? _getAnyLabeledBy(Map<String, dynamic> submission) {
    final images = submission['images'];
    if (images == null) return null;

    return images['house']?['labeledBy']?.toString() ??
        images['tree']?['labeledBy']?.toString() ??
        images['person']?['labeledBy']?.toString();
  }

  Widget buildQuestionItem(String question, String? answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            answer ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget buildStyledExpansionTile({
    required String title,
    required IconData icon,
    required Map<String, dynamic> answers,
  }) {
    final List<Widget> answerWidgets = answers.entries
        .map((entry) => buildQuestionItem(
              entry.key.replaceAll('_', ' '),
              entry.value?.toString(),
            ))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Row(
            children: [
              Icon(icon, color: Colors.grey[800]),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: answerWidgets,
        ),
      ),
    );
  }

  Widget _buildImageCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required dynamic score,
    required dynamic manualScore,
    required IconData icon,
    required Color color,
  }) {
    final displayScore = manualScore != null ? manualScore : score;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (displayScore != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${displayScore.toString()}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullscreenImageViewer(
                      imageUrl: 'http://localhost:3001/$imagePath',
                      heroTag: imagePath,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: imagePath,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'http://localhost:3001/$imagePath',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 32, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubmissionCard(int index) {
    final submission = submissions[index];
    final formattedDate = DateFormat.yMd()
        .add_jm()
        .format(DateTime.parse(submission['submittedAt']));

    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval((index / submissions.length), 1.0,
              curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval((index / submissions.length), 1.0,
              curve: Curves.easeOut),
        )),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    submission['childsName'] ?? 'Unknown Child',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text('Submitted At: $formattedDate'),
                ),
                ListTile(
                  title: Text('Age: ${submission['age'] ?? 'N/A'}'),
                ),
                // Add Scores Section
                buildScoresSection(submission),
                // Images Section - Display all three images
                if (submission['images'] != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Drawings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),

                        // House Image
                        if (submission['images']['house']?['path'] != null)
                          _buildImageCard(
                            context,
                            title: "House Drawing",
                            imagePath: submission['images']['house']['path'],
                            score: submission['images']['house']['score'],
                            manualScore: submission['images']['house']
                                ['manualScore'],
                            icon: Icons.home,
                            color: Colors.blue,
                          ),

                        SizedBox(height: 8),

                        // Tree Image
                        if (submission['images']['tree']?['path'] != null)
                          _buildImageCard(
                            context,
                            title: "Tree Drawing",
                            imagePath: submission['images']['tree']['path'],
                            score: submission['images']['tree']['score'],
                            manualScore: submission['images']['tree']
                                ['manualScore'],
                            icon: Icons.park,
                            color: Colors.green,
                          ),

                        SizedBox(height: 8),

                        // Person Image
                        if (submission['images']['person']?['path'] != null)
                          _buildImageCard(
                            context,
                            title: "Person Drawing",
                            imagePath: submission['images']['person']['path'],
                            score: submission['images']['person']['score'],
                            manualScore: submission['images']['person']
                                ['manualScore'],
                            icon: Icons.person,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ),
                ],
                buildStyledExpansionTile(
                  title: 'House Answers',
                  icon: Icons.house_rounded,
                  answers: submission['houseAns'],
                ),
                buildStyledExpansionTile(
                  title: 'Person Answers',
                  icon: Icons.person_rounded,
                  answers: submission['personAns'],
                ),
                buildStyledExpansionTile(
                  title: 'Tree Answers',
                  icon: Icons.park_rounded,
                  answers: submission['treeAns'],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.childsName}'s Submissions"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions found"))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) => buildSubmissionCard(index),
                ),
    );
  }
}

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullscreenImageViewer({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              loadingBuilder: (context, event) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }
}
