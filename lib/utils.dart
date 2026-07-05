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

class SessionManager {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static Future<void> saveUserData({
    required String userId,
    required String regNo,
    required String role,
    String? departmentId,
  }) async {
    await _prefs?.setString('userId', userId);
    await _prefs?.setString('regNo', regNo);
    await _prefs?.setString('role', role);
    if (departmentId != null) {
      await _prefs?.setString('departmentId', departmentId);
    }
  }
  
  static String? getUserId() => _prefs?.getString('userId');
  static String? getRegNo() => _prefs?.getString('regNo');
  static String? getRole() => _prefs?.getString('role');
  static String? getDepartmentId() => _prefs?.getString('departmentId');
  
  static bool isLoggedIn() {
    return _prefs?.getString('userId') != null;
  }
  
  static Future<void> logout() async {
    await _prefs?.clear();
  }
}