import 'package:flutter/material.dart';
import 'package:mindseye/NGOmobileLogin.dart';
import 'package:mindseye/login.dart';

class SchoolLoginScreen extends StatefulWidget {
  @override
  _SchoolLoginScreenState createState() => _SchoolLoginScreenState();
}

class _SchoolLoginScreenState extends State<SchoolLoginScreen> {
  void _navigateToLogin(String userType) {
    print(userType);
    if (userType == "Parent") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MobileNumberScreen(data: "Parent")));
    } else if (userType == "Admin")
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MobileNumberScreen(data: "Admin")));
    else if (userType == "Teacher")
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MobileNumberScreen(data: "Teacher")));
    else
      print("Invalid user type");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // Add WillPopScope wrapper
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Clear navigation stack and push LoginScreen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            title: Text("School Login"),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32),
                  Text(
                    'School Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Login as Parent Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _navigateToLogin("Parent"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login as Parent',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Login as Admin Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _navigateToLogin("Admin"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login as Admin',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Login as Teacher Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _navigateToLogin("Teacher"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Login as Teacher',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  Spacer(),
                  // Profile Image
                  Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ));
  }
}
