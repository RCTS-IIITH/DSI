import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/fullscreen_image_viewer.dart';
import 'dart:convert';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'labelDataScreen.dart';

// 🎨 App-Wide Design Tokens
class AppColors {
  static const Color primary = Color(0xFF4361EE);
  static const Color secondary = Color(0xFF3A0CA3);
  static const Color success = Color(0xFF4CC9F0);
  static const Color warning = Color(0xFFF72585);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF212529);
  static const Color divider = Color(0xFFE9ECEF);
}

// 📐 Spacing Tokens
const kSpacingSmall = 8.0;
const kSpacingMedium = 16.0;
const kSpacingLarge = 24.0;
const kSpacingXLarge = 32.0;

// ✍️ Typography Styles — UPGRADED
class AppTextStyles {
  static TextStyle headlineSmall(BuildContext context) =>
      Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppColors.onSurface,
          );

  static TextStyle titleLarge(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.onSurface,
          );

  static TextStyle bodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 15,
            height: 1.4,
            color: AppColors.onSurface.withOpacity(0.8),
          );

  static TextStyle labelSmall(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: 13,
            color: AppColors.onSurface.withOpacity(0.6),
          );
}

// 🧩 Profile Item Model
class ProfileItem {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? iconColor;

  ProfileItem({
    required this.label,
    this.value,
    this.icon,
    this.iconColor,
  });
}

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;
  final String userRole;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.userRole,
  });

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> futureReport;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    futureReport = fetchReport(widget.reportId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _tabController = TabController(length: 4, vsync: this);
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchReport(String reportId) async {
    final backendUrl = "http://localhost:3001";
    final uri =
        Uri.parse('$backendUrl/api/reports/get-report-data-clinic/$reportId');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load report (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching report: $e');
    }
  }

  Color getRoleColor(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'parent':
        return Colors.green[700]!;
      case 'teacher':
        return Colors.orange[700]!;
      case 'professional':
        return Colors.blue[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color getColorByScore(double score) {
    if (score >= 80) return Colors.green[700]!;
    if (score >= 50) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  // ✅ UPGRADED: Softer corners, subtle border
  Widget buildSectionCard(Widget child, {double padding = 16}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      margin: EdgeInsets.symmetric(vertical: kSpacingSmall),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }

  Widget buildProfileSection(String title, List<ProfileItem> items) {
    return buildSectionCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge(context).copyWith(
              fontSize: 18,
            ),
          ),
          Divider(color: AppColors.divider, thickness: 1, height: 28),
          ...items.map((item) => buildProfileRow(item)).toList(),
        ],
      ),
    );
  }

  Widget buildProfileRow(ProfileItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (item.icon != null)
            Icon(
              item.icon,
              color: item.iconColor ?? AppColors.onSurface.withOpacity(0.6),
              size: 18,
            ),
          if (item.icon != null) SizedBox(width: 8),
          Flexible(
            child: Text(
              item.label,
              style: AppTextStyles.labelSmall(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 16),
          Flexible(
            flex: 2,
            child: Text(
              item.value ?? 'N/A',
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: Returns shrink if no valid score
  Widget buildScoreGauge(double? percentage, {String title = "Overall Score"}) {
    if (percentage == null || percentage <= 0) {
      return SizedBox.shrink(); // ✅ Hide completely
    }

    final clamped = percentage.clamp(0.0, 100.0);
    final color = getColorByScore(clamped);
    return Column(
      children: [
        Text(title, style: AppTextStyles.bodyMedium(context)),
        SizedBox(height: 8),
        CircularPercentIndicator(
          radius: 60.0,
          lineWidth: 8.0,
          percent: clamped / 100,
          center: Text(
            "${clamped.round()}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: color,
            ),
          ),
          progressColor: color,
          backgroundColor: AppColors.divider,
        ),
      ],
    );
  }

  // ✅ UPDATED: Returns shrink if no valid score
  Widget buildScoreChip(
      String label, dynamic score, IconData icon, Color color) {
    final displayScore = parseScore(score);
    if (displayScore <= 0) {
      return SizedBox.shrink(); // ✅ Hide completely
    }

    final chipColor = getColorByScore(displayScore.toDouble());
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMedium(context)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: chipColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: chipColor, width: 1.5),
            ),
            child: Text(
              "$displayScore%",
              style: TextStyle(
                color: chipColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Section Header with Accent Bar
  Widget sectionHeader(String title, {Color? color}) {
    return Container(
      margin: EdgeInsets.only(top: kSpacingLarge, bottom: kSpacingMedium),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color ?? AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 Per-Section Tab Builder
  Widget buildSectionTab({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, dynamic>? image,
    required Map<String, dynamic> answers,
    required dynamic score,
    required dynamic manualScore,
  }) {
    final displayScore = manualScore ?? score;
    final fullImageUrl = image?['path'] != null
        ? 'http://localhost:3001/${image?['path']}'
        : null;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(kSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ Section Header with Score (Only if > 0)
            Container(
              padding: EdgeInsets.all(kSpacingMedium),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  SizedBox(width: kSpacingSmall),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Spacer(),
                  // ✅ Only show score badge if score > 0
                  if (displayScore != null && displayScore > 0)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${parseScore(displayScore)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: kSpacingLarge),

            // 🖼️ Drawing (if exists)
            if (fullImageUrl != null)
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullscreenImageViewer(
                            imageUrl: fullImageUrl,
                            heroTag: image!['path'],
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: image!['path'],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          fullImageUrl,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 250,
                            color: Colors.grey[200],
                            child: Center(
                                child: Icon(Icons.error_outline,
                                    color: Colors.grey)),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: kSpacingMedium),
                ],
              ),

            // 📋 Q/A Section
            sectionHeader("Questions & Answers", color: color),
            buildSectionCard(
              ExpansionTile(
                initiallyExpanded: true,
                title: Text("Tap to expand all answers",
                    style: AppTextStyles.bodyMedium(context)),
                children: answers.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text("${entry.key}:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 5,
                          child: Text(entry.value.toString()),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              padding: 0,
            ),

            SizedBox(height: kSpacingLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Report Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.userRole.toLowerCase() == 'professional')
            IconButton(
              icon: Icon(Icons.edit_document, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LabelDataScreen(
                      reportId: widget.reportId,
                    ),
                  ),
                );
              },
              tooltip: "Proceed to Manual Scoring",
            ),
        ],
        bottom: _tabController != null
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: "Overview", icon: Icon(Icons.dashboard)),
                  Tab(text: "House", icon: Icon(Icons.home)),
                  Tab(text: "Tree", icon: Icon(Icons.account_tree)),
                  Tab(text: "Person", icon: Icon(Icons.person)),
                ],
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
            vertical: 0,
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: futureReport,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No report data available.'));
              }

              final reportData = snapshot.data!;

              final houseAns = reportData['houseAns'] ?? {};
              final personAns = reportData['personAns'] ?? {};
              final treeAns = reportData['treeAns'] ?? {};
              final submittedBy = reportData['submittedBy'] ?? {};
              final submitterRole = submittedBy['role']?.toUpperCase() ?? 'N/A';
              final submitterPhone = submittedBy['phone'] ?? 'N/A';

              final images = reportData['images'] ?? {};
              final houseImage = images['house'];
              final treeImage = images['tree'];
              final personImage = images['person'];

              // Scoring logic
              final houseScore = houseImage?['score'];
              final treeScore = treeImage?['score'];
              final personScore = personImage?['score'];
              final houseManualScore = houseImage?['manualScore'];
              final treeManualScore = treeImage?['manualScore'];
              final personManualScore = personImage?['manualScore'];

              int? calculatedManualScore;
              int? calculatedAIScore;

              if (houseManualScore != null ||
                  treeManualScore != null ||
                  personManualScore != null) {
                int total = 0;
                int count = 0;
                if (houseManualScore != null) {
                  total += (houseManualScore as num).toInt();
                  count++;
                }
                if (treeManualScore != null) {
                  total += (treeManualScore as num).toInt();
                  count++;
                }
                if (personManualScore != null) {
                  total += (personManualScore as num).toInt();
                  count++;
                }
                calculatedManualScore =
                    count > 0 ? (total / count).round() : null;
              }

              if (houseScore != null ||
                  treeScore != null ||
                  personScore != null) {
                int total = 0;
                int count = 0;
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
                calculatedAIScore = count > 0 ? (total / count).round() : null;
              }

              final finalManualScore =
                  calculatedManualScore ?? reportData['manualScore'];
              final finalAIScore = calculatedAIScore ?? reportData['score'];
              final displayScore = (finalManualScore ?? finalAIScore) ?? 0;

              if (_tabController == null) {
                return Center(child: CircularProgressIndicator());
              }

              // ✅ Compute if any section has valid score
              final hasAnySectionScore =
                  (houseManualScore ?? houseScore) != null &&
                          (houseManualScore ?? houseScore) > 0 ||
                      (treeManualScore ?? treeScore) != null &&
                          (treeManualScore ?? treeScore) > 0 ||
                      (personManualScore ?? personScore) != null &&
                          (personManualScore ?? personScore) > 0;

              return Column(
                children: [
                  // ✅ PROMINENT "NEEDS LABELING" BANNER (Only for professionals when no score)
                  if (widget.userRole.toLowerCase() == 'professional' &&
                      (displayScore == null || displayScore <= 0))
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 400;

                        return Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning_amber,
                                            color: Colors.orange[800],
                                            size: 22),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Not labelled. Please review and assign scores.",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.orange[900],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LabelDataScreen(
                                                reportId: widget.reportId,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.edit_document,
                                            size: 16, color: Colors.white),
                                        label: Text("Label Now",
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange[800],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Icon(Icons.warning_amber,
                                        color: Colors.orange[800], size: 22),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Not labelled. Please review and assign scores.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.orange[900],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LabelDataScreen(
                                              reportId: widget.reportId,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.edit_document,
                                          size: 16, color: Colors.white),
                                      label: Text("Label Now",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[800],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),

                  // 📋 Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController!,
                      children: [
                        // TAB 1: OVERVIEW
                        SingleChildScrollView(
                          padding: EdgeInsets.all(kSpacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🆔 Report ID
                              Text(
                                'Report ID: ${reportData['_id'] ?? 'N/A'}',
                                style: AppTextStyles.headlineSmall(context)
                                    .copyWith(
                                  fontSize: 18,
                                ),
                              ),

                              // 👶 Child Info
                              sectionHeader("Child Information",
                                  color: Colors.blue),
                              buildProfileSection("Child Details", [
                                ProfileItem(
                                    label: "Name",
                                    value: reportData['childsName']),
                                ProfileItem(
                                    label: "Age",
                                    value: reportData['age']?.toString()),
                                ProfileItem(
                                    label: "Roll Number",
                                    value: reportData['rollNumber']),
                              ]),

                              // 📊 Overall Score (Only if > 0)
                              if (displayScore != null && displayScore > 0) ...[
                                sectionHeader("Overall Assessment",
                                    color: AppColors.primary),
                                buildScoreGauge(displayScore.toDouble()),
                              ],

                              // 📊 Section Scores (Only if any section has score)
                              if (hasAnySectionScore) ...[
                                sectionHeader("Section Scores",
                                    color: Colors.green),
                                if (houseManualScore != null ||
                                    houseScore != null)
                                  buildScoreChip(
                                    "House Drawing",
                                    houseManualScore ?? houseScore,
                                    Icons.home,
                                    Colors.brown,
                                  ),
                                if (treeManualScore != null ||
                                    treeScore != null)
                                  buildScoreChip(
                                    "Tree Drawing",
                                    treeManualScore ?? treeScore,
                                    Icons.account_tree,
                                    Colors.green,
                                  ),
                                if (personManualScore != null ||
                                    personScore != null)
                                  buildScoreChip(
                                    "Person Drawing",
                                    personManualScore ?? personScore,
                                    Icons.person,
                                    Colors.orange,
                                  ),
                              ],

                              // 👤 Submitted By
                              if (reportData.containsKey('submittedBy')) ...[
                                sectionHeader("Submitted By",
                                    color: Colors.purple),
                                buildProfileSection("Submitter Info", [
                                  ProfileItem(
                                    label: "Role",
                                    value: submitterRole,
                                    icon: Icons.badge,
                                    iconColor: getRoleColor(
                                        submitterRole.toLowerCase()),
                                  ),
                                  ProfileItem(
                                    label: "Phone",
                                    value: submitterPhone,
                                    icon: Icons.phone,
                                    iconColor: Colors.green[700],
                                  ),
                                ]),
                              ],
                            ],
                          ),
                        ),

                        // TAB 2: HOUSE
                        buildSectionTab(
                          title: "House Drawing",
                          icon: Icons.home,
                          color: Colors.brown,
                          image: houseImage,
                          answers: houseAns,
                          score: houseScore,
                          manualScore: houseManualScore,
                        ),

                        // TAB 3: TREE
                        buildSectionTab(
                          title: "Tree Drawing",
                          icon: Icons.account_tree,
                          color: Colors.green,
                          image: treeImage,
                          answers: treeAns,
                          score: treeScore,
                          manualScore: treeManualScore,
                        ),

                        // TAB 4: PERSON
                        buildSectionTab(
                          title: "Person Drawing",
                          icon: Icons.person,
                          color: Colors.orange,
                          image: personImage,
                          answers: personAns,
                          score: personScore,
                          manualScore: personManualScore,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

int parseScore(dynamic score) {
  if (score == null) return 0;
  if (score is num) return score.round();
  if (score is String) {
    final parsed = double.tryParse(score);
    return parsed != null ? parsed.round() : 0;
  }
  return 0;
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mindseye/fullscreen_image_viewer.dart';
// import 'dart:convert';
// import 'package:percent_indicator/circular_percent_indicator.dart';

// import 'labelDataScreen.dart';

// // 🎨 App-Wide Design Tokens
// class AppColors {
//   static const Color primary = Color(0xFF4361EE);
//   static const Color secondary = Color(0xFF3A0CA3);
//   static const Color success = Color(0xFF4CC9F0);
//   static const Color warning = Color(0xFFF72585);
//   static const Color background = Color(0xFFF8F9FA);
//   static const Color surface = Colors.white;
//   static const Color onSurface = Color(0xFF212529);
//   static const Color divider = Color(0xFFE9ECEF);
// }

// // 📐 Spacing Tokens
// const kSpacingSmall = 8.0;
// const kSpacingMedium = 16.0;
// const kSpacingLarge = 24.0;
// const kSpacingXLarge = 32.0;

// // ✍️ Typography Styles
// class AppTextStyles {
//   static TextStyle headlineSmall(BuildContext context) =>
//       Theme.of(context).textTheme.headlineSmall!.copyWith(
//             fontWeight: FontWeight.bold,
//             color: AppColors.onSurface,
//           );

//   static TextStyle titleLarge(BuildContext context) =>
//       Theme.of(context).textTheme.titleLarge!.copyWith(
//             fontWeight: FontWeight.w600,
//             color: AppColors.onSurface,
//           );

//   static TextStyle bodyMedium(BuildContext context) =>
//       Theme.of(context).textTheme.bodyMedium!.copyWith(
//             color: AppColors.onSurface.withOpacity(0.8),
//           );

//   static TextStyle labelSmall(BuildContext context) =>
//       Theme.of(context).textTheme.labelSmall!.copyWith(
//             color: AppColors.onSurface.withOpacity(0.6),
//           );
// }

// // 🧩 Profile Item Model
// class ProfileItem {
//   final String label;
//   final String? value;
//   final IconData? icon;
//   final Color? iconColor;

//   ProfileItem({
//     required this.label,
//     this.value,
//     this.icon,
//     this.iconColor,
//   });
// }

// class ReportDetailsScreen extends StatefulWidget {
//   final String reportId;
//   final String userRole;

//   const ReportDetailsScreen({
//     super.key,
//     required this.reportId,
//     required this.userRole,
//   });

//   @override
//   _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
// }

// class _ReportDetailsScreenState extends State<ReportDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late Future<Map<String, dynamic>> futureReport;
//   TabController? _tabController;

//   @override
//   void initState() {
//     super.initState();
//     futureReport = fetchReport(widget.reportId);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         setState(() {
//           _tabController =
//               TabController(length: 4, vsync: this); // ✅ Now 4 tabs
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }

//   Future<Map<String, dynamic>> fetchReport(String reportId) async {
//     final backendUrl = "http://localhost:3001";
//     final uri =
//         Uri.parse('$backendUrl/api/reports/get-report-data-clinic/$reportId');

//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception(
//             'Failed to load report (Status: ${response.statusCode})');
//       }
//     } catch (e) {
//       throw Exception('Error fetching report: $e');
//     }
//   }

//   Color getRoleColor(String? role) {
//     switch ((role ?? '').toLowerCase()) {
//       case 'parent':
//         return Colors.green[700]!;
//       case 'teacher':
//         return Colors.orange[700]!;
//       case 'professional':
//         return Colors.blue[700]!;
//       default:
//         return Colors.grey[600]!;
//     }
//   }

//   Color getColorByScore(double score) {
//     if (score >= 80) return Colors.green[700]!;
//     if (score >= 50) return Colors.orange[700]!;
//     return Colors.red[700]!;
//   }

//   Widget buildSectionCard(Widget child, {double padding = 16}) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       margin: EdgeInsets.symmetric(vertical: kSpacingSmall),
//       child: Padding(
//         padding: EdgeInsets.all(padding),
//         child: child,
//       ),
//     );
//   }

//   Widget buildProfileSection(String title, List<ProfileItem> items) {
//     return buildSectionCard(
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.titleLarge(context).copyWith(
//               fontSize: 18,
//             ),
//           ),
//           Divider(color: AppColors.divider, thickness: 1, height: 28),
//           ...items.map((item) => buildProfileRow(item)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget buildProfileRow(ProfileItem item) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           if (item.icon != null)
//             Icon(
//               item.icon,
//               color: item.iconColor ?? AppColors.onSurface.withOpacity(0.6),
//               size: 18,
//             ),
//           if (item.icon != null) SizedBox(width: 8),
//           Flexible(
//             child: Text(
//               item.label,
//               style: AppTextStyles.labelSmall(context),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           SizedBox(width: 16),
//           Flexible(
//             flex: 2,
//             child: Text(
//               item.value ?? 'N/A',
//               style: AppTextStyles.bodyMedium(context).copyWith(
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.end,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildScoreGauge(double percentage, {String title = "Overall Score"}) {
//     final clamped = percentage.clamp(0.0, 100.0);
//     final color = getColorByScore(clamped);
//     return Column(
//       children: [
//         Text(title, style: AppTextStyles.bodyMedium(context)),
//         SizedBox(height: 8),
//         CircularPercentIndicator(
//           radius: 60.0,
//           lineWidth: 8.0,
//           percent: clamped / 100,
//           center: Text(
//             "${clamped.round()}%",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//               color: color,
//             ),
//           ),
//           progressColor: color,
//           backgroundColor: AppColors.divider,
//         ),
//       ],
//     );
//   }

//   Widget buildScoreChip(
//       String label, dynamic score, IconData icon, Color color) {
//     final displayScore = parseScore(score);
//     final chipColor = getColorByScore(displayScore.toDouble());
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 18),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(label, style: AppTextStyles.bodyMedium(context)),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: chipColor.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: chipColor, width: 1.5),
//             ),
//             child: Text(
//               "$displayScore%",
//               style: TextStyle(
//                 color: chipColor,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🎯 Per-Section Tab Builder (House/Tree/Person)
//   Widget buildSectionTab({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required Map<String, dynamic>? image,
//     required Map<String, dynamic> answers,
//     required dynamic score,
//     required dynamic manualScore,
//   }) {
//     final displayScore = manualScore ?? score;
//     final fullImageUrl = image?['path'] != null
//         ? 'http://localhost:3001/${image?['path']}'
//         : null;

//     return SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.all(kSpacingMedium),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🏷️ Section Header with Score
//             Container(
//               padding: EdgeInsets.all(kSpacingMedium),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Icon(icon, color: color, size: 24),
//                   SizedBox(width: kSpacingSmall),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: color,
//                     ),
//                   ),
//                   Spacer(),
//                   if (displayScore != null)
//                     Container(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: color,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         '${parseScore(displayScore)}%',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             SizedBox(height: kSpacingLarge),

//             // 🖼️ Drawing (if exists)
//             if (fullImageUrl != null)
//               Column(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => FullscreenImageViewer(
//                             imageUrl: fullImageUrl,
//                             heroTag: image!['path'],
//                           ),
//                         ),
//                       );
//                     },
//                     child: Hero(
//                       tag: image!['path'],
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Image.network(
//                           fullImageUrl,
//                           height: 250,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                             height: 250,
//                             color: Colors.grey[200],
//                             child: Center(
//                                 child: Icon(Icons.error_outline,
//                                     color: Colors.grey)),
//                           ),
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               height: 250,
//                               color: Colors.grey[200],
//                               child: Center(child: CircularProgressIndicator()),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: kSpacingMedium),
//                 ],
//               ),

//             // 📋 Q/A Section
//             buildSectionCard(
//               ExpansionTile(
//                 initiallyExpanded: true,
//                 title: Text("📝 Questions & Answers",
//                     style: AppTextStyles.titleLarge(context)),
//                 children: answers.entries.map((entry) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: Text("${entry.key}:",
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                         ),
//                         SizedBox(width: 8),
//                         Expanded(
//                           flex: 5,
//                           child: Text(entry.value.toString()),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//               padding: 0,
//             ),

//             SizedBox(height: kSpacingLarge),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           "Report Details",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         bottom: _tabController != null
//             ? TabBar(
//                 controller: _tabController,
//                 indicatorColor: Colors.white,
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.white70,
//                 tabs: [
//                   Tab(text: "Overview", icon: Icon(Icons.dashboard)),
//                   Tab(text: "House", icon: Icon(Icons.home)),
//                   Tab(text: "Tree", icon: Icon(Icons.account_tree)),
//                   Tab(text: "Person", icon: Icon(Icons.person)),
//                 ],
//               )
//             : null,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
//             vertical: 0,
//           ),
//           child: FutureBuilder<Map<String, dynamic>>(
//             future: futureReport,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return Center(child: Text('No report data available.'));
//               }

//               final reportData = snapshot.data!;

//               // ✅ Declare all variables
//               final houseAns = reportData['houseAns'] ?? {};
//               final personAns = reportData['personAns'] ?? {};
//               final treeAns = reportData['treeAns'] ?? {};
//               final submittedBy = reportData['submittedBy'] ?? {};
//               final submitterRole = submittedBy['role']?.toUpperCase() ?? 'N/A';
//               final submitterPhone = submittedBy['phone'] ?? 'N/A';

//               // Prepare image data
//               final images = reportData['images'] ?? {};

//               final houseImage = images['house'];
//               final treeImage = images['tree'];
//               final personImage = images['person'];

//               // Scoring logic
//               final houseScore = houseImage?['score'];
//               final treeScore = treeImage?['score'];
//               final personScore = personImage?['score'];

//               final houseManualScore = houseImage?['manualScore'];
//               final treeManualScore = treeImage?['manualScore'];
//               final personManualScore = personImage?['manualScore'];

//               int? calculatedManualScore;
//               int? calculatedAIScore;

//               if (houseManualScore != null ||
//                   treeManualScore != null ||
//                   personManualScore != null) {
//                 int total = 0;
//                 int count = 0;
//                 if (houseManualScore != null) {
//                   total += (houseManualScore as num).toInt();
//                   count++;
//                 }
//                 if (treeManualScore != null) {
//                   total += (treeManualScore as num).toInt();
//                   count++;
//                 }
//                 if (personManualScore != null) {
//                   total += (personManualScore as num).toInt();
//                   count++;
//                 }
//                 calculatedManualScore =
//                     count > 0 ? (total / count).round() : null;
//               }

//               if (houseScore != null ||
//                   treeScore != null ||
//                   personScore != null) {
//                 int total = 0;
//                 int count = 0;
//                 if (houseScore != null) {
//                   total += (houseScore as num).toInt();
//                   count++;
//                 }
//                 if (treeScore != null) {
//                   total += (treeScore as num).toInt();
//                   count++;
//                 }
//                 if (personScore != null) {
//                   total += (personScore as num).toInt();
//                   count++;
//                 }
//                 calculatedAIScore = count > 0 ? (total / count).round() : null;
//               }

//               final finalManualScore =
//                   calculatedManualScore ?? reportData['manualScore'];
//               final finalAIScore = calculatedAIScore ?? reportData['score'];
//               final displayScore = (finalManualScore ?? finalAIScore) ?? 0;

//               // Wait for tab controller
//               if (_tabController == null) {
//                 return Center(child: CircularProgressIndicator());
//               }

//               return TabBarView(
//                 controller: _tabController!,
//                 children: [
//                   // TAB 1: OVERVIEW — ✅ RESTORED!
//                   SingleChildScrollView(
//                     padding: EdgeInsets.all(kSpacingMedium),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // 🆔 Report ID
//                         Text(
//                           'Report ID: ${reportData['_id'] ?? 'N/A'}',
//                           style: AppTextStyles.titleLarge(context).copyWith(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         SizedBox(height: kSpacingLarge),

//                         // 👶 Child Info
//                         buildProfileSection("Child Information", [
//                           ProfileItem(
//                               label: "Name", value: reportData['childsName']),
//                           ProfileItem(
//                               label: "Age",
//                               value: reportData['age']?.toString()),
//                           ProfileItem(
//                               label: "Roll Number",
//                               value: reportData['rollNumber']),
//                         ]),
//                         SizedBox(height: kSpacingMedium),

//                         // 📊 Overall Score
//                         buildScoreGauge(displayScore.toDouble()),

//                         SizedBox(height: kSpacingMedium),

//                         // 📊 Section Scores
//                         if (houseScore != null ||
//                             houseManualScore != null ||
//                             treeScore != null ||
//                             treeManualScore != null ||
//                             personScore != null ||
//                             personManualScore != null)
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Section Scores",
//                                 style: AppTextStyles.titleLarge(context)
//                                     .copyWith(fontSize: 18),
//                               ),
//                               SizedBox(height: kSpacingSmall),
//                               if (houseScore != null ||
//                                   houseManualScore != null)
//                                 buildScoreChip(
//                                   "House Drawing",
//                                   houseManualScore ?? houseScore,
//                                   Icons.home,
//                                   Colors.brown,
//                                 ),
//                               if (treeScore != null || treeManualScore != null)
//                                 buildScoreChip(
//                                   "Tree Drawing",
//                                   treeManualScore ?? treeScore,
//                                   Icons.account_tree,
//                                   Colors.green,
//                                 ),
//                               if (personScore != null ||
//                                   personManualScore != null)
//                                 buildScoreChip(
//                                   "Person Drawing",
//                                   personManualScore ?? personScore,
//                                   Icons.person,
//                                   Colors.orange,
//                                 ),
//                             ],
//                           ),
//                         SizedBox(height: kSpacingLarge),

//                         // 👤 Submitted By
//                         if (reportData.containsKey('submittedBy'))
//                           buildProfileSection("Submitted By", [
//                             ProfileItem(
//                               label: "Role",
//                               value: submitterRole,
//                               icon: Icons.badge,
//                               iconColor:
//                                   getRoleColor(submitterRole.toLowerCase()),
//                             ),
//                             ProfileItem(
//                               label: "Phone",
//                               value: submitterPhone,
//                               icon: Icons.phone,
//                               iconColor: Colors.green[700],
//                             ),
//                           ]),
//                       ],
//                     ),
//                   ),

//                   // TAB 2: HOUSE
//                   buildSectionTab(
//                     title: "House Drawing",
//                     icon: Icons.home,
//                     color: Colors.brown,
//                     image: houseImage,
//                     answers: houseAns,
//                     score: houseScore,
//                     manualScore: houseManualScore,
//                   ),

//                   // TAB 3: TREE
//                   buildSectionTab(
//                     title: "Tree Drawing",
//                     icon: Icons.account_tree,
//                     color: Colors.green,
//                     image: treeImage,
//                     answers: treeAns,
//                     score: treeScore,
//                     manualScore: treeManualScore,
//                   ),

//                   // TAB 4: PERSON
//                   buildSectionTab(
//                     title: "Person Drawing",
//                     icon: Icons.person,
//                     color: Colors.orange,
//                     image: personImage,
//                     answers: personAns,
//                     score: personScore,
//                     manualScore: personManualScore,
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//       // ✍️ Manual Scoring Button
//       floatingActionButton: widget.userRole.toLowerCase() == 'professional'
//           ? FloatingActionButton.extended(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => LabelDataScreen(
//                       reportId: widget.reportId,
//                     ),
//                   ),
//                 );
//               },
//               icon: Icon(Icons.edit_document),
//               label: Text("Manual Scoring"),
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//             )
//           : null,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }

// int parseScore(dynamic score) {
//   if (score == null) return 0;
//   if (score is num) return score.round();
//   if (score is String) {
//     final parsed = double.tryParse(score);
//     return parsed != null ? parsed.round() : 0;
//   }
//   return 0;
// }
