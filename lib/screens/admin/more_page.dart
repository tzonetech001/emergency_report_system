// lib/screens/admin/more_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// auth_provider import removed (not present in project)
import '../../constants.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'More Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All management tools in one place',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // User Management
            _buildSectionHeader('User Management', Icons.people_outline),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMoreAction(
                  'Add Student',
                  Icons.person_add_outlined,
                  Colors.blue,
                  () => _showComingSoon(context, 'Add Student'),
                ),
                _buildMoreAction(
                  'Add Staff',
                  Icons.person_add_alt_1_outlined,
                  Colors.orange,
                  () => _showComingSoon(context, 'Add Staff'),
                ),
                _buildMoreAction(
                  'Add Admin',
                  Icons.admin_panel_settings_outlined,
                  Colors.purple,
                  () => _showComingSoon(context, 'Add Admin'),
                ),
                _buildMoreAction(
                  'View Students',
                  Icons.people_outline,
                  Colors.blue,
                  () => _navigateToUsers(context, 'student'),
                ),
                _buildMoreAction(
                  'View Staff',
                  Icons.person_outline,
                  Colors.orange,
                  () => _navigateToUsers(context, 'staff'),
                ),
                _buildMoreAction(
                  'View Admins',
                  Icons.admin_panel_settings,
                  Colors.purple,
                  () => _navigateToUsers(context, 'admin'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Department & Course Management
            _buildSectionHeader('Academic Management', Icons.school_outlined),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMoreAction(
                  'Add Department',
                  Icons.business_outlined,
                  Colors.teal,
                  () => _showComingSoon(context, 'Add Department'),
                ),
                _buildMoreAction(
                  'View Departments',
                  Icons.business,
                  Colors.teal,
                  () => _navigateToTab(context, 1),
                ),
                _buildMoreAction(
                  'Add Course',
                  Icons.book_outlined,
                  Colors.indigo,
                  () => _showComingSoon(context, 'Add Course'),
                ),
                _buildMoreAction(
                  'View Courses',
                  Icons.book,
                  Colors.indigo,
                  () => _navigateToTab(context, 2),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Reports & Notifications
            _buildSectionHeader('Reports & Notifications', Icons.notifications_outlined),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMoreAction(
                  'All Reports',
                  Icons.report_outlined,
                  Colors.red,
                  () => _navigateToTab(context, 3),
                ),
                _buildMoreAction(
                  'Pending Reports',
                  Icons.pending_outlined,
                  Colors.orange,
                  () => _showComingSoon(context, 'Pending Reports'),
                ),
                _buildMoreAction(
                  'Notifications',
                  Icons.notifications_outlined,
                  Colors.pink,
                  () => _navigateToNotifications(context),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Settings & Profile
            _buildSectionHeader('Settings & Profile', Icons.settings_outlined),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMoreAction(
                  'Profile',
                  Icons.person_outline,
                  AppConstants.primaryColor,
                  () => _navigateToProfile(context),
                ),
                _buildMoreAction(
                  'Settings',
                  Icons.settings_outlined,
                  Colors.grey,
                  () => _showComingSoon(context, 'Settings'),
                ),
                _buildMoreAction(
                  'Logout',
                  Icons.logout_outlined,
                  Colors.red,
                  () => _showLogoutDialog(context),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // System Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'System Information',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('App Version', AppConstants.appVersion),
                  _buildInfoRow('Database', 'Firebase Firestore'),
                  _buildInfoRow('Platform', 'Flutter Web'),
                  _buildInfoRow('Status', '🟢 Online'),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        Container(
          width: 30,
          height: 2,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildMoreAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
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
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    context.visitAncestorElements((element) {
      if (element is StatefulElement &&
          element.state.widget.runtimeType.toString() == 'AdminDashboard') {
        element.state.setState(() {
          (element.state as dynamic)._currentIndex = index;
        });
        return false;
      }
      return true;
    });
  }

  void _navigateToUsers(BuildContext context, String role) {
    _navigateToTab(context, 2);
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.pushNamed(context, '/notifications');
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
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
              // use dynamic since provider type file may be missing
              Provider.of<dynamic>(context, listen: false).logout();
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