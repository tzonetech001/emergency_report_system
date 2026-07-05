// lib/screens/student/report_academic.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';

class ReportAcademicScreen extends StatefulWidget {
  final bool embedded; // true when used inside dashboard
  const ReportAcademicScreen({super.key, this.embedded = false});

  @override
  State<ReportAcademicScreen> createState() => _ReportAcademicScreenState();
}

class _ReportAcademicScreenState extends State<ReportAcademicScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedDepartmentId;
  bool _isSubmitting = false;

  Map<String, dynamic>? _location;
  bool _isGettingLocation = false;

  // Department data
  List<DepartmentModel> _departments = [];
  bool _loadingDepartments = true;
  String? _departmentsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDepartments();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDepartments() async {
    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      await adminProvider.loadDepartments();
      if (!mounted) return;
      setState(() {
        _departments =
            adminProvider.departments.where((d) => d.isActive).toList();
        _loadingDepartments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _departmentsError = e.toString();
        _loadingDepartments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If embedded, return only the content (no Scaffold/AppBar)
    if (widget.embedded) {
      return _buildContent();
    }
    // Standalone with Scaffold
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Report Academic Issue'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Department',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _buildDepartmentDropdown(),
          const SizedBox(height: 16),

          const Text('Issue Title',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Enter a brief title...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Full Description',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(fontSize: 12),
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Describe the issue in detail...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          // Location Row
          Row(
            children: [
              const Expanded(
                child: Text('Location (Optional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              if (_location != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () => setState(() => _location = null),
                ),
              Flexible(
                child: ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, size: 18),
                  label: Text(
                      _location == null ? 'Get Location' : 'Update Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _location == null
                        ? AppConstants.primaryColor
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
          if (_location != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _location!['address'] ?? 'Location captured',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('SUBMIT REPORT',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    if (_loadingDepartments) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_departmentsError != null) {
      return SizedBox(
        height: 56,
        child: Center(
          child: Text('Error: $_departmentsError',
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      );
    }
    if (_departments.isEmpty) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: Text('No active departments.',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      );
    }

    final seenIds = <String>{};
    final uniqueDepartments =
        _departments.where((dept) => seenIds.add(dept.id)).toList();

    return DropdownButtonFormField<String>(
      value: _selectedDepartmentId,
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Select Department',
        hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: uniqueDepartments.map((dept) {
        return DropdownMenuItem<String>(
          value: dept.id,
          child: Text(
            dept.name,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDepartmentId = value),
    );
  }

  // ---------- Location Methods ----------
  Future<void> _getCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location permission denied.'),
              backgroundColor: AppConstants.errorColor),
        );
      }
      return;
    }
    if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Enable location in settings.'),
              backgroundColor: AppConstants.errorColor),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isGettingLocation = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      String address = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
      if (mounted) {
        setState(() {
          _location = {
            'address': address,
            'lat': position.latitude,
            'lng': position.longitude
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location captured!'),
              backgroundColor: AppConstants.successColor),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppConstants.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  // ---------- Submit Report ----------
  Future<void> _submitReport() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Select a department'),
            backgroundColor: AppConstants.errorColor),
      );
      return;
    }
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fill title and description'),
            backgroundColor: AppConstants.errorColor),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final report = ReportModel(
        id: '',
        reporterId: authProvider.currentUser?.id ?? '',
        reporterRegNo: authProvider.currentUser?.regNo ?? '',
        targetDepartmentId: _selectedDepartmentId!,
        category: AppConstants.categoryAcademic,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: AppConstants.statusPending,
        response: '',
        attachmentUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        location: _location,
      );
      bool success = await reportProvider.submitReport(report);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Report submitted!'),
                backgroundColor: AppConstants.successColor),
          );
          // Clear form
          _titleController.clear();
          _descriptionController.clear();
          setState(() {
            _selectedDepartmentId = null;
            _location = null;
          });
          // If not embedded, pop the screen
          if (!widget.embedded) {
            Navigator.pop(context);
          }
          // If embedded, we stay on the screen but form is cleared.
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(reportProvider.error ?? 'Error'),
                backgroundColor: AppConstants.errorColor),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppConstants.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}