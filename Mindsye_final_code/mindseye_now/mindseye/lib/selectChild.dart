import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mindseye/captureDrawing.dart';
import 'package:mindseye/shared_prefs_helper.dart';

class SelectChildScreen extends StatefulWidget {
  final String data;
  final String phone;
  final String role;

  const SelectChildScreen({
    super.key,
    required this.data,
    required this.phone,
    required this.role,
  });

  @override
  _SelectChildScreenState createState() => _SelectChildScreenState();
}

class _SelectChildScreenState extends State<SelectChildScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> filteredChildren = [];
  bool isLoading = true;
  bool hasError = false;
  String searchQuery = "";
  String selectedClass = "All";

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchChildren();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Debounce logic
    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        filterChildren(searchController.text);
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchChildren() async {
    final String baseUrl = "http://localhost:3000/api/users/getchildren";
    final String url = widget.role == "Parent"
        ? "$baseUrl?role=Parent&phone=${widget.phone}"
        : "$baseUrl?role=Teacher";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          children = data;
          filteredChildren = data;
          isLoading = false;
        });
        _controller.forward();
      } else {
        throw Exception("Failed to load children");
      }
    } catch (error) {
      print("Error fetching children: $error");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void filterChildren(String query) {
    setState(() {
      searchQuery = query;
      filteredChildren = children.where((child) {
        final name = child['name']?.toString().toLowerCase() ?? '';
        final childClass = child['class']?.toString().toLowerCase() ?? '';
        final matchesQuery = name.contains(query.toLowerCase()) ||
            childClass.contains(query.toLowerCase());
        final matchesClass = selectedClass == "All" ||
            child['class'].toString() == selectedClass;
        return matchesQuery && matchesClass;
      }).toList();
    });
  }

  void filterByClass(String selected) {
    setState(() {
      selectedClass = selected;
      filterChildren(searchController.text);
    });
  }

  void navigateToCaptureScreen(Map<String, dynamic> child) async {
    final String childId = child['_id'];
    final String childName = child['name'];
    final String childAge = child['age'].toString();

    // Save selected child details before navigation
    final bool saved = await SharedPrefsHelper.saveSelectedChildDetails(
      id: childId,
      name: childName,
      age: childAge,
    );

    // Print for debugging
    print('Selected child: $childName');

    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving child details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Verify the saved details
    final storedDetails = await SharedPrefsHelper.getSelectedChildDetails();
    print('Stored child details: ${json.encode(storedDetails)}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Hero(
          tag: 'child_$childId',
          child: CaptureDrawingScreen(
            data: widget.data,
            clinicName: '',
            childName: childName,
            age: childAge,
            notes: '',
            labeledScore: '',
          ),
        ),
      ),
    );
  }

  List<String> getClassList() {
    final classes = children.map((e) => e['class'].toString()).toSet().toList();
    classes.sort();
    return ['All', ...classes];
  }

  Widget buildParentCard(Map<String, dynamic> child, int index) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1 * index, 1.0, curve: Curves.elasticOut),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xfff9c5d1), Color(0xfffddde6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(2, 6),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            " ${child['name']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          subtitle:
              Text("Class: ${child['class']}, Roll No: ${child['rollNumber']}"),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () => navigateToCaptureScreen(child),
          ),
        ),
      ),
    );
  }

  Widget buildTeacherTable() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 100,
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
          dataTextStyle: const TextStyle(fontSize: 15),
          columns: const [
            DataColumn(label: Text("Name")),
            DataColumn(label: Text("Roll No")),
            DataColumn(label: Text("Class")),
            DataColumn(label: Text("Parent")),
            DataColumn(label: Text("Action")),
          ],
          rows: filteredChildren.map((child) {
            return DataRow(
              cells: [
                DataCell(Text(child['name'] ?? "-")),
                DataCell(Text(child['rollNumber']?.toString() ?? "-")),
                DataCell(Text(child['class']?.toString() ?? "-")),
                DataCell(Text(child['parentName'] ?? "-")),
                DataCell(
                  ElevatedButton(
                    onPressed: () => navigateToCaptureScreen(child),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Select",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isParent = widget.role == "Parent";

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isParent ? "🧒 Select Your Child" : "👨‍🏫 Select a Student"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
                  ? const Center(child: Text("Something went wrong."))
                  : Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: "Search by name or class",
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      filterChildren("");
                                    },
                                    icon: const Icon(Icons.clear),
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isParent)
                          SizedBox(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: getClassList().map((cls) {
                                final isSelected = selectedClass == cls;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text(cls),
                                    selected: isSelected,
                                    selectedColor: Colors.pink.shade100,
                                    onSelected: (_) => filterByClass(cls),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: filteredChildren.isEmpty
                              ? const Center(child: Text("No children found"))
                              : isParent
                                  ? ListView.builder(
                                      itemCount: filteredChildren.length,
                                      itemBuilder: (context, index) =>
                                          buildParentCard(
                                              filteredChildren[index], index),
                                    )
                                  : buildTeacherTable(),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
