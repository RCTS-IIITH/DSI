import 'package:flutter/material.dart';
import 'package:mindseye/EditProfileScreen.dart';
import 'package:mindseye/labelPreviousData.dart';
import 'package:mindseye/login.dart';
import 'package:mindseye/reportsDashboard.dart';
import 'package:mindseye/schoolScreen.dart';
import 'package:mindseye/tagImageManuaaly.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfessionalDashboard extends StatefulWidget {
final String data;
const ProfessionalDashboard({
super.key,
required this.data,
});

@override
_ProfessionalDashboardState createState() => _ProfessionalDashboardState();
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
return SchoolSubmissionInfo(
schoolId: json['schoolId'].toString(),
schoolName: json['schoolName'] ?? 'Unknown',
todayCount: json['todayCount'] ?? 0,
totalCount: json['totalCount'] ?? 0,
);
}
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
Map<String, String> userDetails = {'role': 'Guest', 'phoneNumber': 'N/A'};
List<SchoolSubmissionInfo> _schoolSubmissions = [];
bool _isLoadingSubmissions = true;
String? _submissionError;
bool _isSubmissionsExpanded = true; // State for ExpansionTile

@override
void initState() {
super.initState();
_loadUserDetails();
_fetchSchoolSubmissions();
}

Future<void> _loadUserDetails() async {
final details = await SharedPrefsHelper.getUserDetails();
setState(() {
userDetails = details;
});
}

Future<List<SchoolSubmissionInfo>> fetchSchoolSubmissions(
String professionalId) async {
final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3000";
final uri = Uri.parse(
'$backendUrl/api/reports/professional-school-submissions?professionalId=$professionalId');
final response = await http.get(uri);
if (response.statusCode == 200) {
final List<dynamic> data = jsonDecode(response.body);
return data.map((json) => SchoolSubmissionInfo.fromJson(json)).toList();
} else {
throw Exception('Failed to load school submissions');
}
}

Future<void> _fetchSchoolSubmissions() async {
setState(() {
_isLoadingSubmissions = true;
_submissionError = null;
});
try {
final userDetails = await SharedPrefsHelper.getUserDetails();
final professionalId = userDetails['phoneNumber'];
if (professionalId == null) throw Exception("No professional ID found");
final submissions = await fetchSchoolSubmissions(professionalId);
setState(() {
_schoolSubmissions = submissions;
});
} catch (e) {
setState(() {
_submissionError = e.toString();
});
} finally {
setState(() {
_isLoadingSubmissions = false;
});
}
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
onPressed: () => Navigator.pop(ctx),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () async {
await SharedPrefsHelper.clearUserDetails();
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (_) => LoginScreen()),
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
int totalToday =
_schoolSubmissions.fold(0, (sum, s) => sum + s.todayCount);
int totalAllTime =
_schoolSubmissions.fold(0, (sum, s) => sum + s.totalCount);

return WillPopScope(
onWillPop: () async => false, // 🔒 Disable system back button
child: Scaffold(
appBar: AppBar(
backgroundColor: Colors.blue,
elevation: 0,
automaticallyImplyLeading: false, // 👈 Hides back arrow
title: Row(
children: [
Icon(Icons.home, color: Colors.white), // Optional home icon
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
icon: Icon(Icons.account_circle, size: 30, color: Colors.white),
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => EditProfileScreen(userData: userDetails),
),
);
},
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
// Wrap body with RefreshIndicator for pull-to-refresh
body: RefreshIndicator(
onRefresh: _fetchSchoolSubmissions, // Refresh submissions data
child: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 16),
// Personalized Greeting (assuming name is stored)
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
Row(
children: [
Icon(Icons.person, color: Colors.black),
SizedBox(width: 8),
Text(
'Role: ${userDetails['role']}',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
color: Colors.black,
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

// --- NEW: Submissions Section (Wrapped in ExpansionTile) ---
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
// Removed SizedBox with fixed height
_buildSchoolSubmissionsAnimatedList(), // Added directly
SizedBox(height: 16),
Text(
"Total submissions today: $totalToday",
style:
TextStyle(fontSize: 16, color: Colors.blue[900]),
),
Text(
"Total submissions (all time): $totalAllTime",
style:
TextStyle(fontSize: 16, color: Colors.blue[900]),
),
],
),
// --- End Submissions Section ---

SizedBox(height: 32),
// --- Notifications (optional, keep or remove as needed) ---
Text(
'Notifications',
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 16),
_buildNotification(
'Report ready for School A',
'Updated on: 10/05/2025',
),
SizedBox(height: 16),
_buildNotification(
'School B Uploaded the pictures',
'Updated on: 10/05/2025',
),
SizedBox(height: 24),
Center(
child: SizedBox(
width: 300,
height: 50,
child: ElevatedButton(
onPressed: () {
// Add action for marking all as read
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Marked all as read!')),
);
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.black,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: Text(
'Mark All as Read',
style: TextStyle(
fontSize: 18,
color: Colors.white,
),
),
),
),
),
SizedBox(height: 16), // Add some padding at the bottom
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
builder: (context) => TagImageManually(data: "Professional"),
),
).then((result) {
if (result == 'refresh') {
_fetchSchoolSubmissions(); // Refresh the counts
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

Widget _buildNotification(String title, String date) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
),
),
Text(
date,
style: TextStyle(
fontSize: 14,
color: Colors.grey[600],
),
),
],
);
}

Widget _buildSchoolSubmissionsAnimatedList() {
if (_isLoadingSubmissions) {
return Center(child: CircularProgressIndicator());
}
if (_submissionError != null) {
return Center(child: Text('Error: $_submissionError'));
}
if (_schoolSubmissions.isEmpty) {
return Center(child: Text('No assigned schools or no submissions.'));
}
// Modified ListView.builder with shrinkWrap and physics
return ListView.builder(
shrinkWrap: true, // <--- Allows dynamic height
physics:
NeverScrollableScrollPhysics(), // <--- Delegates scrolling to parent
itemCount: _schoolSubmissions.length,
itemBuilder: (context, index) {
final info = _schoolSubmissions[index];
return Card(
margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
elevation: 2,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14)),
child: ListTile(
// Make the list tile tappable
onTap: () {
// Example action: Show a snackbar
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Tapped on ${info.schoolName}")),
);
// TODO: Navigate to school detail screen
// Navigator.push(
// context,
// MaterialPageRoute(
// builder: (context) => SchoolDetailScreen(schoolId: info.schoolId),
// ),
// );
},
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
// Example badge for high submission count
if (info.todayCount >
5) // Adjust threshold as needed
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
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
],
),
Column(
children: [
Text("All Time", style: TextStyle(color: Colors.orange)),
Text("$totalAllTime",
style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
],
),
],
),
),
);
}
}

