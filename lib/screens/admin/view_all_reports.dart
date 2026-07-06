// lib/screens/admin/view_all_reports.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers.dart';
import '../../constants.dart';
import '../../models.dart';
import '../../utils.dart';

class ViewAllReportsScreen extends StatefulWidget {
  const ViewAllReportsScreen({super.key});

  @override
  State<ViewAllReportsScreen> createState() => _ViewAllReportsScreenState();
}

class _ViewAllReportsScreenState extends State<ViewAllReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      reportProvider.loadAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    // Build the content (the list or empty state) without Scaffold
    Widget content = reportProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : reportProvider.reports.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reportProvider.reports.length,
                itemBuilder: (context, index) {
                  final report = reportProvider.reports[index];
                  return _buildReportCard(report);
                },
              );



    // Otherwise, wrap with Scaffold and AppBar
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        title: const Text(
          'All Reports',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: () {
              final reportProvider =
                  Provider.of<ReportProvider>(context, listen: false);
              reportProvider.loadAllReports();
            },
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.report,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Reports Found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reports submitted by users will appear here',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      Utils.getCategoryColor(report.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Utils.getCategoryIcon(report.category),
                      size: 14,
                      color: Utils.getCategoryColor(report.category),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getCategoryLabel(report.category),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Utils.getCategoryColor(report.category),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Utils.getStatusColor(report.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusLabel(report.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Utils.getStatusColor(report.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            report.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 12,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                report.reporterRegNo,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today,
                size: 12,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                Utils.formatDate(report.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                color: AppConstants.primaryColor,
                onPressed: () {
                  _showReportDetails(context, report);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReportDetailsBottomSheet(report: report),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'academic':
        return 'Academic';
      case 'health':
        return 'Health';
      case 'security':
        return 'Security';
      case 'harassment':
        return 'Harassment';
      default:
        return 'Other';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }
}

// ---------- BOTTOM SHEET (unchanged, but could be extracted) ----------
class _ReportDetailsBottomSheet extends StatefulWidget {
  final ReportModel report;
  const _ReportDetailsBottomSheet({required this.report});

  @override
  State<_ReportDetailsBottomSheet> createState() =>
      _ReportDetailsBottomSheetState();
}

class _ReportDetailsBottomSheetState extends State<_ReportDetailsBottomSheet> {
  final TextEditingController _responseController = TextEditingController();
  String _selectedStatus = 'pending';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report.status;
    _responseController.text = widget.report.response;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.report.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Utils.getCategoryColor(widget.report.category)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryLabel(widget.report.category),
                    style: TextStyle(
                      fontSize: 10,
                      color: Utils.getCategoryColor(widget.report.category),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Utils.getStatusColor(widget.report.status)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(widget.report.status),
                    style: TextStyle(
                      fontSize: 10,
                      color: Utils.getStatusColor(widget.report.status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  Utils.formatDate(widget.report.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.report.description,
              style: const TextStyle(fontSize: 12),
            ),
            if (widget.report.attachmentUrl != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // View image full screen
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(widget.report.attachmentUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Your Response:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _responseController,
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your response here...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Status',
                labelStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(
                    value: 'in-progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUpdating
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
                        'UPDATE REPORT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _updateReport() async {
    setState(() {
      _isUpdating = true;
    });
    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      bool success = await reportProvider.updateReportStatus(
        widget.report.id,
        _selectedStatus,
        _responseController.text.trim(),
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report updated successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reportProvider.error ?? 'An error occurred'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'academic':
        return 'Academic';
      case 'health':
        return 'Health';
      case 'security':
        return 'Security';
      case 'harassment':
        return 'Harassment';
      default:
        return 'Other';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return 'Unknown';
    }
  }
}
