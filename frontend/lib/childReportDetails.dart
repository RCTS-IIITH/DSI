import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:mindseye/fullscreen_image_viewer.dart'; // Ensure this path is correct
import 'dart:math'; // For staggered delays

// --- Fade In Animation (if not adequately provided in styles.dart) ---
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final Duration duration;
  final double startOpacity;

  const FadeInAnimation({
    Key? key,
    required this.child,
    this.delay,
    this.duration = const Duration(milliseconds: 500),
    this.startOpacity = 0.0,
  }) : super(key: key);

  @override
  _FadeInAnimationState createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: widget.startOpacity, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

// --- Fade and Slide In Animation ---
class FadeSlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final Duration duration;
  final double slideOffset; // Vertical slide distance

  const FadeSlideInAnimation({
    Key? key,
    required this.child,
    this.delay,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = 20.0,
  }) : super(key: key);

  @override
  _FadeSlideInAnimationState createState() => _FadeSlideInAnimationState();
}

class _FadeSlideInAnimationState extends State<FadeSlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<double>(begin: widget.slideOffset, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0.0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// --- Custom Neumorphic Card Widget ---
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color; // Base color for the neumorphism effect

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Theme.of(context).scaffoldBackgroundColor;
    // Ensure baseColor is MaterialColor or Color forRGBO
    final darkColor = baseColor == Colors.white
        ? const Color(0xFFD1D1D1) // Specific dark shadow for white
        : baseColor.withOpacity(0.8); // Darker shade for other colors
    final lightColor = baseColor == Colors.white
        ? Colors.white
        : baseColor.withOpacity(1.0); // Lighter shade

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkColor.withOpacity(0.4), // Softer shadow
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: lightColor, // Light highlight
            offset: const Offset(-4, -4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect( // Ensures content respects rounded corners
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

// --- Animated Score Gauge ---
class AnimatedScoreGauge extends StatefulWidget {
  final int? score;
  final Color color;

  const AnimatedScoreGauge({Key? key, required this.score, required this.color}) : super(key: key);

  @override
  _AnimatedScoreGaugeState createState() => _AnimatedScoreGaugeState();
}

class _AnimatedScoreGaugeState extends State<AnimatedScoreGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    // Start animation after a short delay to sync with section reveal
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.vertical,
      axisAlignment: -1.0, // Start from top
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          if (widget.score != null)
            Row(
              children: [
                const Text('Overall Score: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${widget.score}/100', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          const SizedBox(height: 8),
          if (widget.score != null)
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _animation.value * (widget.score! / 100.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            ),
        ],
      ),
    );
  }
}


class ChildReport extends StatefulWidget {
  final String data; // student ID passed from ReportsDashboardScreen
  const ChildReport({required this.data, Key? key}) : super(key: key);

  @override
  _ChildReportState createState() => _ChildReportState();
}

class _ChildReportState extends State<ChildReport> {
  String reportId = '';
  String name = '';
  int? age;
  int? rollNumber;
  int? score;
  int? modelScore;
  int? manualScore;
  String? labeledBy;
  DateTime? labeledAt;
  String? imagePath;
  List<Map<String, String>> answerSections = [];
  late Future<void> futureReportData;

  @override
  void initState() {
    super.initState();
    futureReportData = getReportData();
  }

  final backendUrl = dotenv.env['BACKEND_URL']!;

  Future<void> getReportData() async {
    try {
      print('Fetching data for student ID: ${widget.data}');
      final uri = Uri.parse(
          '$backendUrl/api/reports/get-report-data-clinic/${widget.data}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data fetched: $data');
        setState(() {
          reportId = data['_id'] ?? 'N/A';
          name = data['childsName'] ?? 'N/A';
          age = data['age'] is num ? (data['age'] as num).toInt() : null;
          rollNumber = data['rollNumber'] is num
              ? (data['rollNumber'] as num).toInt()
              : null;
          if (data['score'] is num) {
            modelScore = (data['score'] as num).toInt();
          }
          if (data['manualScore'] is num) {
            manualScore = (data['manualScore'] as num).toInt();
          }
          labeledBy = data['labeledBy'];
          labeledAt = data['labeledAt'] != null
              ? DateTime.parse(data['labeledAt'])
              : null;
          imagePath = data['imagePath'];
          print('Fetched imagePath: $imagePath');
          final houseAns = data['houseAns'] as Map<String, dynamic>? ?? {};
          final personAns = data['personAns'] as Map<String, dynamic>? ?? {};
          final treeAns = data['treeAns'] as Map<String, dynamic>? ?? {};
          answerSections = [
            ..._mapToAnswerList(houseAns, sectionTitle: 'House'),
            ..._mapToAnswerList(personAns, sectionTitle: 'Person'),
            ..._mapToAnswerList(treeAns, sectionTitle: 'Tree'),
          ];
        });
      } else {
        throw Exception('Failed to load report data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading report data: $e');
      throw e;
    }
  }

  List<Map<String, String>> _mapToAnswerList(
    Map<String, dynamic> ansMap, {
    String sectionTitle = '',
  }) {
    return ansMap.entries.map((entry) {
      final question = entry.key;
      final answer = entry.value.toString();
      return {
        'question': '$sectionTitle: $question',
        'answer': answer,
      };
    }).toList();
  }
  

  Widget _buildScoreSection() {
    final displayScore = manualScore ?? modelScore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scores',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[800])),
        AnimatedScoreGauge(score: displayScore, color: Colors.green),
        const SizedBox(height: 12),
        if (manualScore != null) _buildInfoRow("Manual Score", "$manualScore"),
        if (labeledBy != null || labeledAt != null) ...[
          _buildInfoRow("Labeled By", labeledBy ?? 'N/A'),
          if (labeledAt != null)
            _buildInfoRow(
                "Labeled At", DateFormat('MMM d, y').format(labeledAt!)),
        ],
        if (modelScore != null && manualScore == null)
          _buildInfoRow("Model Score Only", "$modelScore/100"),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Better alignment for multi-line values
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // --- Helper Method for Expandable Answer Sections ---
  Widget _buildAnswerExpansionTile(
      String title, List<Map<String, String>> answers) {
    // Determine icon and color based on title
    IconData icon = Icons.help_outline;
    Color iconColor = Colors.blue;
    if (title.toLowerCase() == 'house') {
      icon = Icons.house_outlined;
      iconColor = Colors.brown;
    } else if (title.toLowerCase() == 'person') {
      icon = Icons.accessibility_new_outlined;
      iconColor = Colors.blue;
    } else if (title.toLowerCase() == 'tree') {
      icon = Icons.eco_outlined;
      iconColor = Colors.green;
    }

    return Card( // Use standard Card for expansion tile background
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme( // Customize ExpansionTile appearance
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Remove default divider
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: iconColor),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          // Use ListView.separated for answers within the tile
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Important!
              itemCount: answers.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final qa = answers[index];
                 // Calculate delay for staggered animation within the list
                 final delay = Duration(milliseconds: min(600, 100 + (index * 30)));
                return FadeSlideInAnimation( // Animate items inside the tile
                  delay: delay,
                  slideOffset: 15.0, // Smaller slide for items
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${qa['question'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${qa['answer'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  // --- End of Helper Method ---


  @override
  Widget build(BuildContext context) {
    // Get a base color for neumorphism that matches the scaffold background
    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        // --- Enhanced AppBar Styling ---
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlue], // Subtle gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4.0, // Add a soft shadow
        backgroundColor: Colors.transparent, // Make transparent to show gradient
        foregroundColor: Colors.white, // White icons/text for contrast
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Child Report", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjusted padding
          child: FutureBuilder(
            future: futureReportData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Loading report...", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text("Error fetching data", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            futureReportData = getReportData();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Try Again"),
                      ),
                    ],
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideInAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          "Report ID: $reportId",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall // Larger, bolder title
                              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Neumorphic Cards with Staggered Animations ---
                      FadeSlideInAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: NeumorphicCard(
                          color: scaffoldBgColor, // Use scaffold background for consistency
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Child Information", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                              const SizedBox(height: 12),
                              _buildInfoRow("Name", name),
                              _buildInfoRow("Age", age?.toString() ?? "N/A"),
                              _buildInfoRow("Roll Number", rollNumber?.toString() ?? "N/A"),
                            ],
                          ),
                        ),
                      ),

                      FadeSlideInAnimation(
                        delay: const Duration(milliseconds: 350),
                        child: NeumorphicCard(
                          color: scaffoldBgColor,
                          child: _buildScoreSection(),
                        ),
                      ),

                      // --- Image Section ---
                      if (imagePath != null && imagePath!.isNotEmpty)
                        FadeSlideInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder( // Custom transition for image
                                    pageBuilder: (context, animation, secondaryAnimation) => FullscreenImageViewer(
                                          imageUrl: 'http://localhost:3000/$imagePath', // Safer string concatenation
                                          heroTag: imagePath!,
                                        ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      // Fade transition
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: imagePath!,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0), // Rounded corners
                                  child: Image.network(
                                    'http://localhost:3000/$imagePath',
                                    height: 220, // Slightly larger
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          height: 220,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(16.0),
                                          ),
                                          child: const Center(child: Text('Image not found', style: TextStyle(color: Colors.grey))),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // --- NEW: Expandable Answers Section Grouped by Type ---
                      if (answerSections.isNotEmpty)
                        FadeSlideInAnimation(
                          delay: const Duration(milliseconds: 650),
                          child: NeumorphicCard(
                            color: scaffoldBgColor,
                            padding: EdgeInsets.zero, // Padding handled inside
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0), // Padding for the title
                                  child: Text(
                                    "Detailed Answers:",
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[800],
                                        ),
                                  ),
                                ),
                                // Group answers by section title (House, Person, Tree)
                                ...() {
                                  final groupedAnswers = <String, List<Map<String, String>>>{};
                                  for (var qa in answerSections) {
                                    // Extract the section title (e.g., "House") from the formatted question
                                    final fullQuestion = qa['question'] ?? '';
                                    final colonIndex = fullQuestion.indexOf(':');
                                    final sectionTitle = colonIndex != -1
                                        ? fullQuestion.substring(0, colonIndex).trim()
                                        : 'Other';

                                    if (!groupedAnswers.containsKey(sectionTitle)) {
                                      groupedAnswers[sectionTitle] = [];
                                    }
                                    // Add only the specific question/answer part
                                    final specificQuestion = colonIndex != -1
                                        ? fullQuestion.substring(colonIndex + 1).trim()
                                        : fullQuestion;
                                    groupedAnswers[sectionTitle]!
                                        .add({'question': specificQuestion, 'answer': qa['answer']!});
                                  }

                                  // Create an ExpansionTile for each group
                                  return groupedAnswers.entries.map((entry) {
                                    final sectionTitle = entry.key;
                                    final answers = entry.value;
                                    return _buildAnswerExpansionTile(
                                        sectionTitle, answers); // Helper widget
                                  }).toList();
                                }(),
                              ],
                            ),
                          ),
                        )
                      else
                        FadeSlideInAnimation(
                          delay: const Duration(milliseconds: 650),
                          child: Center(
                            child: Text("No answers available.", style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}