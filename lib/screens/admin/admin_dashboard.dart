// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../utils.dart';
import '../widgets/bottom_nav_bar.dart';
import 'manage_departments.dart';
import 'manage_courses.dart';
import 'manage_users.dart';
import 'view_all_reports.dart';
import 'notifications.dart';
import 'profile_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _AdminHomeScreen(),
    const ManageDepartmentsScreen(),
    const ManageCoursesScreen(),
    const ViewAllReportsScreen(),
    const ManageUsersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadDepartments();
      adminProvider.loadAllCourses();
      adminProvider.loadStudents();
      adminProvider.loadStaff();
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      reportProvider.loadAllReports();
    });
  }

  void _showActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Data'),
              onTap: () {
                Navigator.pop(context);
                _refreshData(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   title: const Text(
      //     'Admin Dashboard',
      //     style: TextStyle(
      //       fontSize: 18,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: AppConstants.primaryColor,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: true,
      //   leading: Consumer<AuthProvider>(
      //     builder: (context, authProvider, _) {
      //       final user = authProvider.currentUser;
      //       final initial = user?.firstName.isNotEmpty == true
      //           ? user!.firstName[0].toUpperCase()
      //           : 'A';
      //       return Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: GestureDetector(
      //           onTap: () {
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => const ProfilePage(),
      //               ),
      //             );
      //           },
      //           child: Container(
      //             width: 40,
      //             height: 40,
      //             decoration: BoxDecoration(
      //               color: Colors.white.withOpacity(0.2),
      //               shape: BoxShape.circle,
      //               border: Border.all(
      //                 color: Colors.white.withOpacity(0.4),
      //                 width: 2,
      //               ),
      //             ),
      //             child: Center(
      //               child: Text(
      //                 initial,
      //                 style: const TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 16,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      //   actions: [
      //     // Bell Icon for Notifications
      //     IconButton(
      //       icon: Stack(
      //         children: [
      //           const Icon(
      //             Icons.notifications_outlined,
      //             size: 28,
      //             color: Colors.white,
      //           ),
      //           Positioned(
      //             right: 0,
      //             top: 0,
      //             child: Container(
      //               width: 10,
      //               height: 10,
      //               decoration: const BoxDecoration(
      //                 color: Colors.red,
      //                 shape: BoxShape.circle,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => const NotificationsScreen(),
      //           ),
      //         );
      //       },
      //     ),
      //     const SizedBox(width: 8),
      //     // Refresh button
      //     IconButton(
      //       icon: const Icon(
      //         Icons.refresh,
      //         size: 24,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         _refreshData(context);
      //       },
      //     ),
      //     const SizedBox(width: 4),
      //   ],
      // ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionsMenu(context);
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavItem(icon: Icons.home_outlined, label: 'Home'),
          BottomNavItem(icon: Icons.business_outlined, label: 'Depts'),
          BottomNavItem(icon: Icons.book_outlined, label: 'Courses'),
          BottomNavItem(icon: Icons.report_outlined, label: 'Reports'),
          BottomNavItem(
              icon: Icons.people_outline,
              label: 'Users'), // Changed from More to Users
        ],
      ),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await Future.wait([
      adminProvider.loadDepartments(),
      adminProvider.loadAllCourses(),
      adminProvider.loadStudents(),
      adminProvider.loadStaff(),
      reportProvider.loadAllReports(),
    ]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed!'),
        backgroundColor: AppConstants.successColor,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontSize: 16)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ==================== ADMIN HOME SCREEN ====================
class _AdminHomeScreen extends StatelessWidget {
  const _AdminHomeScreen();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final user = authProvider.currentUser;

    // Count statistics
    int totalStudents = adminProvider.students.length;
    int totalStaff = adminProvider.staff.length;
    int totalReports = reportProvider.reports.length;
    int pendingReports =
        reportProvider.reports.where((r) => r.status == 'pending').length;
    int activeDepartments =
        adminProvider.departments.where((d) => d.isActive).length;
    int activeCourses =
        adminProvider.allCourses.where((c) => c.isActive).length;

    // Get time of day greeting
    String greeting = _getGreeting();

    return RefreshIndicator(
      onRefresh: () async {
        final adminProvider =
            Provider.of<AdminProvider>(context, listen: false);
        final reportProvider =
            Provider.of<ReportProvider>(context, listen: false);
        await Future.wait([
          adminProvider.loadDepartments(),
          adminProvider.loadAllCourses(),
          adminProvider.loadStudents(),
          adminProvider.loadStaff(),
          reportProvider.loadAllReports(),
        ]);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== TOP STATIC CARD ====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5FA4ED),
                    const Color(0xFF7BB8F0),
                    const Color(0xFF3A7CBD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shiny lines effect
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -30,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 50,
                    bottom: 20,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Shiny line
                  Positioned(
                    top: 0,
                    left: -50,
                    right: -50,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                user?.displayName ?? 'Admin',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getTodayDate(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Stats Row
                      Row(
                        children: [
                          _buildStatItem(
                            'Students',
                            totalStudents.toString(),
                            Icons.people_outline,
                            Colors.white,
                          ),
                          _buildStatItem(
                            'Staff',
                            totalStaff.toString(),
                            Icons.person_outline,
                            Colors.white,
                          ),
                          _buildStatItem(
                            'Reports',
                            totalReports.toString(),
                            Icons.report_outlined,
                            Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================== QUICK STATS ====================
            Row(
              children: [
                _buildQuickStat(
                  'Departments',
                  activeDepartments.toString(),
                  Icons.business_outlined,
                  AppConstants.primaryColor,
                ),
                const SizedBox(width: 12),
                _buildQuickStat(
                  'Courses',
                  activeCourses.toString(),
                  Icons.book_outlined,
                  Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildQuickStat(
                  'Pending',
                  pendingReports.toString(),
                  Icons.pending_outlined,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================== USERS CARD (NEW) ====================
            GestureDetector(
              onTap: () {
                // Navigate to Users tab
                final parent =
                    context.findAncestorStateOfType<_AdminDashboardState>();
                if (parent != null) {
                  parent.setState(() {
                    parent._currentIndex = 4; // Users tab index
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.primaryLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Manage Users',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total: ${totalStudents + totalStaff} users',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildUserChip(
                                  'Students', totalStudents, Colors.white),
                              const SizedBox(width: 8),
                              _buildUserChip('Staff', totalStaff, Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================== QUICK ACTIONS (Modern Grid) ====================
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickAction(
                  context,
                  'Departments',
                  Icons.business_outlined,
                  _navigateToTab,
                  const Color(0xFF5FA4ED),
                  1,
                ),
                _buildQuickAction(
                  context,
                  'Courses',
                  Icons.book_outlined,
                  _navigateToTab,
                  const Color(0xFF9B59B6),
                  2,
                ),
                _buildQuickAction(
                  context,
                  'Users',
                  Icons.people_outline,
                  _navigateToTab,
                  const Color(0xFF2ECC71),
                  4,
                ),
                _buildQuickAction(
                  context,
                  'Reports',
                  Icons.report_outlined,
                  _navigateToTab,
                  const Color(0xFFE74C3C),
                  3,
                ),
                _buildQuickAction(
                  context,
                  'Profile',
                  Icons.person_outline,
                  _navigateToProfile,
                  const Color(0xFF5FA4ED),
                  null,
                ),
                _buildQuickAction(
                  context,
                  'Notifications',
                  Icons.notifications_outlined,
                  _navigateToNotifications,
                  const Color(0xFFE67E22),
                  null,
                ),
                _buildQuickAction(
                  context,
                  'Add Student',
                  Icons.person_add_outlined,
                  _navigateToUsers,
                  const Color(0xFF2ECC71),
                  null,
                ),
                _buildQuickAction(
                  context,
                  'Add Staff',
                  Icons.person_add_alt_1_outlined,
                  _navigateToUsers,
                  const Color(0xFFF39C12),
                  null,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================== PENDING REPORTS CARD ====================
            GestureDetector(
              onTap: () {
                final parent =
                    context.findAncestorStateOfType<_AdminDashboardState>();
                if (parent != null) {
                  parent.setState(() {
                    parent._currentIndex = 3; // Reports tab
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pending_outlined,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pending Reports',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$pendingReports report(s) need your attention',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        pendingReports.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================== SYSTEM INFO ====================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Information',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            _buildInfoChip('v${AppConstants.appVersion}'),
                            const SizedBox(width: 8),
                            _buildInfoChip('Firestore'),
                            const SizedBox(width: 8),
                            _buildInfoChip('${activeDepartments} Depts'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Footer
            Center(
              child: Text(
                '© ${DateTime.now().year} NIT Emergency Report System',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================
  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 10,
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    void Function(BuildContext, int?) onTap,
    Color color,
    int? tabIndex,
  ) {
    return GestureDetector(
      onTap: () => onTap(context, tabIndex),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  // ==================== Navigation Methods ====================
  void _navigateToTab(BuildContext context, int? index) {
    if (index == null) return;
    final parent = context.findAncestorStateOfType<_AdminDashboardState>();
    if (parent != null) {
      parent.setState(() {
        parent._currentIndex = index;
      });
    }
  }

  void _navigateToProfile(BuildContext context, int? _) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context, int? _) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _navigateToUsers(BuildContext context, int? _) {
    // Navigate to Users tab
    final parent = context.findAncestorStateOfType<_AdminDashboardState>();
    if (parent != null) {
      parent.setState(() {
        parent._currentIndex = 4; // Users tab
      });
    }
  }

  // ==================== Date Helpers ====================
  String _getTodayDate() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }
}
