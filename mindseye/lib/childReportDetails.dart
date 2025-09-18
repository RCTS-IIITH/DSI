import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/fullscreen_image_viewer.dart';
import 'package:mindseye/labelDataScreen.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'dart:convert';
import 'package:percent_indicator/circular_percent_indicator.dart';

// 🎨 Reuse App-Wide Design Tokens
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

// 📐 Reuse Spacing Tokens
const kSpacingSmall = 8.0;
const kSpacingMedium = 16.0;
const kSpacingLarge = 24.0;

// ✍️ Reuse Typography Styles
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

// 🧩 Reuse Profile Item Model
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

class ChildReport extends StatefulWidget {
  final String data; // student ID
  final String? reportId;

  const ChildReport({
    required this.data,
    super.key,
    this.reportId,
  });

  @override
  _ChildReportState createState() => _ChildReportState();
}

class _ChildReportState extends State<ChildReport>
    with SingleTickerProviderStateMixin {
  Future<Map<String, dynamic>> futureReport = Future.value({});
  TabController? _tabController;
  String? userRole;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    futureReport = getReportData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _tabController = TabController(length: 4, vsync: this);
        });
      }
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUserRole() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      setState(() {
        userRole = userDetails?['role']?.toString();
      });
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  void _onScroll() {
    setState(() {}); // Trigger rebuild to show/hide back-to-top button
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getReportData() async {
    final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
    final uri = Uri.parse(
        '$backendUrl/api/reports/get-report-data-clinic/${widget.data}');

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

  // ✅ Reuse Section Card Builder
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

  // ✅ Reuse Profile Section Builder
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

  // ✅ Reuse Score Gauge
  Widget buildScoreGauge(double? percentage, {String title = "Overall Score"}) {
    if (percentage == null || percentage <= 0) {
      return SizedBox.shrink();
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

  // ✅ Reuse Score Chip
  Widget buildScoreChip(
      String label, dynamic score, IconData icon, Color color) {
    final displayScore = parseScore(score);
    if (displayScore <= 0) {
      return SizedBox.shrink();
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

  // ✅ Reuse Section Header
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

  // ✅ Days Ago Helper
  String _formatDaysAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) return "Today";
      if (difference.inDays == 1) return "Yesterday";
      return "${difference.inDays} days ago";
    } catch (e) {
      return '';
    }
  }

  // ✅ Skeleton Image Loader
  Widget _buildSkeletonImage() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Loading image...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  // ✅ Section Tab with Fixed Header
  Widget buildSectionTab({
    required String title,
    required IconData icon,
    required Color color,
    required Map<String, dynamic>? image,
    required Map<String, dynamic> answers,
    required dynamic score,
    required dynamic manualScore,
    required String? submittedAt,
  }) {
    final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";

    String normalizePath(String? path) {
      if (path == null) return '';
      return path.startsWith('/') ? path.substring(1) : path;
    }

    final imagePath = normalizePath(image?['path']);
    final fullImageUrl = imagePath.isNotEmpty ? '$backendUrl/$imagePath' : null;
    final daysAgo = _formatDaysAgo(submittedAt);

    return Column(
      children: [
        // ✅ FIXED HEADER (not scrollable)
        Container(
          padding: EdgeInsets.all(kSpacingMedium),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: kSpacingSmall),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              if (manualScore != null && manualScore > 0) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Manual",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
              if (manualScore != null && manualScore > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${parseScore(manualScore)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (score != null && score > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${parseScore(score)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (daysAgo.isNotEmpty) ...[
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // ✅ SCROLLABLE CONTENT
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureReport = getReportData();
              });
              await futureReport;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.all(kSpacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: kSpacingMedium),
                    // 🖼️ Drawing
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
                                    heroTag: imagePath,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: imagePath,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: FutureBuilder(
                                  future: _precacheImage(fullImageUrl, context),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return _buildSkeletonImage();
                                    } else if (snapshot.hasError) {
                                      return Container(
                                        height: 250,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error_outline,
                                                  color: Colors.grey),
                                              SizedBox(height: 8),
                                              Text('Failed to load',
                                                  style: TextStyle(
                                                      color: Colors.grey[600])),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Image.network(
                                        fullImageUrl,
                                        height: 250,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          height: 250,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error_outline,
                                                    color: Colors.grey),
                                                SizedBox(height: 8),
                                                Text('Image not found',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[600])),
                                              ],
                                            ),
                                          ),
                                        ),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return _buildSkeletonImage();
                                        },
                                      );
                                    }
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
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "${entry.key}:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _precacheImage(String imageUrl, BuildContext context) async {
    final imageProvider = NetworkImage(imageUrl);
    await precacheImage(imageProvider, context);
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
          "Child Report",
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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 20,
            vertical: 0,
          ),
          child: Stack(
            // 👈 Wrap everything in Stack
            children: [
              // 👇 Main scrollable content
              FutureBuilder<Map<String, dynamic>>(
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
                  final submitterRole =
                      submittedBy['role']?.toUpperCase() ?? 'N/A';
                  final submitterPhone = submittedBy['phone'] ?? 'N/A';
                  final submittedAt = reportData['submittedAt']?.toString();

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
                    calculatedAIScore =
                        count > 0 ? (total / count).round() : null;
                  }

                  final finalManualScore = calculatedManualScore;
                  final finalAIScore = calculatedAIScore;
                  final displayScore = (finalManualScore ?? finalAIScore) ?? 0;

                  // ✅ Check if needs labeling
                  final hasAnyManualScore = houseManualScore != null ||
                      treeManualScore != null ||
                      personManualScore != null;

                  if (_tabController == null) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    children: [
                      // ✅ "Needs Labeling" Banner
                      if ((userRole ?? '').toLowerCase() == 'professional' &&
                          !hasAnyManualScore)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    color: Colors.orange[900]),
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
                                                          reportId: reportData[
                                                                  '_id'] ??
                                                              ''),
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.edit_document,
                                                size: 16, color: Colors.white),
                                            label: Text("Label Now",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.orange[800],
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
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
                                            color: Colors.orange[800],
                                            size: 22),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "Not labelled. Please review and assign scores.",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.orange[900]),
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
                                                        reportId:
                                                            reportData['_id'] ??
                                                                ''),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.edit_document,
                                              size: 16, color: Colors.white),
                                          label: Text("Label Now",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange[800],
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
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
                        child: DefaultTabController(
                          length: 4,
                          child: Column(
                            children: [
                              TabBar(
                                controller: _tabController,
                                indicatorColor: Colors.white,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white70,
                                tabs: [
                                  Tab(
                                      text: "Overview",
                                      icon: Icon(Icons.dashboard)),
                                  Tab(text: "House", icon: Icon(Icons.home)),
                                  Tab(
                                      text: "Tree",
                                      icon: Icon(Icons.account_tree)),
                                  Tab(text: "Person", icon: Icon(Icons.person)),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController!,
                                  children: [
                                    // TAB 1: OVERVIEW
                                    SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Padding(
                                        padding: EdgeInsets.all(kSpacingMedium),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 🆔 Report ID
                                            Text(
                                              'Report ID: ${reportData['_id'] ?? 'N/A'}',
                                              style:
                                                  AppTextStyles.headlineSmall(
                                                          context)
                                                      .copyWith(fontSize: 18),
                                            ),
                                            // 👶 Child Info
                                            sectionHeader("Child Information",
                                                color: Colors.blue),
                                            buildProfileSection(
                                                "Child Details", [
                                              ProfileItem(
                                                  label: "Name",
                                                  value:
                                                      reportData['childsName']),
                                              ProfileItem(
                                                  label: "Age",
                                                  value: reportData['age']
                                                      ?.toString()),
                                              ProfileItem(
                                                  label: "Roll Number",
                                                  value:
                                                      reportData['rollNumber']),
                                            ]),
                                            // 📊 Overall Score
                                            if (displayScore != null &&
                                                displayScore > 0) ...[
                                              sectionHeader(
                                                  "Overall Assessment",
                                                  color: AppColors.primary),
                                              buildScoreGauge(
                                                  displayScore.toDouble()),
                                            ],
                                            // 📊 Section Scores
                                            if (houseManualScore != null ||
                                                houseScore != null ||
                                                treeManualScore != null ||
                                                treeScore != null ||
                                                personManualScore != null ||
                                                personScore != null) ...[
                                              sectionHeader("Section Scores",
                                                  color: Colors.green),
                                              if (houseManualScore != null ||
                                                  houseScore != null)
                                                buildScoreChip(
                                                    "House Drawing",
                                                    houseManualScore ??
                                                        houseScore,
                                                    Icons.home,
                                                    Colors.brown),
                                              if (treeManualScore != null ||
                                                  treeScore != null)
                                                buildScoreChip(
                                                    "Tree Drawing",
                                                    treeManualScore ??
                                                        treeScore,
                                                    Icons.account_tree,
                                                    Colors.green),
                                              if (personManualScore != null ||
                                                  personScore != null)
                                                buildScoreChip(
                                                    "Person Drawing",
                                                    personManualScore ??
                                                        personScore,
                                                    Icons.person,
                                                    Colors.orange),
                                            ],
                                            // 👤 Submitted By
                                            if (reportData.containsKey(
                                                'submittedBy')) ...[
                                              sectionHeader("Submitted By",
                                                  color: Colors.purple),
                                              buildProfileSection(
                                                  "Submitter Info", [
                                                ProfileItem(
                                                  label: "Role",
                                                  value: submitterRole,
                                                  icon: Icons.badge,
                                                  iconColor: getRoleColor(
                                                      submitterRole
                                                          .toLowerCase()),
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
                                      submittedAt: submittedAt,
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
                                      submittedAt: submittedAt,
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
                                      submittedAt: submittedAt,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              // 👇 Back to Top Button — Positioned absolutely
              if (_scrollController.hasClients &&
                  _scrollController.position.pixels > 200)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30, right: 20),
                    child: FloatingActionButton(
                      onPressed: () {
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      },
                      child: Icon(Icons.arrow_upward),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
}
