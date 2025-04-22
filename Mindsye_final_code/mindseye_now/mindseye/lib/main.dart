import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mindseye/provider/professional_provider.dart';
import 'package:mindseye/provider/report_provider.dart';
import 'package:mindseye/provider/role_provider.dart';
import 'package:mindseye/provider/user_provider.dart';
import 'package:provider/provider.dart'; // ✅ Provider package
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
import 'package:mindseye/adminDahboard.dart';
import 'package:mindseye/login.dart';
import 'package:mindseye/provider/admin_provider.dart';

// ✅ Your RoleProvider

Future<void> envLoader() async {
  await dotenv.load(fileName: ".env");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await envLoader();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionalProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
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
        'createProfessionalAccount': (context) => CreateProfessionalAccount(),
        'schoolDashboard': (context) => SchoolDashboardScreen(
              data: '',
              phone: '',
            ),
        'professionalDashboard': (context) => ProfessionalDashboard(
              data: '',
              phone: '',
            ),
        'NGOdashboard': (context) => NGODashboard(
              data: '',
            ),
        'reportsDashboard': (context) => ReportsDashboardScreen(),
        'labelData': (context) => LabelDataScreen(),
        'labelPreviousData': (context) => LabelPreviousDataScreen(),
        'reportDetails': (context) => ReportDetailsScreen(),
        'reportAnalysis': (context) => ReportAnalysisScreen(),
        'studentReport': (context) => StudentReportScreen(),
        'submissionStatus': (context) => SubmissionStatusScreen(),
        'tagImage': (context) => TagImageScreen(),
        'captureDrawing': (context) => CaptureDrawingScreen(
              clinicName: '',
              childName: '',
              age: '',
              notes: '',
              labeledScore: '',
              data: '',
              phone: '',
              role: '',
            ),
        'parentDashboard': (context) => ParentDashboardScreen(
              data: '',
              phone: '',
            ),
        'tagImageManually': (context) => TagImageManually(data: ''),
        'previousSubmission': (context) => PreviousSubmissionsScreen(
              data: '',
              phone: '',
              role: '',
            ),
        'uploadChildDetails': (context) => UploadChildDetails(),
        'uploadTeacherDetails': (context) => UploadTeacherDetails(),
        'adminDashboard': (context) => AdminDashboard(data: ''),
        'schoolAdminLogin': (context) => SchoolAdminLogin(),
        'selectChild': (context) => SelectChildScreen(
              data: '',
              phone: '',
              role: '',
            ),
        'schoolsAnalysis': (context) => SchoolAnalysisScreen(),
        'CreateAdminAccount': (context) => CreateAdminAccountScreen(),
        'assignAdminToSchool': (context) => AssignAdminToSchoolScreen(),
        'childReportDetails': (context) => ChildReport(data: ''),
      },
    );
  }
}
