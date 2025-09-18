// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mindseye/question.dart';
// import 'package:mindseye/shared_prefs_helper.dart';
// import 'package:http/http.dart' as http;
// import 'package:confetti/confetti.dart'; // ← Add this

// class CaptureDrawingScreen extends StatefulWidget {
//   final String clinicName;
//   final String childName;
//   final String age;
//   final String notes;
//   final String labeledScore;
//   final String data; // "Professional", "Parent", "Teacher"
//   final String? phoneNumber;

//   const CaptureDrawingScreen({
//     super.key,
//     this.clinicName = '',
//     this.childName = '',
//     this.age = '',
//     this.notes = '',
//     this.labeledScore = '',
//     required this.data,
//     this.phoneNumber,
//   });

//   @override
//   _CaptureDrawingScreenState createState() => _CaptureDrawingScreenState();
// }

// class _CaptureDrawingScreenState extends State<CaptureDrawingScreen> {
//   File? _houseImage;
//   File? _treeImage;
//   File? _personImage;
//   String clinicName = '';
//   bool _confettiShown = false;

//   // Confetti Controller
//   late ConfettiController _confettiController;

//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(duration: Duration(seconds: 3));
//     SharedPrefsHelper.getUserDetails().then((details) {
//       if (mounted) {
//         setState(() {
//           clinicName = details['clinicName'] ?? '';
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose(); // Important: avoid memory leaks
//     super.dispose();
//   }

//   Future<void> _pickHouseImage(ImageSource source) async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _houseImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       print('Error picking house image: $e');
//       String errorMessage = "Failed to capture/upload house image.";
//       if (e.toString().contains("cameraDelegate")) {
//         errorMessage =
//             "Camera permission not granted. Please use gallery upload instead.";
//       }
//       _showError("Error", errorMessage);
//     }
//   }

//   Future<void> _pickTreeImage(ImageSource source) async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _treeImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       print('Error picking tree image: $e');
//       String errorMessage = "Failed to capture/upload tree image.";
//       if (e.toString().contains("cameraDelegate")) {
//         errorMessage =
//             "Camera permission not granted. Please use gallery upload instead.";
//       }
//       _showError("Error", errorMessage);
//     }
//   }

//   Future<void> _pickPersonImage(ImageSource source) async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _personImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       print('Error picking person image: $e');
//       String errorMessage = "Failed to capture/upload person image.";
//       if (e.toString().contains("cameraDelegate")) {
//         errorMessage =
//             "Camera permission not granted. Please use gallery upload instead.";
//       }
//       _showError("Error", errorMessage);
//     }
//   }

//   void _showError(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allCaptured =
//         _houseImage != null && _treeImage != null && _personImage != null;

