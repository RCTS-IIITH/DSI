import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/adminDahboard.dart';
import 'package:mindseye/parentDashboard.dart';
import 'package:mindseye/professionalDashboard.dart';
import 'package:mindseye/schoolDashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';
import './sendotp.dart';

class MobileNumberScreen extends StatefulWidget {
  final String data; // Role of the user (e.g., Parent, Teacher)

  const MobileNumberScreen({Key? key, required this.data}) : super(key: key);

  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final TextEditingController _mobileController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> requestOtp() async {
    String phoneNumber = _mobileController.text.trim();

    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a mobile number";
      });
      return;
    }

    if (phoneNumber.length != 10) {
      setState(() {
        _errorMessage = "Please enter a valid 10-digit mobile number.";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      await sendOtp('+91', phoneNumber, widget.data);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OTPScreen(mobileNumber: phoneNumber, data: widget.data),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to send OTP. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: Text("Back"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Mobile Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please enter a 10-digit mobile number.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : requestOtp,
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
                          'Request OTP',
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

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  final String data; // Role of the user

  const OTPScreen({required this.mobileNumber, required this.data});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _otpErrorMessage;

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
    });

    try {
      bool isValid = await verifyOtp('+91', widget.mobileNumber, otp);
      if (isValid) {
        print("User role: ${widget.data}");

        // Save user details in SharedPreferences
        await SharedPrefsHelper.saveUserDetails(
            widget.data, widget.mobileNumber);

        // Navigate to the appropriate dashboard based on the role
        if (widget.data == "Parent") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParentDashboardScreen(
                data: widget.mobileNumber,
                phone: widget.mobileNumber,
              ),
            ),
          );
        } else if (widget.data == "Teacher") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SchoolDashboardScreen(data: widget.mobileNumber),
            ),
          );
        } else if (widget.data == "NGO Master") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NGODashboard(data: widget.mobileNumber),
            ),
          );
        } else if (widget.data == "Professional") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProfessionalDashboard(data: widget.mobileNumber),
            ),
          );
        } else if (widget.data == "Admin") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboard(data: widget.mobileNumber),
            ),
          );
        }
      } else {
        setState(() {
          _otpErrorMessage = "Incorrect OTP. Please try again.";
        });
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      setState(() {
        _otpErrorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to MobileNumberScreen
          },
        ),
        title: Text("Back"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      sendOtp('+91', widget.mobileNumber,
                          widget.data); // Resend OTP
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
                  onPressed: submitOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
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
