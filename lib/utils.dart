// lib/utils.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  // Generate Registration Number with proper sequence
  static String generateRegNo({
    required String code,
    required int year,
    required int sequence,
    bool isStudent = false,
  }) {
    String seqStr = sequence.toString().padLeft(4, '0');
    return 'NIT/$code/$year/$seqStr';
  }
  
  // Get available years (2022-2026)
  static List<int> getAvailableYears() {
    final currentYear = DateTime.now().year;
    List<int> years = [];
    for (int year = 2022; year <= currentYear; year++) {
      years.add(year);
    }
    return years;
  }
  
  // Generate default password
  static String generatePassword(String lastName, int year) {
    return '$lastName@$year';
  }
  
  // Validate Email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validate Phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^[0-9]{10,15}$').hasMatch(phone);
  }
  
  // Get Current Year
  static int getCurrentYear() {
    return DateTime.now().year;
  }
  
  // Format Date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
  
  // Get Category Icon
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'academic': return Icons.school;
      case 'health': return Icons.medical_services;
      case 'security': return Icons.security;
      case 'harassment': return Icons.warning;
      default: return Icons.report;
    }
  }
  
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'academic': return const Color(0xFF3498DB);
      case 'health': return const Color(0xFF2ECC71);
      case 'security': return const Color(0xFFE67E22);
      case 'harassment': return const Color(0xFFE74C3C);
      default: return const Color(0xFF5FA4ED);
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF39C12);
      case 'in-progress': return const Color(0xFF3498DB);
      case 'resolved': return const Color(0xFF2ECC71);
      default: return const Color(0xFF757575);
    }
  }
  
  static String getRoleLabel(String role) {
    switch (role) {
      case 'admin': return 'Administrator';
      case 'student': return 'Student';
      case 'staff': return 'Staff';
      default: return 'Unknown';
    }
  }
  
  static String getStatusLabel(String status) {
    switch (status) {
      case 'active': return 'Active';
      case 'inactive': return 'Inactive';
      default: return 'Unknown';
    }
  }
  
  // Get student sequence starting number (1001)
  static int getStudentStartSequence() {
    return 1001;
  }
  
  // Get staff sequence starting number (0001)
  static int getStaffStartSequence() {
    return 1;
  }
}
// lib/utils.dart (replace the SessionManager class only)

// lib/utils.dart (replace the SessionManager class only)

class SessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyRegNo = 'user_reg_no';
  static const String _keyRole = 'user_role';
  static const String _keyDepartmentId = 'user_department_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Save user data after login
  static Future<void> saveUserData({
    required String userId,
    required String regNo,
    required String role,
    String? departmentId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyRegNo, regNo);
    await prefs.setString(_keyRole, role);
    await prefs.setBool(_keyIsLoggedIn, true);
    if (departmentId != null) {
      await prefs.setString(_keyDepartmentId, departmentId);
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Get registration number
  static Future<String?> getRegNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRegNo);
  }

  // Get role
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  // Get department ID
  static Future<String?> getDepartmentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDepartmentId);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear all session data (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRegNo);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyDepartmentId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Get all user data as a map
  static Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    return {
      'userId': prefs.getString(_keyUserId) ?? '',
      'regNo': prefs.getString(_keyRegNo) ?? '',
      'role': prefs.getString(_keyRole) ?? '',
      'departmentId': prefs.getString(_keyDepartmentId) ?? '',
    };
  }
}