import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../src/config/theme.dart';
import '../../../../src/models/job_model.dart';
import '../../../../src/providers/job_provider.dart';
import '../../../../src/widgets/job_card.dart';
import '../../../../src/widgets/timeline_widget.dart';
import '../../../../src/widgets/checklist_item.dart';
import 'view_quotation_screen.dart';
import '../../invoicing/screens/view_invoice_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../chat/screens/chat_screen.dart'; // Import ChatScreen
import 'package:firebase_auth/firebase_auth.dart';

class TrackJobScreen extends StatelessWidget {
  final String jobId;

  const TrackJobScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leadingWidth: 40,
        title: Row(children: [Image.asset('assets/app_icon.png', height: 32)]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.account_circle,
              color: AppColors.textSecondary,
              size: 36,
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: AppColors.scaffoldBg,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          final job = jobProvider.jobs.firstWhere(
            (j) => j.id == jobId,
            orElse: () => throw Exception('Job not found'),
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Job Header
                _buildJobHeader(job),

                // Progress Indicator
                _buildProgressCard(job),

                // Job Checklist
                _buildJobChecklist(job, jobProvider),

                // View Quotation Button
                if (job.status.index >= JobStatus.quoteSent.index)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewQuotationScreen(jobId: jobId),
                            ),
                          );
                        },
                        child: const Text('View Quotation'),
                      ),
                    ),
                  ),

                // Payment Status
                if (job.status == JobStatus.completed) _buildPaymentStatus(job),

                // Invoice Card (Available when ready or completed)
                if (job.status == JobStatus.ready ||
                    job.status == JobStatus.completed)
                  _buildInvoiceCard(context, job),

                // Call Workshop Button
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final Uri phoneUri = Uri(
                        scheme: 'tel',
                        path: '+27616198642',
                      );
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Workshop'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppColors.statusWorking),
                      foregroundColor: AppColors.statusWorking,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Message Workshop Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 8,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            jobId: job.id,
                            currentUserId:
                                FirebaseAuth.instance.currentUser?.uid ??
                                'customer',
                            userRole: 'customer',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Message Workshop'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppColors.primaryBlue),
                      foregroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobHeader(Job job) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: JobCard(
        job: job,
        onTap: () {}, // Already on detail screen
      ),
    );
  }

  Widget _buildProgressCard(Job job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Status Timeline', style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: 8),
          TimelineWidget(activeStatus: job.status),
        ],
      ),
    );
  }

  Widget _buildJobChecklist(Job job, JobProvider jobProvider) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text('Job Checklist', style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: 8),
          if (job.checklist.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No checklist items yet',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            )
          else
            ...job.checklist.map(
              (item) => ChecklistItem(
                title: item,
                isCompleted: job.completedChecklist.contains(item),
                onTap: () => jobProvider.toggleChecklistItem(job.id, item),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(Job job) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.paymentPending.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.paymentPending),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Status', style: AppTextStyles.h4),
              const SizedBox(height: 4),
              Text(
                'Pending Approval',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.statusQuoted,
                ),
              ),
            ],
          ),
          Text(
            'R0.00',
            style: AppTextStyles.h3,
          ), // Placeholder if quote not found
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Job job) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: AppColors.primaryBlue),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Ready', style: AppTextStyles.h4),
                Text('Tap to view details', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewInvoiceScreen(job: job),
                ),
              );
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
