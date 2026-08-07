import 'package:flutter/material.dart';
import '../../../../src/config/theme.dart';
import '../../../../src/models/job_model.dart';
import '../../../../src/providers/job_provider.dart';
import 'package:provider/provider.dart';

class TechnicianJobDetailScreen extends StatefulWidget {
  final String jobId;

  const TechnicianJobDetailScreen({super.key, required this.jobId});

  @override
  State<TechnicianJobDetailScreen> createState() =>
      _TechnicianJobDetailScreenState();
}

class _TechnicianJobDetailScreenState extends State<TechnicianJobDetailScreen> {
  // Local state for checking items before syncing or just sync directly?
  // Direct sync is better for simplicity.
  // We need to fetch the job.

  @override
  Widget build(BuildContext context) {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        // Find the job
        Job? job;
        try {
          job = jobProvider.jobs.firstWhere((j) => j.id == widget.jobId);
        } catch (e) {
          return const Scaffold(body: Center(child: Text("Job not found")));
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          appBar: AppBar(
            title: Text('${job.carMake} ${job.carModel}'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCarDetails(job),
                const SizedBox(height: AppSpacing.md),
                _buildChecklist(job, jobProvider),
                const SizedBox(height: AppSpacing.xl),
                _buildActionButtons(job, jobProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarDetails(Job job) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Registration:', style: AppTextStyles.bodySmall),
                Text(job.registration, style: AppTextStyles.h4),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service Type:', style: AppTextStyles.bodySmall),
                Text(
                  job.serviceType,
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Customer Notes:', style: AppTextStyles.bodySmall),
              Text(job.description, style: AppTextStyles.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(Job job, JobProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Checklist',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: job.checklist.map((item) {
              final isDone = job.completedChecklist.contains(item);
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      item,
                      style: TextStyle(
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Checkbox(
                      value: isDone,
                      activeColor: AppColors.success,
                      onChanged: (val) {
                        provider.toggleChecklistItem(job.id, item);
                      },
                    ),
                    onTap: () => provider.toggleChecklistItem(job.id, item),
                  ),
                  if (item != job.checklist.last)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Job job, JobProvider provider) {
    // Status flow: pending -> quoteSent -> inProgress -> ready -> completed.
    // 'ready' means "ready for customer pickup" — this is the same transition
    // triggered by the admin's "Mark Ready for Pickup" button in
    // admin_job_detail_screen.dart, so this button is just the technician-side
    // equivalent, not a separate status.
    if (job.status == JobStatus.ready || job.status == JobStatus.completed) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            job.status == JobStatus.completed
                ? 'Job Completed'
                : 'Ready for Pickup',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (job.status != JobStatus.inProgress) {
      // Job hasn't been started yet (e.g. quote not yet approved by customer)
      // — nothing for the technician to submit.
      return const SizedBox.shrink();
    }

    final allDone =
        job.checklist.isNotEmpty &&
        job.completedChecklist.length == job.checklist.length;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: allDone ? AppColors.success : AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: allDone
            ? () async {
                await provider.updateStatus(job.id, JobStatus.ready);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job marked ready for pickup!'),
                    ),
                  );
                }
              }
            : null,
        child: const Text(
          'Complete Job',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
