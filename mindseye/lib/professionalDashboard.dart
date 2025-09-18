import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/error_display.dart';
import 'package:mindseye/labelPreviousData.dart';
import 'package:mindseye/reportDetails.dart';
import 'package:mindseye/reportsDashboard.dart';
import 'package:mindseye/schoolScreen.dart';
import 'package:mindseye/tagImageManuaaly.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/unified_login_screen.dart';
import 'package:mindseye/utility.dart';

class ProfessionalDashboard extends StatefulWidget {
  final String data;
  const ProfessionalDashboard(String s, {super.key, required this.data});

  @override
  _ProfessionalDashboardState createState() => _ProfessionalDashboardState();
}

// ✅ Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? reportId; // Optional: link to report
  final String? childId;
  final String? schoolName;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.schoolName, // 👈
    this.reportId,
    this.childId, // 👈
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'reportId': reportId,
      'childId': childId, // 👈
      'schoolName': schoolName,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      reportId: json['reportId'],
      childId: json['childId'], // 👈
      schoolName: json['schoolName'],
      isRead: json['isRead'] ?? false,
    );
  }
}

class SchoolSubmissionInfo {
  final String schoolId;
  final String schoolName;
  final int todayCount;
  final int totalCount;

  SchoolSubmissionInfo({
    required this.schoolId,
    required this.schoolName,
    required this.todayCount,
    required this.totalCount,
  });