//     // Trigger confetti once when all images are captured
//     if (allCaptured && !_confettiShown) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           setState(() {
//             _confettiShown = true;
//           });
//           _confettiController.play(); // Launch confetti
//         }
//       });
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Capture Drawings',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline, color: Colors.black54),
//             tooltip: 'How to capture drawings',
//             onPressed: () {
//               _showCaptureInstructions(context);
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Main scrollable content
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (widget.data == "Professional") ...[
//                     Text('Clinic Name: $clinicName',
//                         style: const TextStyle(fontSize: 16)),
//                     Text('Child Name: ${widget.childName}',
//                         style: const TextStyle(fontSize: 16)),
//                     Text('Age: ${widget.age}',
//                         style: const TextStyle(fontSize: 16)),
//                     Text('Notes: ${widget.notes}',
//                         style: const TextStyle(fontSize: 16)),
//                     Text('Labeled Score: ${widget.labeledScore}',
//                         style: const TextStyle(fontSize: 16)),
//                     const SizedBox(height: 16),
//                   ],
//                   _buildImageSection(
//                     title: "House Drawing",
//                     image: _houseImage,
//                     onCapture: () => _pickHouseImage(ImageSource.camera),
//                     onUpload: () => _pickHouseImage(ImageSource.gallery),
//                     onRetake: () => _pickHouseImage(ImageSource.camera),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildImageSection(
//                     title: "Tree Drawing",
//                     image: _treeImage,
//                     onCapture: () => _pickTreeImage(ImageSource.camera),
//                     onUpload: () => _pickTreeImage(ImageSource.gallery),
//                     onRetake: () => _pickTreeImage(ImageSource.camera),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildImageSection(
//                     title: "Person Drawing",
//                     image: _personImage,
//                     onCapture: () => _pickPersonImage(ImageSource.camera),
//                     onUpload: () => _pickPersonImage(ImageSource.gallery),
//                     onRetake: () => _pickPersonImage(ImageSource.camera),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: allCaptured
//                           ? () async {
//                               Map<String, String> selectedChildDetails = {};
//                               String finalChildName = '';
//                               String finalAge = '';

//                               if (widget.data == "Professional") {
//                                 finalChildName = widget.childName;
//                                 finalAge = widget.age;
//                               } else {
//                                 selectedChildDetails = await SharedPrefsHelper
//                                     .getSelectedChildDetails();
//                                 finalChildName =
//                                     selectedChildDetails['name'] ?? '';
//                                 finalAge = selectedChildDetails['age'] ?? '';
//                               }

//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => QuestionsScreen(
//                                     clinicName: widget.data == "Professional"
//                                         ? widget.clinicName
//                                         : "",
//                                     childName: finalChildName,
//                                     age: finalAge,
//                                     notes: widget.notes,
//                                     labeledScore: widget.labeledScore,
//                                     houseImage: _houseImage!,
//                                     treeImage: _treeImage!,
//                                     personImage: _personImage!,
//                                     data: '',
//                                   ),
//                                 ),
//                               );
//                             }
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             allCaptured ? Colors.black : Colors.grey,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Confirm',
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Please ensure all three drawings are captured before proceeding.',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),

//           // ✨ Confetti Layer (on top)
//           if (_confettiShown)
//             ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirectionality: BlastDirectionality.explosive,
//               shouldLoop: false,
//               maxBlastForce: 10,
//               minBlastForce: 5,
//               emissionFrequency: 0.05,
//               numberOfParticles: 20,
//               gravity: 0.1,
//             ),
//         ],
//       ),
//     );
//   }

//   void _showCaptureInstructions(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text(
//           "📸 How to Capture Drawings",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "Please follow these guidelines for best results:",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 12),
//               _buildInstruction("✅ Clear Image",
//                   "Make sure the drawing is in focus and not blurry."),
//               _buildInstruction("✅ Full Page",
//                   "Capture the entire drawing within the frame."),
//               _buildInstruction("✅ Good Lighting",
//                   "Avoid shadows or glare. Use natural light if possible."),
//               _buildInstruction("✅ Flat Surface",
//                   "Place the paper on a flat surface while capturing."),
//               _buildInstruction(
//                   "✅ No Folds", "Ensure the paper is not folded or crumpled."),
//               _buildInstruction("✅ No Filters",
//                   "Do not apply filters or edits to the photo."),
//               const SizedBox(height: 16),
//               const Text(
//                 "Tip: Hold the device directly above the drawing for best angle.",
//                 style: TextStyle(
//                     fontSize: 14,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.blueGrey),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Got it!", style: TextStyle(color: Colors.blue)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInstruction(String title, String description) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.green),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             description,
//             style: const TextStyle(fontSize: 14, height: 1.4),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageSection({
//     required String title,
//     required File? image,
//     required VoidCallback onCapture,
//     required VoidCallback onUpload,
//     required VoidCallback onRetake,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             height: 120,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: image != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(image, fit: BoxFit.cover),
//                   )
//                 : const Center(
//                     child: Text(
//                       'No Image Selected',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: image == null ? onCapture : onRetake,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: image == null ? Colors.black : Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     image == null ? 'Capture' : 'Retake',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: onUpload,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'Upload',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Note: If camera fails, use gallery upload',
//             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindseye/question.dart'; // QuestionsScreen
import 'package:mindseye/shared_prefs_helper.dart';
import 'package:http/http.dart' as http;

class CaptureDrawingScreen extends StatefulWidget {
  final String clinicName;
  final String childName;
  final String age;
  final String notes;
  final String labeledScore;
  final String data; // Role: "Professional", "Parent", "Teacher"
  final String? phoneNumber;

  const CaptureDrawingScreen({
    super.key,
    this.clinicName = '',
    this.childName = '',
    this.age = '',
    this.notes = '',
    this.labeledScore = '',
    required this.data,
    this.phoneNumber,
  });

  @override
  _CaptureDrawingScreenState createState() => _CaptureDrawingScreenState();
}

class _CaptureDrawingScreenState extends State<CaptureDrawingScreen> {
  File? _houseImage;
  File? _treeImage;
  File? _personImage;
  String clinicName = '';

  @override
  void initState() {
    super.initState();
    SharedPrefsHelper.getUserDetails().then((details) {
      if (mounted) {
        setState(() {
          clinicName = details['clinicName'] ?? '';
        });
      }
    });
  }

  Future<void> _pickHouseImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _houseImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking house image: $e');
      String errorMessage = "Failed to capture/upload house image.";
      if (e.toString().contains("cameraDelegate")) {
        errorMessage =
            "Camera permission not granted. Please use gallery upload instead.";
      }
      _showError("Error", errorMessage);
    }
  }

  Future<void> _pickTreeImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _treeImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking tree image: $e');
      String errorMessage = "Failed to capture/upload tree image.";
      if (e.toString().contains("cameraDelegate")) {
        errorMessage =
            "Camera permission not granted. Please use gallery upload instead.";
      }
      _showError("Error", errorMessage);
    }
  }

  Future<void> _pickPersonImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        setState(() {
          _personImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking person image: $e');
      String errorMessage = "Failed to capture/upload person image.";
      if (e.toString().contains("cameraDelegate")) {
        errorMessage =
            "Camera permission not granted. Please use gallery upload instead.";
      }
      _showError("Error", errorMessage);
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Capture Drawings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Info Icon Button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black54),
            tooltip: 'How to capture drawings',
            onPressed: () {
              _showCaptureInstructions(context);
            },
          ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conditionally display professional-specific fields
              if (widget.data == "Professional") ...[
                Text('Clinic Name: $clinicName',
                    style: const TextStyle(fontSize: 16)),
                Text('Child Name: ${widget.childName}',
                    style: const TextStyle(fontSize: 16)),
                Text('Age: ${widget.age}',
                    style: const TextStyle(fontSize: 16)),
                Text('Notes: ${widget.notes}',
                    style: const TextStyle(fontSize: 16)),
                Text('Labeled Score: ${widget.labeledScore}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
              ],

              // House Image Section
              _buildImageSection(
                title: "House Drawing",
                image: _houseImage,
                onCapture: () => _pickHouseImage(ImageSource.camera),
                onUpload: () => _pickHouseImage(ImageSource.gallery),
                onRetake: () => _pickHouseImage(ImageSource.camera),
              ),

              const SizedBox(height: 16),

              // Tree Image Section
              _buildImageSection(
                title: "Tree Drawing",
                image: _treeImage,
                onCapture: () => _pickTreeImage(ImageSource.camera),
                onUpload: () => _pickTreeImage(ImageSource.gallery),
                onRetake: () => _pickTreeImage(ImageSource.camera),
              ),

              const SizedBox(height: 16),

              // Person Image Section
              _buildImageSection(
                title: "Person Drawing",
                image: _personImage,
                onCapture: () => _pickPersonImage(ImageSource.camera),
                onUpload: () => _pickPersonImage(ImageSource.gallery),
                onRetake: () => _pickPersonImage(ImageSource.camera),
              ),

              const SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_houseImage != null &&
                          _treeImage != null &&
                          _personImage != null)
                      ? () async {
                          Map<String, String> selectedChildDetails = {};
                          String finalChildName = '';
                          String finalAge = '';

                          if (widget.data == "Professional") {
                            finalChildName = widget.childName;
                            finalAge = widget.age;
                            print(
                                'Professional Mode - Using passed details: $finalChildName, Age: $finalAge');
                          } else {
                            selectedChildDetails = await SharedPrefsHelper
                                .getSelectedChildDetails();
                            finalChildName = selectedChildDetails['name'] ?? '';
                            finalAge = selectedChildDetails['age'] ?? '';
                            print(
                                'Parent/Teacher Mode - Using stored details: $finalChildName, Age: $finalAge');
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionsScreen(
                                clinicName: widget.data == "Professional"
                                    ? widget.clinicName
                                    : "",
                                childName: finalChildName,
                                age: finalAge,
                                notes: widget.notes,
                                labeledScore: widget.labeledScore,
                                data: widget.data,
                                //phoneNumber: widget.phoneNumber,
                                houseImage: _houseImage!,
                                treeImage: _treeImage!,
                                personImage: _personImage!,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_houseImage != null &&
                            _treeImage != null &&
                            _personImage != null)
                        ? Colors.black
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please ensure all three drawings are captured before proceeding.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCaptureInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "📸 How to Capture Drawings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Please follow these guidelines for best results:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildInstruction("✅ Clear Image",
                  "Make sure the drawing is in focus and not blurry."),
              _buildInstruction("✅ Full Page",
                  "Capture the entire drawing within the frame."),
              _buildInstruction("✅ Good Lighting",
                  "Avoid shadows or glare. Use natural light if possible."),
              _buildInstruction("✅ Flat Surface",
                  "Place the paper on a flat surface while capturing."),
              _buildInstruction(
                  "✅ No Folds", "Ensure the paper is not folded or crumpled."),
              _buildInstruction("✅ No Filters",
                  "Do not apply filters or edits to the photo."),
              const SizedBox(height: 16),
              const Text(
                "Tip: Hold the device directly above the drawing for best angle.",
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it!", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

// Helper to build each instruction
  Widget _buildInstruction(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection({
    required String title,
    required File? image,
    required VoidCallback onCapture,
    required VoidCallback onUpload,
    required VoidCallback onRetake,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : const Center(
                    child: Text(
                      'No Image Selected',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: image == null ? onCapture : onRetake,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: image == null ? Colors.black : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    image == null ? 'Capture' : 'Retake',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: onUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upload',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Note: If camera fails, use gallery upload',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
