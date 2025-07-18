// import 'package:flutter/material.dart';
// import 'package:mindseye/NGOdashboard.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// // import 'package:mindseye/session_manager.dart';

// class NgoLoginScreen extends StatefulWidget {
//   @override
//   _NgoLoginScreenState createState() => _NgoLoginScreenState();
// }

// class _NgoLoginScreenState extends State<NgoLoginScreen> {
//   // Controllers for email and password
//   final TextEditingController _numberController = TextEditingController();

//   // State for "Remember Me" toggle
//   bool _rememberMe = false;
//   bool _isLoading = false;


//   Future<void> _login() async {
//     final String number = _numberController.text;
//     // final String password = _passwordController.text;

//     // API URL
//     const String url = 'http://localhost:3000/api/products/login';

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Send POST request
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'number':number
//         }),
//       );

//       // Handle the response
//       // print("hello bete");
//       // print({response.});
//       print('${response.body}');
//       // print('${response.body.password}');

//       if (response.statusCode == 200) {
//         // final responseData = json.decode(response.body);
//         print('Login Successful: $response');
//         // final responseData = json.decode(response.body);
//         // await SessionManager.createLoginSession(
//         //   email: email,
//         //   password: password,
//         //   rememberMe: _rememberMe,
//         // );

//         // Navigate to Dashboard
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => NGODashboard()),
//         );
//       } else {
//         // Handle error
//         final responseData = json.decode(response.body);
//         print('Error: ${responseData['message']}');
//         _showErrorDialog('Login failed. Please check your credentials.');
//       }
//     } catch (e) {
//       print('Error: $e');
//       _showErrorDialog('An error occurred. Please try again.');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//     // return "kevin ";
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
//               // Title
//               Text(
//                 'NGO Login',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 30),

//               // Email Field
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   labelText: 'Email or Mobile No.',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               SizedBox(height: 20),

//               // Password Field
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   suffixIcon: Icon(Icons.visibility), // Eye icon
//                 ),
//                 obscureText: true,
//               ),
//               SizedBox(height: 20),

//               // Remember Me toggle
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Switch(
//                         value: _rememberMe,
//                         onChanged: (bool value) {
//                           setState(() {
//                             _rememberMe = value;
//                           });
//                         },
//                       ),
//                       Text('Remember Me'),
//                     ],
//                   ),
//                 ],
//               ),

//               SizedBox(height: 20),

//               // Login Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Handle login action here
//                     print('Email: ${_emailController.text}');
//                     print('Password: ${_passwordController.text}');
//                     print('Remember Me: $_rememberMe');

//                     Navigator.push(context, MaterialPageRoute(builder: (context) => NGODashboard()));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Text(
//                     'Login',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Forgot Password
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     // Navigate to Forgot Password screen
//                   },
//                   child: Text(
//                     'Forgot Password?',
//                     style: TextStyle(
//                       color: Colors.black,
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

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