  factory SchoolSubmissionInfo.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['schoolId'];
    return SchoolSubmissionInfo(
      schoolId: rawId == null ? '' : rawId.toString(),
      schoolName: (json['schoolName'] ?? 'Unknown').toString(),
      todayCount: (json['todayCount'] ?? 0) is int
          ? (json['todayCount'] as int)
          : int.tryParse((json['todayCount'] ?? '0').toString()) ?? 0,
      totalCount: (json['totalCount'] ?? 0) is int
          ? (json['totalCount'] as int)
          : int.tryParse((json['totalCount'] ?? '0').toString()) ?? 0,
    );
  }
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  Map<String, String> userDetails = {'role': 'Guest', 'phoneNumber': 'N/A'};
  List<SchoolSubmissionInfo> _schoolSubmissions = [];
  List<NotificationItem> _notifications = [];
  bool _isLoadingSubmissions = true;
  String? _submissionError;
  bool _isSubmissionsExpanded = true;
  Timer? _refreshTimer;
  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (mounted) {
        _fetchUnlabeledReports();
      }
    });
    _refreshAll();
    _loadNotifications();
  }

  // ✅ Unified refresh method
  Future<void> _refreshAll() async {
    await _loadUserProfile(); // ✅ Re-fetch clinic name
    await _fetchSchoolSubmissions(); // ✅ Re-fetch submissions
    await _fetchUnlabeledReports();
  }

  // ✅ Fetch full profile from backend
  Future<void> _loadUserProfile() async {
    try {
      // Clear any existing child details when Professional logs in
      await SharedPrefsHelper.clearChildDetailsForProfessional();

      final localDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = localDetails['phoneNumber'];

      if (professionalId == null || professionalId == 'N/A') {
        setState(() {
          userDetails = localDetails;
          if ((userDetails['clinicName']?.isEmpty ?? true)) {
            userDetails['clinicName'] = 'Private Practice';
          }
        });
        return;
      }

      final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
      final uri = Uri.parse(
          '$backendUrl/api/users/verify-professional?professionalId=$professionalId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true) {
          final profile = data['professional'];
          final String? backendClinicName = profile['clinicName'];
          final String? backendName = profile['name'];

          // ✅ Save only if valid
          if (backendClinicName != null) {
            await SharedPrefsHelper.updateUserDetails({
              'clinicName': backendClinicName,
              if (backendName != null) 'name': backendName,
            });
          }

          // ✅ Use saved value, don't overwrite
          final savedDetails = await SharedPrefsHelper.getUserDetails();
          setState(() {
            userDetails = savedDetails;
            if ((userDetails['clinicName']?.isEmpty ?? true)) {
              userDetails['clinicName'] = 'Private Practice';
            }
          });
        } else {
          // Not found → use saved
          setState(() {
            userDetails = localDetails;
            if ((userDetails['clinicName']?.isEmpty ?? true)) {
              userDetails['clinicName'] = 'Private Practice';
            }
          });
        }
      } else {
        // Backend error → use saved
        setState(() {
          userDetails = localDetails;
          if ((userDetails['clinicName']?.isEmpty ?? true)) {
            userDetails['clinicName'] = 'Private Practice';
          }
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      final fallback = await SharedPrefsHelper.getUserDetails();
      setState(() {
        userDetails = fallback;
        if ((userDetails['clinicName']?.isEmpty ?? true)) {
          userDetails['clinicName'] = 'Private Practice';
        }
      });
    }
  }

  // Add to _ProfessionalDashboardState class:
  Future<void> _fetchSchoolSubmissions() async {
    setState(() {
      _isLoadingSubmissions = true;
      _submissionError = null;
    });

    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = userDetails['phoneNumber'];
      final selectedOrgId = await SharedPrefsHelper.getSelectedOrganizationId();
      if (professionalId == null) throw Exception("No professional ID found");

      final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
      Uri uri =
          Uri.parse('$backendUrl/api/reports/professional-school-submissions');
      uri = uri.replace(queryParameters: {
        'professionalId': professionalId ?? '',
        if (selectedOrgId != null && selectedOrgId.isNotEmpty)
          'organizationId': selectedOrgId,
      });

      final response = await NetworkUtils.retryingRequest(
        requestFunction: () => http.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10)),
      );

      if (response.success) {
        dynamic body = response.data;
        // Support both raw list and wrapped { success, data }
        if (body is Map && body['data'] is List) {
          body = body['data'];
        }
        if (body is! List) {
          throw APIException('Unexpected response shape', 500, 'BAD_SHAPE');
        }
        final submissions = body
            .map<SchoolSubmissionInfo>(
                (json) => SchoolSubmissionInfo.fromJson(json))
            .toList();

        setState(() {
          _schoolSubmissions = submissions;
        });
      } else {
        throw APIException(
          response.error ?? 'Unknown error',
          500,
          response.errorId,
        );
      }
    } on TimeoutException {
      setState(() {
        _submissionError = 'Request timed out. Please check your connection.';
      });
    } on APIException catch (e) {
      setState(() {
        _submissionError =
            'Error: ${e.message}${e.errorId != null ? ' (ID: ${e.errorId})' : ''}';
      });
    } catch (e) {
      setState(() {
        _submissionError = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoadingSubmissions = false;
      });
    }
  }

  // ✅ Generate notifications with stable ID
  Future<void> _fetchUnlabeledReports() async {
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final professionalId = userDetails['phoneNumber'];
      if (professionalId == null) return;

      final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
      final uri = Uri.parse('$backendUrl/api/reports/get-unlabeled-reports');
      final response = await http.get(
        uri.replace(queryParameters: {'professionalId': professionalId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> reports = jsonDecode(response.body);
        final List<NotificationItem> newNotifications = [];

        for (var report in reports) {
          final reportId = report['_id']?.toString() ?? '';
          final childName = report['childsName']?.toString() ?? 'Unknown Child';
          final schoolName = (report['schoolName']?.toString() ?? '').isNotEmpty
              ? report['schoolName'].toString()
              : 'Personal Submission';

          // Create unique ID per report
          final notificationId = 'report_$reportId';

          // Skip if already exists
          if (_notifications.any((n) => n.id == notificationId)) continue;

          newNotifications.add(
            NotificationItem(
              id: notificationId,
              title: 'Needs Labeling',
              message: '$childName ($schoolName)',
              timestamp: DateTime.now(),
              reportId: reportId,
              schoolName: schoolName,
              isRead: false,
            ),
          );
        }

        // Sort newest first
        newNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        setState(() {
          _notifications.insertAll(0, newNotifications);
        });

        _saveNotifications();
      }
    } catch (e) {
      print("Error fetching unlabeled reports: $e");
    }
  }

  // ✅ Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPrefsHelper.getUserDetails();
      final savedJson = prefs['notifications'];
      if (savedJson == null || savedJson.isEmpty) return;

      final List<dynamic> list = jsonDecode(savedJson);
      final loaded =
          list.map((item) => NotificationItem.fromJson(item)).toList();

      setState(() {
        _notifications = loaded;
      });
    } catch (e) {
      print("Error loading notifications: $e");
    }
  }

  // ✅ Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await SharedPrefsHelper.updateUserDetails({
        'notifications': jsonEncode(jsonList),
      });
    } catch (e) {
      print("Error saving notifications: $e");
    }
  }

  // ✅ Mark all as read
  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    _saveNotifications(); // ✅ Persist
  }

  // ✅ Clear all notifications
  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });
    _saveNotifications(); // ✅ Save empty list
  }

  // ✅ Format time ago
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) return '${diff.inSeconds} sec ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(userData: userDetails),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await SharedPrefsHelper.clearUserDetails();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => UnifiedLoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalToday = _schoolSubmissions.fold(0, (sum, s) => sum + s.todayCount);
    int totalAllTime =
        _schoolSubmissions.fold(0, (sum, s) => sum + s.totalCount);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Icon(Icons.home, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: _isLoadingSubmissions
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.refresh, color: Colors.white),
              onPressed: _isLoadingSubmissions ? null : _refreshAll,
              tooltip: "Refresh Data",
            ),
            IconButton(
              icon: Icon(Icons.account_circle, size: 30, color: Colors.white),
              onPressed: _navigateToEditProfile,
              tooltip: "Edit Profile",
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              onPressed: _logout,
              tooltip: "Logout",
            ),
            SizedBox(width: 16),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshAll,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),

                  // ✅ Welcome Greeting
                  Text(
                    'Welcome, Dr. ${userDetails['name']?.split(' ').first ?? 'Valued User'}!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // 🧾 User Info Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Show Clinic Name instead of Role
                        Row(
                          children: [
                            Icon(Icons.business, color: Colors.black),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Clinic: ${userDetails['clinicName']?.isNotEmpty == true ? userDetails['clinicName'] : 'Private Practice'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              'Phone: ${userDetails['phoneNumber']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  _buildButton('Report Dashboard'),
                  SizedBox(height: 16),
                  _buildButton("Capture Child's Drawing"),
                  SizedBox(height: 16),
                  _buildButton('Label Previous Data'),
                  SizedBox(height: 16),
                  _buildButton('School Analysis'),
                  SizedBox(height: 16),
                  _buildButton('Logout'),
                  SizedBox(height: 32),

                  // --- Submissions Section ---
                  ExpansionTile(
                    title: Text(
                      "Submissions by School",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    initiallyExpanded: _isSubmissionsExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isSubmissionsExpanded = expanded;
                      });
                    },
                    children: [
                      _buildSubmissionsSummaryCard(totalToday, totalAllTime),
                      _buildSchoolSubmissionsAnimatedList(),
                      SizedBox(height: 16),
                      Text(
                        "Total submissions today: $totalToday",
                        style: TextStyle(fontSize: 16, color: Colors.blue[900]),
                      ),
                      Text(
                        "Total submissions (all time): $totalAllTime",
                        style: TextStyle(fontSize: 16, color: Colors.blue[900]),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // --- Notifications ---
                  if (_notifications.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LabelPreviousDataScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.list_alt),
                            label: Text("View All Unlabeled Reports"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final n = _notifications[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                onTap: () async {
                                  setState(() {
                                    n.isRead = true;
                                  });
                                  _saveNotifications();

                                  if (n.reportId != null) {
                                    final userDetails = await SharedPrefsHelper
                                        .getUserDetails();
                                    final role =
                                        userDetails['role'] ?? 'professional';

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReportDetailsScreen(
                                          reportId: n.reportId!,
                                          userRole: role,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                leading: Icon(
                                  Icons.upload,
                                  color: n.isRead ? Colors.grey : Colors.blue,
                                ),
                                title: Text(
                                  n.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: n.isRead ? Colors.grey[600] : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.message,
                                      style: n.isRead
                                          ? TextStyle(color: Colors.grey[600])
                                          : null,
                                    ),
                                    Text(
                                      _formatTimeAgo(n.timestamp),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: !n.isRead
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _markAllAsRead,
                              icon: Icon(Icons.mark_chat_read),
                              label: Text("Mark All Read"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _clearAllNotifications,
                              icon: Icon(Icons.delete),
                              label: Text("Clear All"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Text(
                      'No new notifications',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Report Dashboard') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportsDashboardScreen(),
              ),
            );
          } else if (text == "Capture Child's Drawing") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TagImageManually(
                  "Professional",
                  data:
                      "Professional", // Fix: Pass "Professional" instead of empty string
                ),
              ),
            ).then((result) {
              if (result == 'refresh') {
                _fetchSchoolSubmissions();
              }
            });
          } else if (text == 'Label Previous Data') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LabelPreviousDataScreen(),
              ),
            );
          } else if (text == 'School Analysis') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SchoolsScreen(),
              ),
            );
          } else if (text == 'Logout') {
            _logout();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolSubmissionsAnimatedList() {
    if (_isLoadingSubmissions) {
      return Center(child: CircularProgressIndicator());
    }
    if (_submissionError != null) {
      return ErrorDisplay(
        error: _submissionError!,
        onRetry: _fetchSchoolSubmissions,
      );
    }
    if (_schoolSubmissions.isEmpty) {
      return Center(child: Text('No assigned schools or no submissions.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _schoolSubmissions.length,
      itemBuilder: (context, index) {
        final info = _schoolSubmissions[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: info.schoolName == "Personal Submissions"
                  ? Colors.deepPurple
                  : Colors.blue,
              child: Icon(
                info.schoolName == "Personal Submissions"
                    ? Icons.person
                    : Icons.school,
                color: Colors.white,
              ),
            ),
            title: Text(
              info.schoolName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                Icon(Icons.today, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text("Today: ", style: TextStyle(color: Colors.green)),
                Text("${info.todayCount}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                Icon(Icons.all_inbox, size: 16, color: Colors.orange),
                SizedBox(width: 4),
                Text("Total: ", style: TextStyle(color: Colors.orange)),
                Text("${info.totalCount}",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (info.todayCount > 5)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Hot!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmissionsSummaryCard(int totalToday, int totalAllTime) {
    return Card(
      color: Colors.blue[50],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text("Today", style: TextStyle(color: Colors.blue)),
                Text("$totalToday",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            Column(
              children: [
                Text("All Time", style: TextStyle(color: Colors.orange)),
                Text("$totalAllTime",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
