// lib/screens/admin/manage_users.dart
import 'package:emergency_report_system/repositories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      _loadAllData(adminProvider);
    });
  }

  Future<void> _loadAllData(AdminProvider adminProvider) async {
    await Future.wait([
      adminProvider.loadDepartments(),
      adminProvider.loadAllCourses(),
      adminProvider.loadStudents(),
      adminProvider.loadStaff(),
      adminProvider.loadAdmins(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final students = adminProvider.students;
    final staff = adminProvider.staff;
    final admins = adminProvider.admins;

    // Build the content (the TabBar and TabBarView) without Scaffold
    Widget content = Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Students'),
            Tab(text: 'Staff'),
            Tab(text: 'Admins'),
          ],
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppConstants.primaryColor,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(students, 'student'),
              _buildUserList(staff, 'staff'),
              _buildUserList(admins, 'admin'),
            ],
          ),
        ),
      ],
    );

    // If embedded, return only the content


    // Otherwise, wrap with Scaffold and AppBar
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text(
          'Manage Users',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: () {
              final index = _tabController.index;
              if (index == 0) {
                _showRegisterStudentDialog();
              } else if (index == 1) {
                _showRegisterStaffDialog();
              } else {
                _showRegisterAdminDialog();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () async {
              final provider =
                  Provider.of<AdminProvider>(context, listen: false);
              await _loadAllData(provider);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshed!'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }

  // ---------- USER LIST ----------
  Widget _buildUserList(List<UserModel> users, String role) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              role == 'student'
                  ? Icons.people
                  : role == 'staff'
                      ? Icons.person
                      : Icons.admin_panel_settings,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_roleName(role)} Registered',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to register a new ${_roleName(role).toLowerCase()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        final provider = Provider.of<AdminProvider>(context, listen: false);
        await _loadAllData(provider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  String _roleName(String role) {
    switch (role) {
      case 'student':
        return 'Students';
      case 'staff':
        return 'Staff';
      case 'admin':
        return 'Admins';
      default:
        return 'Users';
    }
  }

  // ---------- USER CARD ----------
  Widget _buildUserCard(UserModel user) {
    // Extract code from regNo
    String regNoParts = user.regNo;
    List<String> parts = regNoParts.split('/');
    String code = parts.length > 1 ? parts[1] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: user.isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: user.isActive
            ? null
            : Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: user.isActive
                  ? AppConstants.primaryColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                user.firstName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: user.isActive
                      ? AppConstants.primaryColor
                      : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: user.isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.badge,
                      size: 12,
                      color:
                          user.isActive ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.regNo,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            user.isActive ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!user.isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'INACTIVE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 20,
                  color: AppConstants.primaryColor,
                ),
                onPressed: () => _showEditUserDialog(user),
              ),
              IconButton(
                icon: Icon(
                  user.isActive ? Icons.block : Icons.check_circle,
                  size: 20,
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
                onPressed: () => _toggleUserStatus(user),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () => _confirmDeleteUser(user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- EDIT USER ----------
  void _showEditUserDialog(UserModel user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final middleNameController = TextEditingController(text: user.middleName);
    final lastNameController = TextEditingController(text: user.lastName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit User',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(firstNameController, 'First Name'),
              _buildTextField(middleNameController, 'Middle Name'),
              _buildTextField(lastNameController, 'Last Name'),
              _buildTextField(emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(phoneController, 'Phone Number',
                  keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<AdminProvider>(context, listen: false);
              Map<String, dynamic> data = {
                'firstName': firstNameController.text.trim(),
                'middleName': middleNameController.text.trim(),
                'lastName': lastNameController.text.trim(),
                'email': emailController.text.trim(),
                'phone': phoneController.text.trim(),
              };
              bool success = await provider.updateUser(user.id, data);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User updated!'),
                      backgroundColor: AppConstants.successColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ---------- TOGGLE / DELETE ----------
  void _toggleUserStatus(UserModel user) async {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    bool success = await provider.toggleUserStatus(user.id, !user.isActive);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(user.isActive ? 'User deactivated!' : 'User activated!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    }
  }

  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Delete "${user.fullName}"?',
            style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider =
                  Provider.of<AdminProvider>(context, listen: false);
              bool success = await provider.deleteUser(user.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('User deleted!'),
                      backgroundColor: AppConstants.successColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------- REGISTER STUDENT (with course dropdown) ----------
  void _showRegisterStudentDialog() {
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? selectedDepartmentId;
    String? selectedCourseId;
    String selectedYear = DateTime.now().year.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final adminProvider = Provider.of<AdminProvider>(context);
          final departments =
              adminProvider.departments.where((d) => d.isActive).toList();
          final courses = adminProvider.allCourses
              .where(
                  (c) => c.departmentId == selectedDepartmentId && c.isActive)
              .toList();

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Register Student',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(firstNameCtrl, 'First Name'),
                  _buildTextField(middleNameCtrl, 'Middle Name'),
                  _buildTextField(lastNameCtrl, 'Last Name'),
                  _buildTextField(emailCtrl, 'Email',
                      keyboardType: TextInputType.emailAddress),
                  _buildTextField(phoneCtrl, 'Phone Number',
                      keyboardType: TextInputType.phone),
                  // Department dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedDepartmentId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: departments.map((d) {
                      return DropdownMenuItem(value: d.id, child: Text(d.name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDepartmentId = value;
                        selectedCourseId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Course dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourseId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Course',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: courses.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCourseId = value),
                  ),
                  const SizedBox(height: 12),
                  // Year dropdown (2024-2030)
                  DropdownButtonFormField<String>(
                    initialValue: selectedYear,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Year of Registration',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(7, (i) {
                      int year = DateTime.now().year + i;
                      return DropdownMenuItem(
                          value: year.toString(), child: Text(year.toString()));
                    }),
                    onChanged: (value) => setState(() => selectedYear = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (firstNameCtrl.text.isEmpty ||
                      lastNameCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty ||
                      phoneCtrl.text.isEmpty ||
                      selectedDepartmentId == null ||
                      selectedCourseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: AppConstants.errorColor),
                    );
                    return;
                  }
                  final provider =
                      Provider.of<AdminProvider>(context, listen: false);
                  // Get course code from selected course
                  final course = provider.allCourses
                      .firstWhere((c) => c.id == selectedCourseId);
                  final student = StudentData(
                    firstName: firstNameCtrl.text.trim(),
                    middleName: middleNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    departmentId: selectedDepartmentId!,
                    courseId: selectedCourseId!,
                    courseCode: course.code,
                    year: int.parse(selectedYear),
                  );
                  String? regNo = await provider.registerStudent(student);
                  if (regNo != null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Student registered! RegNo: $regNo'),
                          backgroundColor: AppConstants.successColor),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor),
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- REGISTER STAFF ----------
  void _showRegisterStaffDialog() {
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String? selectedDepartmentId;
    String selectedYear = DateTime.now().year.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final adminProvider = Provider.of<AdminProvider>(context);
          final departments =
              adminProvider.departments.where((d) => d.isActive).toList();

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Register Staff',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(firstNameCtrl, 'First Name'),
                  _buildTextField(middleNameCtrl, 'Middle Name'),
                  _buildTextField(lastNameCtrl, 'Last Name'),
                  _buildTextField(emailCtrl, 'Email',
                      keyboardType: TextInputType.emailAddress),
                  _buildTextField(phoneCtrl, 'Phone Number',
                      keyboardType: TextInputType.phone),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDepartmentId,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: departments.map((d) {
                      return DropdownMenuItem(value: d.id, child: Text(d.name));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedDepartmentId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedYear,
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      labelText: 'Year of Registration',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(7, (i) {
                      int year = DateTime.now().year + i;
                      return DropdownMenuItem(
                          value: year.toString(), child: Text(year.toString()));
                    }),
                    onChanged: (value) => setState(() => selectedYear = value!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (firstNameCtrl.text.isEmpty ||
                      lastNameCtrl.text.isEmpty ||
                      emailCtrl.text.isEmpty ||
                      phoneCtrl.text.isEmpty ||
                      selectedDepartmentId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: AppConstants.errorColor),
                    );
                    return;
                  }
                  final provider =
                      Provider.of<AdminProvider>(context, listen: false);
                  final dept = provider.departments
                      .firstWhere((d) => d.id == selectedDepartmentId);
                  final staff = StaffData(
                    firstName: firstNameCtrl.text.trim(),
                    middleName: middleNameCtrl.text.trim(),
                    lastName: lastNameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    departmentId: selectedDepartmentId!,
                    departmentCode: dept.code,
                    year: int.parse(selectedYear),
                  );
                  String? regNo = await provider.registerStaff(staff);
                  if (regNo != null) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Staff registered! RegNo: $regNo'),
                          backgroundColor: AppConstants.successColor),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor),
                child: const Text('Register'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- REGISTER ADMIN ----------
  void _showRegisterAdminDialog() {
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Register Admin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(firstNameCtrl, 'First Name'),
              _buildTextField(middleNameCtrl, 'Middle Name'),
              _buildTextField(lastNameCtrl, 'Last Name'),
              _buildTextField(emailCtrl, 'Email',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(phoneCtrl, 'Phone Number',
                  keyboardType: TextInputType.phone),
              _buildTextField(passwordCtrl, 'Password', obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (firstNameCtrl.text.isEmpty ||
                  lastNameCtrl.text.isEmpty ||
                  emailCtrl.text.isEmpty ||
                  phoneCtrl.text.isEmpty ||
                  passwordCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: AppConstants.errorColor),
                );
                return;
              }
              // We'll use the registerAdmin method from provider
              final provider =
                  Provider.of<AdminProvider>(context, listen: false);
              final adminData = {
                'firstName': firstNameCtrl.text.trim(),
                'middleName': middleNameCtrl.text.trim(),
                'lastName': lastNameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'password': passwordCtrl.text.trim(),
              };
              String? regNo = await provider.registerAdmin(adminData);
              if (regNo != null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Admin registered! RegNo: $regNo'),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Registration failed'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  // ---------- HELPER TEXTFIELD ----------
  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 12),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}