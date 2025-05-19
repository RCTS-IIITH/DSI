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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class CreateProfessionalAccount extends StatefulWidget {
  const CreateProfessionalAccount({super.key});

  @override
  _CreateProfessionalAccountState createState() =>
      _CreateProfessionalAccountState();
}

class _CreateProfessionalAccountState extends State<CreateProfessionalAccount>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _professionalIdController =
      TextEditingController();

  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _professionalIdController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-professional'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'Number': _phoneController.text.trim(), // Uppercase to match backend
          'Address': _addressController.text.trim(), // Uppercase
          'ProfessionalID': _professionalIdController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? "Validation failed");
      } else {
        _showErrorDialog("Failed to create account. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Professional account created successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const NGODashboard(data: ''),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentUserDetails = await SharedPrefsHelper.getUserDetails();
        final currentAdminPhone =
            currentUserDetails['phoneNumber'] ?? 'Unknown';

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => NGODashboard(data: currentAdminPhone)),
          (route) => false,
        );
        return false;
      },
      child: FadeTransition(
        opacity: _animationController,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue, // Match your app style
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                final currentUserDetails =
                    await SharedPrefsHelper.getUserDetails();
                final currentAdminPhone =
                    currentUserDetails['phoneNumber'] ?? 'Unknown';

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NGODashboard(data: currentAdminPhone)),
                  (route) => false,
                );
              },
            ),
            title: Text("Create Professional Account"),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create Professional Account",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration("Name *"),
                      validator: (value) =>
                          value?.isEmpty == true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("Phone Number *"),
                      validator: (value) =>
                          value?.isEmpty == true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration("Address *"),
                      validator: (value) =>
                          value?.isEmpty == true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _professionalIdController,
                      decoration: _inputDecoration("Professional ID *"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Professional ID is required";
                        }
                        if (!value.startsWith("PROF-")) {
                          return "Professional ID must start with 'PROF-'";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, child) {
                        return Opacity(
                          opacity: _isLoading ? 0.5 : 1,
                          child: child!,
                        );
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createAccount,
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.engineering),
                          label: Text(
                            _isLoading
                                ? "Creating..."
                                : "Create Professional Account",
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
