import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/NGOdashboard.dart';
import 'package:mindseye/NGOmobileLogin.dart';
import 'package:mindseye/assignadmintoschool.dart';
import 'package:mindseye/captureDrawing.dart';
import 'package:mindseye/childReportDetails.dart';
import 'package:mindseye/createProfessionalAccount.dart';
import 'package:mindseye/createSchoolAccount.dart';
import 'package:mindseye/createadminaccount.dart';
import 'package:mindseye/labelDataScreen.dart';
import 'package:mindseye/labelPreviousData.dart';
import 'package:mindseye/parentDashboard.dart';
import 'package:mindseye/previousSubmission.dart';
import 'package:mindseye/professionalDashboard.dart';
import 'package:mindseye/professionalLogin.dart';
import 'package:mindseye/question.dart';
import 'package:mindseye/reportAnalysis.dart';
import 'package:mindseye/reportDetails.dart';
import 'package:mindseye/reportsDashboard.dart';
import 'package:mindseye/schoolAdminLogin.dart';
import 'package:mindseye/schoolDashboard.dart';
import 'package:mindseye/schoolLogin.dart';
import 'package:mindseye/schoolScreen.dart';
import 'package:mindseye/schoolsAnalysis.dart';
import 'package:mindseye/selectChild.dart';
import 'package:mindseye/studentReport.dart';
import 'package:mindseye/submissionStatus.dart';
import 'package:mindseye/tagImage.dart';
import 'package:mindseye/tagImageManuaaly.dart';
import 'package:mindseye/uploadChildDetails.dart';
import 'package:mindseye/uploadTeacherDetails.dart';
import 'adminDahboard.dart';
import 'login.dart'; // Import LoginScreen from login.dart

Future<void> envLoader() async {
  await dotenv.load(fileName: ".env");
}

void main() {
  envLoader();
  runApp(MyApp());
}

// Create a ValueNotifier to manage theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          initialRoute: 'login',
          debugShowCheckedModeBanner: false,
          routes: {
            'login': (context) => LoginScreen(),
            'schoolLogin': (context) => SchoolLoginScreen(),
            'professionalLogin': (context) => ProfessionalLoginScreen(),
            'NGOmobileLogin': (context) => const MobileNumberScreen(data: ''),
            'schoolScreen': (context) => SchoolsScreen(),
            'createSchoolAccount': (context) => CreateSchoolAccount(),
            'createProfessionalAccount': (context) =>
                CreateProfessionalAccount(),
            'schoolDashboard': (context) => SchoolDashboardScreen(data: ''),
            'professionalDashboard': (context) =>
                ProfessionalDashboard(data: ''),
            'NGOdashboard': (context) => NGODashboard(data: ''),
            'reportsDashboard': (context) => ReportsDashboardScreen(),
            'labelData': (context) => LabelDataScreen(
                  reportId: '',
                ),
            'labelPreviousData': (context) => LabelPreviousDataScreen(),
            'reportDetails': (context) => ReportDetailsScreen(
                  reportId: '',
                ),
            'reportAnalysis': (context) => ReportAnalysisScreen(),
            'studentReport': (context) => StudentReportScreen(),
            'submissionStatus': (context) => SubmissionStatusScreen(),
            'tagImage': (context) => TagImageScreen(),
            'captureDrawing': (context) => CaptureDrawingScreen(
                  data: '',
                  clinicName: '',
                  childName: '',
                  age: '',
                  notes: '',
                  labeledScore: '',
                ),
            'question': (context) => QuestionsScreen(
                  data: '',
                  clinicName: '',
                  childName: '',
                  age: '',
                  notes: '',
                  labeledScore: '',
                  imageFile: File(''),
                ),
            'parentDashboard': (context) => ParentDashboardScreen(
                  data: '',
                  phone: '', // ✅ Fixed: Added required 'phone' parameter
                ),
            'tagImageManually': (context) => TagImageManually(
                  data: '',
                ),
            'previousSubmission': (context) => PreviousSubmissionsScreen(
                  data: '',
                  phone: '',
                ),
            'uploadChildDetails': (context) => UploadChildDetails(),
            'uploadTeacherDetails': (context) => UploadTeacherDetails(),
            'adminDashboard': (context) => AdminDashboard(
                  data: '',
                ),
            'schoolAdminLogin': (context) => SchoolAdminLogin(),
            'selectChild': (context) => SelectChildScreen(
                  data: '',
                  phone: '',
                  role: '', // ✅ Required role added
                ),
            'schoolsAnalysis': (context) => SchoolAnalysisScreen(
                  schoolName: '',
                ),
            'CreateAdminAccount': (context) => CreateAdminAccountScreen(),
            'assignAdminToSchool': (context) => AssignAdminToSchoolScreen(),
            'childReportDetails': (context) => ChildReport(data: ''),
          },
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: currentMode,
        );
      },
    );
  }
}
