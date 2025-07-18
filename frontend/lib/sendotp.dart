import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

// ✅ Fixed Dummy OTP for development
const String dummyOtp = '123456';

/// ✅ Function to send OTP (checks DB + uses dummy OTP)
Future<void> sendOtp(
    String dialCode, String phoneNumber, String usertype) async {
  String backendUrl = dotenv.env['BACKEND_URL']!;
  final url = '$backendUrl/api/users/search-number';

  // Step 1: Check if number exists in DB
  final responseMongo = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'usertype': usertype,
      'number': phoneNumber,
    }),
  );

  print("📨 Backend Response: ${responseMongo.body}");

  if (responseMongo.statusCode != 200) {
    throw Exception(
        "❌ User not found in DB (status: ${responseMongo.statusCode})");
  }

  print("✅ User exists. Skipping real OTP send.");
  print("🔐 Dummy OTP used: $dummyOtp");
}

/// ✅ Function to verify dummy OTP
Future<bool> verifyOtp(String dialCode, String phoneNumber, String otp) async {
  print("🔍 Verifying OTP in DEV mode...");

  if (otp == dummyOtp) {
    print('✅ OTP verified successfully (Dummy Mode).');
    return true;
  } else {
    print('❌ OTP verification failed (Dummy Mode).');
    return false;
  }
}
