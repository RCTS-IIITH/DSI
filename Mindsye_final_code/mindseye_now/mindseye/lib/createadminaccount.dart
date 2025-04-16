import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CreateAdminAccountScreen extends StatefulWidget {
  const CreateAdminAccountScreen({super.key});

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

  /// Show alert dialog with optional navigation on success
  void _showDialog(String title, String content, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the alert
              if (isSuccess) {
                Navigator.pop(context); // Go back after success
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Create admin account and handle responses
  Future<void> _createAdminAccount() async {
    final name = _nameController.text;
    final phone = _phoneController.text;

    if (name.isEmpty || phone.isEmpty) {
      _showDialog("Error", "Please fill all the fields");
      return;
    }

    String? backendUrl = dotenv.env['BACKEND_URL'];
    if (backendUrl == null || backendUrl.isEmpty) {
      _showDialog("Error", "Backend URL is not configured.");
      return;
    }

    final uri = Uri.parse('$backendUrl/api/users/create-ngo-admin');

    try {
      final response = await http.post(uri, body: {
        'name': name,
        'phone': phone,
      });

      if (response.statusCode == 200) {
        _showDialog("Success", "Admin account created successfully!",
            isSuccess: true);
      } else {
        _showDialog("Error", "Failed to create account. Please try again.");
      }
    } catch (e) {
      _showDialog("Error", "Network error: Unable to connect to the server.");
    }
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
              const Text(
                'Create Admin Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
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
                  child: const Text(
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
