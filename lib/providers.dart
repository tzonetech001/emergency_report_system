// lib/providers.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'repositories.dart';
import 'utils.dart';
import 'constants.dart'; // Added missing import for AppConstants

// lib/providers.dart (only AuthProvider part – replace the entire AuthProvider class)

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  String? _error;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;

  Future<bool> login(String regNo, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(regNo, password);

      await SessionManager.saveUserData(
        userId: _currentUser!.id,
        regNo: _currentUser!.regNo,
        role: _currentUser!.role,
        departmentId: _currentUser!.departmentId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // lib/providers.dart (inside AuthProvider class)

// Check if user is already logged in (called on app start)
Future<bool> checkAuthStatus() async {
  final isLoggedIn = await SessionManager.isLoggedIn();
  if (!isLoggedIn) return false;

  try {
    final userId = await SessionManager.getUserId();
    if (userId == null) return false;

    // Fetch user data from Firestore using userId
    final user = await _repository.getUserById(userId);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<void> logout() async {
  await _repository.logout();
  await SessionManager.logout();
  _currentUser = null;
  notifyListeners();
}

  Future<bool> resetPassword(String email, String phone, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.resetPassword(email, phone, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getUserFriendlyError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper: convert exceptions to user-friendly messages
  String _getUserFriendlyError(Object e) {
    if (e is FirebaseAuthException) {
      // Handle Firebase Auth specific errors
      switch (e.code) {
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'user-not-found':
          return 'No user found with these credentials.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return e.message ?? 'An error occurred. Please try again.';
      }
    } else if (e is FirebaseException) {
      // General Firebase exceptions (including Firestore)
      if (e.code == 'network-request-failed') {
        return 'Network error. Please check your internet connection.';
      }
      return e.message ?? 'An error occurred. Please try again.';
    } else if (e is Exception) {
      // Any other exception
      final msg = e.toString();
      if (msg.contains('network') || msg.contains('Connection') || msg.contains('timeout')) {
        return 'Network error. Please check your internet connection.';
      }
      return 'An error occurred. Please try again.';
    }
    return 'An unexpected error occurred.';
  }
}

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenToReports(String departmentId) {
    _repository.getReportsForDepartment(departmentId).listen((reports) {
      _reports = reports;
      notifyListeners();
    });
  }

  void listenToUserReports(String userId) {
    _repository.getReportsByUser(userId).listen((reports) {
      _reports = reports;
      notifyListeners();
    });
  }

  Future<bool> submitReport(ReportModel report) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitReport(report);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String> uploadAttachment(File file) async {
    return await _repository.uploadAttachment(file);
  }

  Future<bool> updateReportStatus(
      String reportId, String status, String response) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateReportStatus(reportId, status, response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.getAllReports();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DepartmentModel> _departments = [];
  List<CourseModel> _courses = [];
  List<CourseModel> _allCourses = [];
  List<UserModel> _students = [];
  List<UserModel> _staff = [];
  bool _isLoading = false;
  String? _error;

  List<DepartmentModel> get departments => _departments;
  List<CourseModel> get courses => _courses;
  List<CourseModel> get allCourses => _allCourses;
  List<UserModel> get students => _students;
  List<UserModel> get staff => _staff;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add this getter
  List<UserModel> get admins => _admins; // define _admins list at top
  List<UserModel> _admins = [];

// Add this method to load admins
Future<void> loadAdmins() async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _admins = await _repository.getUsersByRole(AppConstants.roleAdmin);
    print('✅ Admins loaded: ${_admins.length}');  // 👈 debug
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    print('❌ Error loading admins: $e');
  }
}

// Add a method to register admin (optional)
  Future<String?> registerAdmin(Map<String, dynamic> adminData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Generate regNo: NIT/ADMIN/YYYY/XXXX
      // You need a counter for admin as well, or use a simple timestamp.
      // For simplicity, we'll generate a random number.
      String regNo =
          'NIT/ADMIN/${DateTime.now().year}/${DateTime.now().millisecondsSinceEpoch}';
      // Truncate to keep consistent format
      regNo = regNo.substring(0, 18);

      // Store in Firestore
      await _firestore.collection(AppConstants.usersCollection).add({
        ...adminData,
        'regNo': regNo,
        'role': AppConstants.roleAdmin,
        'status': AppConstants.statusActive,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Also create Firebase Auth user with the provided password
      // adminData should contain 'email' and 'password'
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: adminData['email'],
        password: adminData['password'],
      );
      await loadAdmins();
      _isLoading = false;
      notifyListeners();
      return regNo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Department Methods
  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _departments = await _repository.getDepartments();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerDepartment(DepartmentModel department) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerDepartment(department);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDepartment(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateDepartment(id, data);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDepartment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteDepartment(id);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleDepartmentStatus(String id, bool active) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleDepartmentStatus(id, active);
      await loadDepartments();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Course Methods
  Future<void> loadAllCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allCourses = await _repository.getAllCourses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourses(String departmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _repository.getCoursesByDepartment(departmentId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerCourse(CourseModel course) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerCourse(course);
      await loadCourses(course.departmentId);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCourse(id, data);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCourse(id);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCourseStatus(String id, bool active) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleCourseStatus(id, active);
      await loadAllCourses();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // User Methods
  Future<void> loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _students = await _repository.getUsersByRole(AppConstants.roleStudent);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStaff() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _staff = await _repository.getUsersByRole(AppConstants.roleStaff);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> registerStudent(StudentData student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String regNo = await _repository.registerStudent(student);
      await loadStudents();
      _isLoading = false;
      notifyListeners();
      return regNo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> registerStaff(StaffData staff) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String regNo = await _repository.registerStaff(staff);
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return regNo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUser(id, data);
      await loadStudents();
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteUser(id);
      await loadStudents();
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserStatus(String id, bool active) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.toggleUserStatus(id, active);
      await loadStudents();
      await loadStaff();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

class StudentProvider extends ChangeNotifier {
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
}

class StaffProvider extends ChangeNotifier {
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
}
