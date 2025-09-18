import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/shared_prefs_helper.dart';

class SchoolAdminManageScreen extends StatefulWidget {
  const SchoolAdminManageScreen({super.key});

  @override
  State<SchoolAdminManageScreen> createState() => _SchoolAdminManageScreenState();
}

class _SchoolAdminManageScreenState extends State<SchoolAdminManageScreen> {
  bool _loading = true;
  String? _error;
  Map<String, List<Map<String, dynamic>>> _studentsByClass = {};
  List<Map<String, dynamic>> _teachers = [];
  String _schoolName = '';

  String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:3001';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await SharedPrefsHelper.getUserDetails();
      // For SchoolAdmin, we expect one assigned school in local store from profile fetch
      // Fallback to fetching from backend if needed
      _schoolName = user['assignedSchool'] ?? '';
      if (_schoolName.isEmpty) {
        // Try get admins self and infer school list
        final phone = user['phoneNumber'] ?? '';
        final res = await http.get(Uri.parse('$backendUrl/api/users/get-admins?phone=$phone'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final list = data['assignedSchoolList'] is List
              ? List<String>.from(data['assignedSchoolList'])
              : (data['assignedSchoolList']?.toString().split(',') ?? []);
          if (list.isNotEmpty) _schoolName = list.first.toString();
        }
      }

      if (_schoolName.isEmpty) {
        throw Exception('No assigned school found');
      }

      final stuRes = await http.get(Uri.parse('$backendUrl/api/users/students-by-school?schoolName=${Uri.encodeQueryComponent(_schoolName)}'));
      final teaRes = await http.get(Uri.parse('$backendUrl/api/users/teachers-by-school?schoolName=${Uri.encodeQueryComponent(_schoolName)}'));
      if (stuRes.statusCode == 200 && teaRes.statusCode == 200) {
        final stu = jsonDecode(stuRes.body);
        final tea = jsonDecode(teaRes.body);
        final map = <String, List<Map<String, dynamic>>>{};
        final data = Map<String, dynamic>.from(stu['data'] ?? {});
        for (final entry in data.entries) {
          map[entry.key] = List<Map<String, dynamic>>.from(entry.value.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)));
        }
        setState(() {
          _studentsByClass = map;
          _teachers = List<Map<String, dynamic>>.from((tea['data'] as List).map((e) => Map<String, dynamic>.from(e)));
          _loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteTeacher(String id, String phone) async {
    final ok = await _confirm('Delete Teacher', 'Are you sure you want to delete this teacher?');
    if (ok != true) return;
    final res = await http.delete(Uri.parse('$backendUrl/api/users/delete-teacher/$id?phone=$phone'));
    if (res.statusCode == 200) {
      await _load();
      _toast('Teacher deleted');
    } else {
      _toast('Failed to delete teacher');
    }
  }

  Future<void> _deleteStudent(String id) async {
    final ok = await _confirm('Delete Student', 'Are you sure you want to delete this student?');
    if (ok != true) return;
    final res = await http.delete(Uri.parse('$backendUrl/api/users/delete-child/$id'));
    if (res.statusCode == 200) {
      await _load();
      _toast('Student deleted');
    } else {
      _toast('Failed to delete student');
    }
  }

  Future<bool?> _confirm(String title, String message) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage School'),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Text('School: $_schoolName', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text('Students by Class', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._studentsByClass.entries.map((entry) => _buildStudentClassSection(entry.key, entry.value)).toList(),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      const Text('Teachers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._teachers.map(_buildTeacherTile).toList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStudentClassSection(String className, List<Map<String, dynamic>> students) {
    return Card(
      child: ExpansionTile(
        title: Text('Class $className (${students.length})'),
        children: students
            .map((s) => ListTile(
                  title: Text(s['name']?.toString() ?? '-'),
                  subtitle: Text('Roll: ${s['rollNumber'] ?? '-'} | Age: ${s['age'] ?? '-'}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteStudent(s['_id'].toString()),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTeacherTile(Map<String, dynamic> t) {
    return Card(
      child: ListTile(
        title: Text(t['name']?.toString() ?? '-'),
        subtitle: Text('Class: ${t['class']?.toString() ?? '-'} | Phone: ${t['phone'] ?? '-'}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTeacher(t['_id']?.toString() ?? '', t['phone']?.toString() ?? ''),
        ),
      ),
    );
  }
}


