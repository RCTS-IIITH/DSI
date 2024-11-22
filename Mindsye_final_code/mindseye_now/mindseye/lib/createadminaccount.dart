import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:mindseye/NGOdashboard.dart';

class CreateAdminAccountScreen extends StatefulWidget {
  @override
  _CreateAdminAccountScreenState createState() =>
      _CreateAdminAccountScreenState();
}

class _CreateAdminAccountScreenState extends State<CreateAdminAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createAdminAccount() async {
    // Implement account creation logic
    final name = _nameController.text;
    final phone = _phoneController.text;
    // final email = _emailController.text;

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the fields'),
        ),
      );
      return;
    }
    String backendUrl = dotenv.env['BACKEND_URL']!;
    // final uri = Uri.parse('http://localhost:3000/api/users/create-ngo-admin');
    final uri = Uri.parse('${backendUrl}/api/users/create-ngo-admin');
    print(uri);

    // Send a POST request to the server
    await http.post(uri, body: {
      'name': name,
      'phone': phone,
      // 'email': email,
    });

    Navigator.pop(context);
    // You can use these variables to send data to the server or perform other actions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Admin Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              // SizedBox(height: 16),
              // TextField(
              //   controller: _emailController,
              //   decoration: InputDecoration(
              //     labelText: 'Email *',
              //     filled: true,
              //     fillColor: Colors.grey[200],
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //       borderSide: BorderSide.none,
              //     ),
              //   ),
              // ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _createAdminAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Create Admin Account',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
