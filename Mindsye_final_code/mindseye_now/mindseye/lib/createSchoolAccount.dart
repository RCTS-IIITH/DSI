// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:mindseye/NGOdashboard.dart';
// import 'package:http/http.dart' as http;

// class CreateSchoolAccount extends StatefulWidget {
//   @override
//   _CreateSchoolAccountState createState() => _CreateSchoolAccountState();
// }

// class _CreateSchoolAccountState extends State<CreateSchoolAccount> {
//   bool _isPasswordVisible = false;
//   String? _selectedProfessionalId; // Stores the selected value

//   // List of options for Assigned Professional ID
//   // final List<String> _professionalIds = [
//   //   'Professional 1',
//   //   'Professional 2',
//   //   'Professional 3',
//   //   'Professional 4',
//   // ];

//   List<String> _professionalIds = [];

//   final uri = Uri.parse('http://localhost:3000/api/users/getProfessionalIds');

//   Future<void> getProfessionalIds() async {
//     try {
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         final List<String> professionalIds = [];
//         print(response.body);
//         final List<dynamic> data = json.decode(response.body);
//         print(data);
//         for (var i = 0; i < data.length; i++) {
//           final String display = data[i]["name"] + ' (' + data[i]["ProfessionalID"] + ')';
//           professionalIds.add(display);
//         }
//         setState(() {
//           _professionalIds = professionalIds;
//         });
//       } else {
//         print('Failed to load professional IDs');
//       }
//     } catch (e) {
//       print('Error loading professional IDs: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getProfessionalIds();
//   }

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
//                 'Create School Account',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 32), // Space below title
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'School Name *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
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
//               SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'School UDISE Number *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedProfessionalId,
//                 items: _professionalIds
//                     .map((id) => DropdownMenuItem<String>(
//                           value: id,
//                           child: Text(id),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedProfessionalId = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Assigned Professional ID *',
//                   filled: true,
//                   fillColor: Colors.grey[200],
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_selectedProfessionalId != null) {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => NGODashboard(),
//                         ),
//                         (Route<dynamic> route) =>
//                             false, // Removes all previous routes
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Please select a professional ID'),
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'Create School Account',
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

class CreateSchoolAccount extends StatefulWidget {
  const CreateSchoolAccount({super.key});

  @override
  _CreateSchoolAccountState createState() => _CreateSchoolAccountState();
}

class _CreateSchoolAccountState extends State<CreateSchoolAccount>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProfessionalId;
  late AnimationController _animationController;

  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _udiseNumberController = TextEditingController();

  List<Map<String, dynamic>> _professionals = [];

  bool _isLoading = false;
  bool _isProfessionalLoading = false;

  String get backendUrl => dotenv.env['BACKEND_URL'] ?? "";

  final Uri _fetchUri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/getProfessionalIds');
  final Uri _submitUri =
      Uri.parse('${dotenv.env['BACKEND_URL']}/api/users/create-school');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    getProfessionalIds();
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _addressController.dispose();
    _udiseNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getProfessionalIds() async {
    setState(() => _isProfessionalLoading = true);
    try {
      final response = await http.get(_fetchUri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          _professionals =
              data.map((item) => item as Map<String, dynamic>).toList();
          _animationController.forward();
        });
      } else {
        _showSnackBar("Failed to load professional IDs");
      }
    } catch (e) {
      _showSnackBar("Error fetching professionals: $e");
    } finally {
      setState(() => _isProfessionalLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> createSchoolAccount() async {
    if (_formKey.currentState?.validate() != true ||
        _selectedProfessionalId == null) {
      _showSnackBar("Please fill all required fields.");
      return;
    }

    setState(() => _isLoading = true);

    final String professionalId =
        _selectedProfessionalId!.split('(').last.replaceAll(')', '').trim();

    try {
      final response = await http.post(
        _submitUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schoolName': _schoolNameController.text.trim(),
          'address': _addressController.text.trim(),
          'UDISE': _udiseNumberController.text.trim(),
          'assignedProfessional': professionalId,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("School account created successfully!");
        _resetForm();

        // ✅ Redirect to NGODashboard with animation
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                NGODashboard(data: _schoolNameController.text),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showSnackBar(error['message'] ?? "Validation failed");
      } else {
        _showSnackBar("Failed to create school account");
      }
    } catch (e) {
      _showSnackBar("Network error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _schoolNameController.clear();
    _addressController.clear();
    _udiseNumberController.clear();
    setState(() => _selectedProfessionalId = null);
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue, // Match SchoolLoginScreen style
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
          title: Text("Create School Account"),
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
                    'Create School Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _schoolNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration("School Name *"),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration("Address *"),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _udiseNumberController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("UDISE Number *"),
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Required';
                      if (value!.length != 11) return 'UDISE must be 11 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: _animationController,
                      child: DropdownButtonFormField<String>(
                        value: _selectedProfessionalId,
                        items: _professionals.map((p) {
                          final display =
                              "${p["name"]} (${p["ProfessionalID"]})";
                          return DropdownMenuItem(
                            value: display,
                            child: Text(display),
                          );
                        }).toList(),
                        onChanged: _isProfessionalLoading || _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedProfessionalId = value;
                                });
                              },
                        decoration:
                            _inputDecoration("Assigned Professional ID *"),
                        validator: (value) =>
                            value == null ? 'Please select one' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isLoading ? 0.5 : 1,
                        child: child!,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() == true &&
                                    _selectedProfessionalId != null) {
                                  createSchoolAccount();
                                } else {
                                  _showSnackBar(
                                      "Please complete all required fields");
                                }
                              },
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : Icon(Icons.school),
                        label: Text(
                          _isLoading ? "Creating..." : "Create School Account",
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
    );
  }
}
