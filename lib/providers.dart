// lib/providers.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'models.dart';
import 'repositories.dart';
import 'utils.dart';
import 'constants.dart'; // Added missing import for AppConstants

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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
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
  
  Future<bool> updateReportStatus(String reportId, String status, String response) async {
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
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
}

class StaffProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
}