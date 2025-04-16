/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mindseye/schoolsAnalysis.dart';

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});

  @override
  _SchoolsScreenState createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  List<dynamic> schools = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/users/get-schools'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          schools = data;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching schools: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Schools',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                const Center(child: Text('Error fetching schools'))
              else if (schools.isEmpty)
                const Center(child: Text('No schools available'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: schools.length,
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      final schoolName =
                          school['schoolName'] ?? 'Unnamed School';
                      return Column(
                        children: [
                          _buildSchoolButton(schoolName),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolButton(String schoolName) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolAnalysisScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          schoolName,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
 


*/
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SchoolsScreen extends StatefulWidget {
  const SchoolsScreen({super.key});

  @override
  _SchoolsScreenState createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  List<dynamic> schools = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/api/users/get-schools'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          schools = data;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching schools: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Schools',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                const Center(child: Text('Error fetching schools'))
              else if (schools.isEmpty)
                const Center(child: Text('No schools available'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: schools.length,
                    itemBuilder: (context, index) {
                      final school = schools[index];
                      final schoolName =
                          school['schoolName'] ?? 'Unnamed School';
                      final udiseNumber = school['UDISE'] ?? 'Not Available';
                      final address =
                          school['address'] ?? 'Address not available';
                      return _buildSchoolCard(schoolName, udiseNumber, address);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolCard(
      String schoolName, String udiseNumber, String address) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AnimatedContainer(
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            // Navigate to a detailed screen or perform any action
            print("Tapped on $schoolName");
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // School Name
              Text(
                schoolName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),

              // UDISE Number
              Row(
                children: [
                  Icon(Icons.account_balance,
                      color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "UDISE: $udiseNumber", // Display UDISE number here
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Address
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
