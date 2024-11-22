import 'package:flutter/material.dart';
import 'package:mindseye/captureDrawing.dart';

class SelectChildScreen extends StatefulWidget {
  final String data;

  const SelectChildScreen({Key? key, required this.data}) : super(key: key);

  @override
  _SelectChildScreenState createState() => _SelectChildScreenState();
}

class _SelectChildScreenState extends State<SelectChildScreen> {
  String? selectedChild; // Variable to store the selected child
  final List<String> children = ['Child A', 'Child B', 'Child C', 'Child D']; // Sample list of children
  final FocusNode dropdownFocusNode = FocusNode(); // Focus node for the dropdown field

  @override
  void dispose() {
    dropdownFocusNode.dispose(); // Dispose focus node to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust layout when the keyboard appears
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true, // Ensures the last field stays visible while typing
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Child',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  focusNode: dropdownFocusNode, // Attach the focus node
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: Text('Select Child'),
                  value: selectedChild,
                  items: children
                      .map((child) => DropdownMenuItem(
                            value: child,
                            child: Text(child),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedChild = value; // Update selected child
                    });
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedChild != null
                        ? () {
                            // Action when "Proceed" is pressed
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CaptureDrawingScreen(
                                  data: widget.data,
                                  clinicName: '',
                                  childName: '',
                                  age: '',
                                  notes: '',
                                  labeledScore: '',
                                ),
                              ),
                            );
                            print('Selected child: $selectedChild');
                          }
                        : null, // Disable button if no child is selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Proceed',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
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
