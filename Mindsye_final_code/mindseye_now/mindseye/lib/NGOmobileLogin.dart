import 'package:flutter/material.dart';
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/adminDahboard.dart';
import 'package:mindseye/parentDashboard.dart';
import 'package:mindseye/professionalDashboard.dart';
import 'package:mindseye/schoolDashboard.dart';
import './sendotp.dart';

class MobileNumberScreen extends StatefulWidget {
  final String data;

  const MobileNumberScreen({Key? key, required this.data}) : super(key: key);

  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen>
    with SingleTickerProviderStateMixin {
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please enter your mobile number',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : requestOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Request OTP',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  final String data;

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
        switch (widget.data) {
          case "Parent":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ParentDashboardScreen(
                  data: widget.mobileNumber,
                  phone: widget.mobileNumber,
                ),
              ),
            );
            break;
          case "Teacher":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SchoolDashboardScreen(
                  data: widget.mobileNumber,
                  phone: widget.mobileNumber,
                ),
              ),
            );
            break;
          case "NGO Master":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NGODashboard(data: widget.mobileNumber),
              ),
            );
            break;
          case "Professional":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfessionalDashboard(
                  data: widget.mobileNumber,
                  phone: widget.mobileNumber,
                ),
              ),
            );
            break;
          case "Admin":
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboard(data: widget.mobileNumber),
              ),
            );
            break;
        }
      } else {
        setState(() {
          _otpErrorMessage = "Incorrect OTP. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _otpErrorMessage = "Something went wrong. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'OTP sent to +91-${widget.mobileNumber}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
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
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      sendOtp('+91', widget.mobileNumber, widget.data);
                    },
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
