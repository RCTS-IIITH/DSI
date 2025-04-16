// import 'package:flutter/material.dart';
// import 'package:mindseye/NGOdashboard.dart';
// import 'package:http/http.dart' as http;

// class CreateProfessionalAccount extends StatefulWidget {
//   @override
//   _CreateProfessionalAccountState createState() =>
//       _CreateProfessionalAccountState();
// }

// class _CreateProfessionalAccountState extends State<CreateProfessionalAccount> {
//   bool _isPasswordVisible = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 40), // Space from top
//               Text(
//                 'Create Professional Account',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 32), // Space below title
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Name *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 32), // Space below title
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               SizedBox(height: 32), // Space below title
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Address *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               // SizedBox(height: 16),
//               // TextField(
//               //   decoration: InputDecoration(
//               //     labelText: 'Professional ID *',
//               //     filled: true,
//               //     fillColor: Colors.grey[200],
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(12),
//               //       borderSide: BorderSide.none,
//               //     ),
//               //   ),
//               // ),
//               // SizedBox(height: 16),
//               // TextField(
//               //   obscureText: !_isPasswordVisible,
//               //   decoration: InputDecoration(
//               //     labelText: 'Password *',
//               //     filled: true,
//               //     fillColor: Colors.grey[200],
//               //     border: OutlineInputBorder(
//               //       borderRadius: BorderRadius.circular(12),
//               //       borderSide: BorderSide.none,
//               //     ),
//               //     suffixIcon: IconButton(
//               //       icon: Icon(
//               //         _isPasswordVisible
//               //             ? Icons.visibility
//               //             : Icons.visibility_off,
//               //       ),
//               //       onPressed: () {
//               //         setState(() {
//               //           _isPasswordVisible = !_isPasswordVisible;
//               //         });
//               //       },
//               //     ),
//               //   ),
//               // ),
//               SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle Create Professional Account logic here

//                     final uri = Uri.parse(
//                         'http://localhost:3000/api/users/create-professional');
//                     http.post(uri, body: {
//                       'name': 'John Doe',
//                       'phone': '1234567890',
//                       'address': '123, Main Street',
//                     });

//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => NGODashboard(),
//                       ),
//                       (Route<dynamic> route) =>
//                           false, // This condition removes all previous routes
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Create Professional Account',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';

class CreateProfessionalAccount extends StatefulWidget {
  const CreateProfessionalAccount({super.key});

  @override
  _CreateProfessionalAccountState createState() =>
      _CreateProfessionalAccountState();
}

class _CreateProfessionalAccountState extends State<CreateProfessionalAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _professionalIdController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _professionalIdController.dispose();
    super.dispose();
  }

  void _showDialog(String title, String content, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NGODashboard(data: ''),
                  ),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _createAccount() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _professionalIdController.text.isEmpty) {
      _showDialog("Error", "Please fill in all required fields.");
      return;
    }

    final uri =
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-professional');

    final response = await http.post(uri, body: {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'professionalId': _professionalIdController.text,
    });

    if (response.statusCode == 200) {
      _showDialog("Success", "Account Created Successfully!", isSuccess: true);
    } else {
      _showDialog("Error", "Failed to create account. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Create Professional Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _professionalIdController,
                decoration: InputDecoration(
                  labelText: 'Professional ID *',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Professional Account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
