import 'package:flutter/material.dart';
import 'package:mindseye/reportDetails.dart';

class LabelPreviousDataScreen extends StatefulWidget {
  @override
  _LabelPreviousDataScreenState createState() =>
      _LabelPreviousDataScreenState();
}

class _LabelPreviousDataScreenState extends State<LabelPreviousDataScreen> {
  final List<String> reportIds = [
    '982744',
    '73744',
    '87284',
    '23434',
    '983749',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Label Previous Data',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reportIds.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add action for report button press
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReportDetailsScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Report ID: ${reportIds[index]}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
