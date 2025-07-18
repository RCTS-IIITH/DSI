import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsKeys {
  static const String roleKey = 'role';
  static const String phoneNumberKey = 'phoneNumber';
  static const String selectedChildIdKey = 'selectedChildId';
  static const String selectedChildNameKey = 'selectedChildName';
  static const String selectedChildAgeKey = 'selectedChildAge';
}

class SharedPrefsHelper {
  // Save user details (role and phone number)
  static Future<void> saveUserDetails(String role, String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPrefsKeys.roleKey, role);
      await prefs.setString(SharedPrefsKeys.phoneNumberKey, phoneNumber);
    } catch (e) {
      print("Error saving user details: $e");
    }
  }

  static const String tokenKey = 'jwt_token';
  static const String userDetailsKey = 'user_details';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get user details (role and phone number)
  static Future<Map<String, String>> getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(SharedPrefsKeys.roleKey) ?? 'Guest';
      final phoneNumber =
          prefs.getString(SharedPrefsKeys.phoneNumberKey) ?? 'N/A';
      final assignedSchoolList =
          prefs.getStringList('assignedSchoolList') ?? [];
      final name = prefs.getString('name') ?? 'Unknown';
      return {
        'role': role,
        'phoneNumber': phoneNumber,
        'name': name,
        'assignedSchoolList': assignedSchoolList.join(', '),
      };
    } catch (e) {
      print("Error retrieving user details: $e");
      return {'role': 'Guest', 'phoneNumber': 'N/A'};
    }
  }

  // Clear user details (logout functionality)
  static Future<void> clearUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPrefsKeys.roleKey);
      await prefs.remove(SharedPrefsKeys.phoneNumberKey);
    } catch (e) {
      print("Error clearing user details: $e");
    }
  }

  static Future<bool> saveSelectedChildDetails({
    required String id,
    required String name,
    required String age,
    required String schoolId,
    required String schoolName,
  }) async {
    try {
      if (id.isEmpty || name.isEmpty || age.isEmpty) {
        print("Error: Invalid child details provided");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(
          'selectedChild',
          json.encode({
            'id': id,
            'name': name,
            'age': age,
            'schoolId': schoolId,
            'schoolName': schoolName,
          }));

      // Verify storage
    } catch (e, stackTrace) {
      print("Error saving selected child details: $e");
      print("Stack trace: $stackTrace");
      return false;
    }
  }

  // Get selected child details with validation
  static Future<Map<String, String>> getSelectedChildDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final childJson = prefs.getString('selectedChild');

      if (childJson == null) {
        print("No selected child found");
        return {
          'id': '',
          'name': '',
          'age': '',
          'schoolId': '',
          'schoolName': ''
        };
      }

      final Map<String, dynamic> childData = json.decode(childJson);

      final id = childData['id'] ?? '';
      final name = childData['name'] ?? '';
      final age = childData['age'] ?? '';
      final schoolId = childData['schoolId'] ?? '';
      final schoolName = childData['schoolName'] ?? '';

      print("Retrieved child details: $childData");

      return {
        'id': id,
        'name': name,
        'age': age,
        'schoolId': schoolId,
        'schoolName': schoolName,
      };
    } catch (e, stackTrace) {
      print("Error retrieving selected child details: $e");
      print("Stack trace: $stackTrace");
      return {
        'id': '',
        'name': '',
        'age': '',
        'schoolId': '',
        'schoolName': ''
      };
    }
  }

  static Future<void> updateUserDetails(Map<String, String> updates) async {
    final prefs = await SharedPreferences.getInstance();
    updates.forEach((key, value) {
      prefs.setString(key, value);
    });
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Clear selected child details with confirmation
  static Future<bool> clearSelectedChildDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selectedChild');
      final isCleared = (prefs.getString('selectedChild') == null);
      print(isCleared
          ? "Child details cleared"
          : "Failed to clear child details");
      return isCleared;
    } catch (e) {
      print("Error clearing selected child details: $e");
      return false;
    }
  }

  static Future<String?> getCurrentUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPrefsKeys.phoneNumberKey);
  }
}
