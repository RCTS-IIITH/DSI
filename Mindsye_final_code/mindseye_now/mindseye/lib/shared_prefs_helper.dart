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

  // Get user details (role and phone number)
  static Future<Map<String, String>> getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(SharedPrefsKeys.roleKey) ?? 'Guest';
      final phoneNumber =
          prefs.getString(SharedPrefsKeys.phoneNumberKey) ?? 'N/A';
      return {'role': role, 'phoneNumber': phoneNumber};
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

  // Save selected child details
  static Future<void> saveSelectedChildDetails({
    required String id,
    required String name,
    required String age,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPrefsKeys.selectedChildIdKey, id);
      await prefs.setString(SharedPrefsKeys.selectedChildNameKey, name);
      await prefs.setString(SharedPrefsKeys.selectedChildAgeKey, age);
    } catch (e) {
      print("Error saving selected child details: $e");
    }
  }

  // Get selected child details
  static Future<Map<String, String>> getSelectedChildDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(SharedPrefsKeys.selectedChildIdKey) ?? '';
      final name = prefs.getString(SharedPrefsKeys.selectedChildNameKey) ?? '';
      final age = prefs.getString(SharedPrefsKeys.selectedChildAgeKey) ?? '';

      return {'id': id, 'name': name, 'age': age};
    } catch (e) {
      print("Error retrieving selected child details: $e");
      return {'id': '', 'name': '', 'age': ''};
    }
  }

  // Clear selected child details
  static Future<void> clearSelectedChildDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPrefsKeys.selectedChildIdKey);
      await prefs.remove(SharedPrefsKeys.selectedChildNameKey);
      await prefs.remove(SharedPrefsKeys.selectedChildAgeKey);
    } catch (e) {
      print("Error clearing selected child details: $e");
    }
  }
}
