// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedRegNo();
    _checkIfAlreadyLoggedIn(); // 👈 Check if already logged in
  }

  // ✅ Check if user is already logged in
  Future<void> _checkIfAlreadyLoggedIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();
    
    if (isLoggedIn && authProvider.currentUser != null) {
      // User is already logged in - redirect to dashboard
      final role = authProvider.currentUser!.role;
      
      if (role == AppConstants.roleAdmin) {
        Navigator.pushReplacementNamed(context, '/admin-dash');
      } else if (role == AppConstants.roleStudent) {
        Navigator.pushReplacementNamed(context, '/student-dash');
      } else if (role == AppConstants.roleStaff) {
        Navigator.pushReplacementNamed(context, '/staff-dash');
      }
    }
  }

  // ✅ Load remembered registration number
  Future<void> _loadRememberedRegNo() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedRegNo = prefs.getString('remembered_reg_no');
    if (rememberedRegNo != null && rememberedRegNo.isNotEmpty) {
      setState(() {
        _regNoController.text = rememberedRegNo;
        _rememberMe = true;
      });
    }
  }

  // ✅ Save Remember Me preference
  Future<void> _saveRememberMe(bool remember, String regNo) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember && regNo.isNotEmpty) {
      await prefs.setString('remembered_reg_no', regNo);
    } else {
      await prefs.remove('remembered_reg_no');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login with your Registration Number',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Reg No Field
                  TextField(
                    controller: _regNoController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Registration Number',
                      labelStyle: const TextStyle(fontSize: 12),
                      hintText: 'e.g., NIT/BIT/2026/0012',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.badge, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(Icons.lock, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppConstants.primaryColor,
                          ),
                          const Text(
                            'Remember Me',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgot-password');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppConstants.primaryColor,
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              String regNo = _regNoController.text.trim();
                              String password = _passwordController.text.trim();

                              if (regNo.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all fields'),
                                    backgroundColor: AppConstants.errorColor,
                                  ),
                                );
                                return;
                              }

                              bool success =
                                  await authProvider.login(regNo, password);

                              if (success) {
                                // ✅ Save Remember Me preference
                                await _saveRememberMe(_rememberMe, regNo);

                                // Redirect based on role
                                String role =
                                    authProvider.currentUser?.role ?? '';
                                print('🔑 Logged in as: $role');

                                if (role == AppConstants.roleAdmin) {
                                  Navigator.pushReplacementNamed(
                                      context, '/admin-dash');
                                } else if (role == AppConstants.roleStudent) {
                                  Navigator.pushReplacementNamed(
                                      context, '/student-dash');
                                } else if (role == AppConstants.roleStaff) {
                                  Navigator.pushReplacementNamed(
                                      context, '/staff-dash');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Unknown user role. Please contact support.'),
                                      backgroundColor: AppConstants.errorColor,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.error ??
                                        'An error occurred'),
                                    backgroundColor: AppConstants.errorColor,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      '© ${DateTime.now().year} NIT Emergency Report System',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}