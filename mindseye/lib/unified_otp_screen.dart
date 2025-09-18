// unified_otp_screen.dart
import 'package:flutter/material.dart';
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/adminDahboard.dart'; // Assuming this is the correct path
import 'package:mindseye/parentDashboard.dart';
import 'package:mindseye/professionalDashboard.dart';
import 'package:mindseye/schoolDashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import './sendotp.dart'; // Assuming verifyOtp is here
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UnifiedOTPScreen extends StatefulWidget {
  final String mobileNumber;
  // No 'data' (role) parameter anymore
  const UnifiedOTPScreen({required this.mobileNumber});

  @override
  _UnifiedOTPScreenState createState() => _UnifiedOTPScreenState();
}

class _UnifiedOTPScreenState extends State<UnifiedOTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _otpErrorMessage;
  bool _isLoading = false;

  // --- NEW FUNCTION: Fetch User Role and Profile ---
  Future<Map<String, dynamic>?> _detectRoleAndFetchProfile(
      String phoneNumber) async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
      final uri =
          Uri.parse('$backendUrl/api/users/detect-role-and-fetch-profile');
      print("📡 Calling backend to detect role for $phoneNumber");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      print(
          "📥 Backend response status: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print("✅ Role detected: ${data['detectedRole']}");
          print("✅ Profile data fetched: ${data['profileData']}");
          return data; // Contains 'detectedRole' and 'profileData'
        } else {
          print("⚠️ Backend reported failure: ${data['message']}");
          return null;
        }
      } else if (response.statusCode == 404) {
        print("❓ User not found for number $phoneNumber");
        // You might want to show a specific message to the user here
        return null;
      } else {
        print(
            "❌ Failed to detect role. Status: ${response.statusCode}. Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("💥 Error calling detect-role endpoint: $e");
      return null; // Indicate failure
    }
  }
  // --- END NEW FUNCTION ---

  Future<void> submitOtp() async {
    String otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        _otpErrorMessage = "Please enter the OTP";
      });
      return;
    }
    setState(() {
      _otpErrorMessage = null;
      _isLoading = true; // Start loading indicator
    });

    try {
      // Assuming verifyOtp is your current dummy validation that returns true/false
      bool isValid = await verifyOtp('+91', widget.mobileNumber, otp);

      if (isValid) {
        print("✅ OTP verified successfully for number: ${widget.mobileNumber}");

        // --- NEW CODE: Detect Role and Fetch Profile ---
        final roleDetectionResult =
            await _detectRoleAndFetchProfile(widget.mobileNumber);

        if (roleDetectionResult == null) {
          // Handle case where role detection failed or user not found
          setState(() {
            _otpErrorMessage =
                "User account not found or error occurred. Please contact support.";
            _isLoading = false; // Stop loading indicator
          });
          return; // Stop the login process
        }

        final String detectedRole = roleDetectionResult['detectedRole'];
        final Map<String, dynamic> profileData =
            roleDetectionResult['profileData'];

        // --- Save User Details to SharedPreferences ---
        // Prepare data to save based on the fetched profile
        String? nameToSave;
        String? clinicNameToSave; // Specific for Professionals
        // Add other role-specific data as needed

        if (detectedRole == "Professional") {
          nameToSave = profileData['name'];
          clinicNameToSave = profileData['clinicName'];
          // You could also save assignedSchoolIds if needed immediately
        } else if (detectedRole == "Parent") {
          nameToSave = profileData['name'];
          // Add other Parent-specific data if fetched
        } else if (detectedRole == "Teacher") {
          nameToSave = profileData['name'];
          // Add other Teacher-specific data if fetched
        } else if (detectedRole == "Admin" || detectedRole == "NGO Master") {
          nameToSave = profileData['name'];
          // Add other Admin-specific data if fetched (e.g., assignedSchoolList)
        }

        // Save details including the DETECTED role
        await SharedPrefsHelper.saveUserDetails(
          detectedRole, // Use the role detected by the backend
          widget.mobileNumber,
          name: nameToSave,
          clinicName: clinicNameToSave, // Pass clinicName if applicable
          // Add other relevant data based on role if needed and fetched
        );
        print(
            "💾 Saved user details: Role=$detectedRole, Phone=${widget.mobileNumber}, Name=$nameToSave");

        // Stop loading indicator before navigation
        setState(() {
          _isLoading = false;
        });

        // --- Navigate Based on DETECTED Role ---
        print("🧭 Navigating to dashboard for role: $detectedRole");
        if (detectedRole == "Parent") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ParentDashboardScreen(
                widget.mobileNumber,
                phone: widget.mobileNumber,
                data: '',
              ),
            ),
            (route) => false, // Remove all previous routes
          );
        } else if (detectedRole == "Teacher") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolDashboardScreen(widget.mobileNumber,
                  data: widget.mobileNumber),
            ),
            (route) => false,
          );
        } else if (detectedRole == "NGO Master") {
          // Use the frontend role name
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => NGODashboard(data: widget.mobileNumber),
            ),
            (route) => false,
          );
        } else if (detectedRole == "Professional") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => ProfessionalDashboard(widget.mobileNumber,
                  data: widget.mobileNumber),
            ),
            (route) => false,
          );
        } else if (detectedRole == "Admin") {
          // Use the frontend role name
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboard(widget.mobileNumber,
                  data: widget.mobileNumber),
            ),
            (route) => false,
          );
        } else {
          // Handle unexpected roles
          print("⚠️ Unexpected role detected: $detectedRole");
          setState(() {
            _otpErrorMessage =
                "Unsupported user role detected. Please contact support.";
            _isLoading = false; // Stop loading indicator
          });
          // Optionally clear saved details if role is invalid
          // await SharedPrefsHelper.clearUserDetails();
        }
        // --- End Navigation ---
      } else {
        setState(() {
          _otpErrorMessage = "Incorrect OTP. Please try again.";
          _isLoading = false; // Stop loading indicator
        });
      }
    } catch (e) {
      print("Error during OTP submission or role detection: $e");
      setState(() {
        _otpErrorMessage = "Something went wrong. Please try again.";
        _isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Enter OTP"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Enter OTP sent to',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '+91 ${widget.mobileNumber}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading, // Disable input during loading
                decoration: InputDecoration(
                  labelText: 'OTP',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_otpErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _otpErrorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align right
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Resend OTP logic (dummy or real)
                            // sendOtp('+91', widget.mobileNumber, 'Unified');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("OTP Resent (Dummy)")),
                            );
                          },
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : submitOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
