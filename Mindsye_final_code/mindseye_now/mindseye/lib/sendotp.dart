import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:http/http.dart' as http;
// Initialize Twilio
//final twilioFlutter = TwilioFlutter(
//accountSid://// Replace with your Account SID
//authToken: //'// Replace with your Auth Token
//twilioNumber: '+91', // Replace with your Twilio number
// Replace with your Verification Service Id
//);

// Function to send OTP
Future<void> sendOtp(
    String dialCode, String phoneNumber, String usertype) async {
  String backendUrl = dotenv.env['BACKEND_URL']!;

  final url = '${backendUrl}/api/users/search-number';

  var response_mongo = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'usertype': usertype, 'number': phoneNumber}),
  );

  print(response_mongo.body);

  final responseData =
      jsonDecode(response_mongo.body); // Decode the JSON response

  if (responseData['message'] == "Error Fetching User") {
    throw Exception(
        "User not found"); // Throw an exception if the user is not found
  }

  print("User found");

  TwilioResponse response = await twilioFlutter.sendVerificationCode(
    //verificationServiceId:',
    recipient: '$dialCode${phoneNumber.replaceAll(" ", "")}',
    verificationChannel: VerificationChannel.SMS,
  );

  if (response.responseState != ResponseState.SUCCESS) {
    throw Exception('Failed to send OTP: ${response.responseState}');
  }

  print('OTP sent successfully.');
}

extension on String {
  get message => null;
}

extension on http.Response {
  get status => null;
}

Future<bool> verifyOtp(String dialCode, String phoneNumber, String otp) async {
  try {
    TwilioResponse response = await twilioFlutter.verifyCode(
      // verificationServiceId:
      recipient: '$dialCode${phoneNumber.replaceAll(" ", "")}',
      code: otp,
    );

    if (response.responseState == ResponseState.SUCCESS &&
        response.metadata?['status'] == 'approved') {
      print('OTP verified successfully.');
      return true; // OTP is valid
    } else {
      print('OTP verification failed: ${response.metadata?['status']}');
      return false; // OTP is invalid
    }
  } catch (e) {
    print('Error during OTP verification: $e');
    return false; // Return false in case of an error
  }
}
