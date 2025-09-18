// unified_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'unified_otp_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({Key? key}) : super(key: key);

  @override
  _UnifiedLoginScreenState createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _mobileController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  late AnimationController _errorAnimationController;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _errorAnimation = CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _errorAnimationController.dispose();
    super.dispose();
  }

  /// Checks if the phone number exists in any user collection.
  Future<bool> _checkUserExists(String phoneNumber) async {
    try {
      final backendUrl = dotenv.env['BACKEND_URL'] ?? "http://localhost:3001";
      final uri = Uri.parse('$backendUrl/api/users/search-number');
      print("📡 Checking user existence for $phoneNumber");

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usertype': 'Any', 'number': phoneNumber}),
      );

      print("📥 Backend response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['exists'] == true) {
          print("✅ User found");
          return true;
        } else {
          print("⚠️ User not found (from backend 200 response)");
          setState(() {
            _errorMessage = data['message'] ?? "User not found.";
            _errorAnimationController.forward();
          });
          return false;
        }
      } else if (response.statusCode == 404) {
        final data = jsonDecode(response.body);
        print("❓ User not found (404 response)");
        setState(() {
          _errorMessage = data['message'] ?? "User not found for this number.";
          _errorAnimationController.forward();
        });
        return false;
      } else {
        print("❌ Error checking user: ${response.statusCode}");
        setState(() {
          _errorMessage = "Error checking number. Please try again.";
          _errorAnimationController.forward();
        });
        return false;
      }
    } catch (e) {
      print("💥 Network error in _checkUserExists: $e");
      setState(() {
        _errorMessage = "Network error. Please check your connection.";
        _errorAnimationController.forward();
      });
      return false;
    }
  }

  /// Handles the OTP request button press.
  Future<void> requestOtp() async {
    String phoneNumber = _mobileController.text.trim();
    if (phoneNumber.isEmpty) {
      _handleValidationError("Please enter a mobile number");
      return;
    }
    if (phoneNumber.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      _handleValidationError("Please enter a valid 10-digit mobile number.");
      return;
    }

    setState(() {
      _errorMessage = null;
      _errorAnimationController.reset();
      _isLoading = true;
    });

    try {
      bool userExists = await _checkUserExists(phoneNumber);

      if (userExists) {
        print("✅ Proceeding to OTP screen.");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnifiedOTPScreen(mobileNumber: phoneNumber),
          ),
        );
      } else {
        print("❌ User not found. Stopping flow.");
        // Ensure loading stops if user not found
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("💥 Unexpected error in requestOtp: $e");
      setState(() {
        _errorMessage = "Failed to proceed. Please try again.";
        _errorAnimationController.forward();
        _isLoading = false;
      });
    }
  }

  /// Helper to set validation error state.
  void _handleValidationError(String message) {
    setState(() {
      _errorMessage = message;
      _errorAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final errorColor = Colors.red.shade700;

    return GestureDetector(
      onTap: () {
        if (_mobileController.text.isNotEmpty) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.blue,
          title: Text(
            "Login",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Please sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Mobile Number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Enter 10-digit mobile number',
                    labelStyle: TextStyle(
                      color: _isLoading ? Colors.grey : primaryColor,
                    ),
                    filled: true,
                    fillColor:
                        _isLoading ? Colors.grey.shade200 : Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: primaryColor, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: errorColor, width: 2.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: errorColor, width: 2.0),
                    ),
                    prefixIcon: Icon(Icons.phone_android,
                        color: _isLoading ? Colors.grey : primaryColor),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                  ),
                  onChanged: (value) {
                    if (_errorMessage != null && value.isNotEmpty) {
                      setState(() {
                        _errorMessage = null;
                        _errorAnimationController.reset();
                      });
                    }
                  },
                ),
                SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _errorMessage != null
                      ? Text(
                          _errorMessage!,
                          key: ValueKey<String>(_errorMessage!),
                          style: TextStyle(
                            color: errorColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : requestOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: _isLoading ? 0 : 4,
                      padding: EdgeInsets.zero,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sms, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Request OTP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
}
