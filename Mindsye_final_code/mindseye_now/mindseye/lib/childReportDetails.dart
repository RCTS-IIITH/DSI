// // Copyright 2024 Umang Patel
// //
// // Licensed under the Apache License, Version 2.0 (the "License");
// // you may not use this file except in compliance with the License.
// // You may obtain a copy of the License at
// //
// //     https://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing, software
// // distributed under the License is distributed on an "AS IS" BASIS,
// // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// // See the License for the specific language governing permissions and
// // limitations under the License.

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:mindseye/labelDataScreen.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ChildReport extends StatefulWidget {
//   final String data;

//   const ChildReport({
//     Key? key,
//     required this.data,
//   }) : super(key: key);

//   @override
//   _ChildReportState createState() => _ChildReportState();
// }

// class _ChildReportState extends State<ChildReport> {
//   // final String reportId = '123456';
//   // final String name = 'Student C';
//   // final int age = 13;
//   // final int rollNumber = 345678;
//   // final int score = 87;
//   // final List<String> answers = [
//   //   'Answer to first question',
//   //   'Answer to second question',
//   //   'Answer to third question',
//   // ];

//   String reportId = '';
//   String name = '';
//   int age = 0;
//   int rollNumber = 0;
//   int score = 0;
//   List<String> answers = [];

//   String backendUrl = dotenv.env['BACKEND_URL']!;

//   Future<void> getReportData() async {
//     print(widget.data);

//     final uri = Uri.parse(
//         '$backendUrl/api/reports/get-report-data-clinic/${widget.data}');
//     final response = await http.get(uri);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);

//       print(data);
//       setState(() {
//         reportId = data['_id'];
//         name = data['childsName'];
//         age = data['age'];
//         rollNumber = data['rollNumber'] == null ? 0 : data['rollNumber'];
//         score = data['score'] == null ? "N/A" : data['score'];
//         answers = [
//           // data['answer1'],
//           // data['answer2'],
//           // data['answer3'],
//           data['answer1'] == null ? "N/A" : data['answer1'],
//           data['answer2'] == null ? "N/A" : data['answer2'],
//           data['answer3'] == null ? "N/A" : data['answer3'],
//         ];
//       });
//     } else {
//       print('Failed to load report data');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         toolbarHeight: 50,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Report ID: $reportId',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Name: $name',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Age: $age',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               'Roll Number: $rollNumber',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 16),
//             Container(
//               padding: EdgeInsets.all(16.0),
//               color: Colors.grey[200],
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Score: $score',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Brief Summary',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Answer 1: ${answers[0]}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     'Answer 2: ${answers[1]}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   Text(
//                     'Answer 3: ${answers[2]}',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ],
//               ),
//             ),
//             Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/labelDataScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChildReport extends StatefulWidget {
  final String data; // The student ID passed from ReportsDashboardScreen

  const ChildReport({
    Key? key,
    required this.data, // Receive student ID in constructor
  }) : super(key: key);

  @override
  _ChildReportState createState() => _ChildReportState();
}

class _ChildReportState extends State<ChildReport> {
  String reportId = '';
  String name = '';
  String age = '';
  String rollNumber = '';
  String score = '';
  List<String> answers = [];
  // final String reportId = '123456';
  // final String name = 'Student C';
  // final int age = 13;
  // final int rollNumber = 345678;
  // final int score = 87;
  // final List<String> answers = [
  //   'Answer to first question',
  //   'Answer to second question',
  //   'Answer to third question',
  // ];


  String backendUrl = dotenv.env['BACKEND_URL']!;

  @override
  void initState() {
    super.initState();
    getReportData(); // Call the function to fetch report data
  }

  // Fetch report data based on student ID passed to the widget
  Future<void> getReportData() async {
    print('Fetching data for student ID: ${widget.data}');

    final uri = Uri.parse(
        '$backendUrl/api/reports/get-report-data-clinic/${widget.data}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Data fetched: $data');

      setState(() {
        reportId = data['_id'] ?? '';
        name = data['childsName'] ?? 'N/A';
        age = data['age'] ?? 'N/A';
        rollNumber = data['rollNumber'] ?? 'N/A';
        score = data['score'] ?? 'N/A';
        answers = [
          data['answer1'] ?? 'N/A', // Handle null answers gracefully
          data['answer2'] ?? 'N/A',
          data['answer3'] ?? 'N/A',
        ];
      });
    } else {
      print('Failed to load report data');
      // Handle failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 50,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report ID: $reportId',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: $name',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Age: $age',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Roll Number: $rollNumber',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: $score',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Brief Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Answer 1: ${answers[0]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Answer 2: ${answers[1]}',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Answer 3: ${answers[2]}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
