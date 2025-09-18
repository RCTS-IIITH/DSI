import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import SharedPreferences helper
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:mindseye/schoolsAnalysis.dart';

// ✅ School Model Class
class School {
  final String name;
  final String udise;
  final String address;
  final String contactNumber;
  String get displayName => name.toUpperCase();

  School({
    required this.name,
    required this.udise,
    required this.address,
    required this.contactNumber,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      name: json['schoolName'] ?? 'Unnamed School',
      udise:
          (json['udiseNumber'] ?? json['UDISE'] ?? 'Not Available').toString(),
      address: json['address'] ?? 'Address not available',
      contactNumber: json['contactNumber']?.toString() ??
          'Not Available', // Handle null or number
    );
  }
}

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});

  @override
  _SchoolsScreenState createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  List<School> assignedSchools = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String backendUrl = dotenv.env['BACKEND_URL'] ?? '';

  Future<void> _fetchAssignedSchools() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });
    try {
      final userDetails = await SharedPrefsHelper.getUserDetails();
      final phoneNumber = userDetails['phoneNumber'];

      if (phoneNumber == null || phoneNumber.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Professional phone number not found.';
          isLoading = false;
        });
        return;
      }

      final assignedUrl =
          Uri.parse('$backendUrl/api/users/get-assigned-schools')
              .replace(queryParameters: {'phoneNumber': phoneNumber});
      final assignedRes = await http.get(assignedUrl);

      if (assignedRes.statusCode != 200) {
        setState(() {
          hasError = true;
          errorMessage =
              'Failed to fetch assigned schools. Status: ${assignedRes.statusCode}';
          isLoading = false;
        });
        return;
      }

      final assignedData = json.decode(assignedRes.body);
      if (!assignedData['success']) {
        setState(() {
          hasError = true;
          errorMessage = assignedData['message'] ?? 'No schools assigned.';
          isLoading = false;
        });
        return;
      }

      final assignedNames = List<String>.from(assignedData['data']);

      final selectedOrgId = await SharedPrefsHelper.getSelectedOrganizationId();
      final baseSchoolsUrl = Uri.parse('$backendUrl/api/users/get-schools');
      final schoolsUrl = baseSchoolsUrl.replace(
        queryParameters: (selectedOrgId != null && selectedOrgId.isNotEmpty)
            ? {'organizationId': selectedOrgId}
            : null,
      );
      final schoolsRes = await http.get(schoolsUrl);

      if (schoolsRes.statusCode != 200) {
        setState(() {
          hasError = true;
          errorMessage =
              'Failed to fetch school details. Status: ${schoolsRes.statusCode}';
          isLoading = false;
        });
        return;
      }

      final schoolsData = json.decode(schoolsRes.body);
      dynamic body = schoolsData;
      if (body is Map && body['data'] is List) {
        body = body['data'];
      }
      if (body is! List) {
        throw Exception('Unexpected schools response shape');
      }
      final allSchools = body
          .map<School>((item) => School.fromJson(item as Map<String, dynamic>))
          .toList();

      final filteredSchools = allSchools
          .where((school) => assignedNames.contains(school.name))
          .toList();

      setState(() {
        assignedSchools = filteredSchools;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAssignedSchools();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Schools'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // // const Text(
                // //   'Assigned Schools',
                // //   style: TextStyle(
                // //     fontSize: 28,
                // //     fontWeight: FontWeight.bold,
                // //     color: Colors.indigo,
                // //   ),
                // // ),
                // const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo,
                      strokeWidth: 3,
                    ),
                  )
                else if (hasError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          '⚠️ $errorMessage',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchAssignedSchools,
                          icon: Icon(Icons.refresh),
                          label: Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (assignedSchools.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 64, color: Colors.indigoAccent),
                        const SizedBox(height: 12),
                        const Text(
                          'No schools assigned yet.',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      color: Colors.indigo,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      onRefresh: _fetchAssignedSchools,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: assignedSchools.length,
                        itemBuilder: (context, index) {
                          final school = assignedSchools[index];
                          return _buildSchoolCard(school);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Enhanced School Card UI
  Widget _buildSchoolCard(School school) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        school.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.school, color: Colors.indigo),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.qr_code, 'UDISE: ${school.udise}'),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.location_on, 'Address: ${school.address}'),
                const SizedBox(height: 8),
                _buildDetailRow(
                    Icons.phone, 'Contact: ${school.contactNumber}'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SchoolAnalysisScreen(schoolName: school.name),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 16),
                    label: const Text('View Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.indigo),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
