import 'package:flutter/material.dart';
import 'package:mindseye/NGOlogin.dart';
import 'package:mindseye/NGOmobileLogin.dart';
import 'package:mindseye/assignadmintoschool.dart';
import 'package:mindseye/createProfessionalAccount.dart';
import 'package:mindseye/createSchoolAccount.dart';
import 'package:mindseye/createadminaccount.dart';
import 'package:mindseye/login.dart';

class NGODashboard extends StatefulWidget {
  final String data;

  const NGODashboard({
    Key? key,
    required this.data,
  }) : super(key: key);
  @override
  _NGODashboardState createState() => _NGODashboardState();
}

class _NGODashboardState extends State<NGODashboard> {
  // Assuming this value is dynamic and fetched from a backend
  int imagesSubmittedToday = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40), // Spacing from top
              Text(
                'NGO Dashboard',
                style: TextStyle(
                  fontSize: 24, // Title font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32), // Space below title
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Create School Account screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateSchoolAccount(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create School Account',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16), // Space between buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Create Professional Account screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateProfessionalAccount(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Professional Account',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),



              // SizedBox(height: 16), // Space between buttons
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Logout logic here
              //       Navigator.push(context,
              //           MaterialPageRoute(builder: (context) => LoginScreen()));
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.black,
              //       padding: EdgeInsets.symmetric(vertical: 16),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: Text(
              //       'Create Professional Account',
              //       style: TextStyle(fontSize: 16, color: Colors.white),
              //     ),
              //   ),
              // ),





              SizedBox(height: 16), // Space between buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logout logic here
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateAdminAccountScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Create Admin Account',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),


              SizedBox(height: 16), // Space between buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logout logic here
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AssignAdminToSchoolScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Assign Admin to School',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),







              SizedBox(height: 16), // Space between buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Logout logic here
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 24), // Space below buttons
              Text(
                '$imagesSubmittedToday images submitted today',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
