import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_model.dart';
import '../config/theme.dart';
import 'status_badge.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final bool isCompact;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompact(context);
    }
    return _buildExpanded(context);
  }

  Widget _buildExpanded(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vehicle Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_outlined, // Cog icon from mockup
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Job Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.serviceType, style: AppTextStyles.h4),
                  const SizedBox(height: 2),
                  Text(
                    '${job.carMake} ${job.carModel}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    job.registration,
                    style: AppTextStyles.bodySmall.copyWith(letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        job.serviceLocation == 'Mobile'
                            ? Icons.directions_car
                            : Icons.build,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(job.serviceLocation, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),

            // Badge (No chevron in expanded/current job mockup)
            StatusBadge(status: job.status),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Smaller Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                job.status == JobStatus.completed
                    ? Icons.check_circle_outline
                    : Icons.history,
                color: job.status == JobStatus.completed
                    ? AppColors.success
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.serviceType,
                    style: AppTextStyles.h4.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(
                      job.createdAt,
                    ), // Assuming createdAt exists or similar
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Requires intl package or simple conversion
    return DateFormat('MMM d, yyyy').format(date);
  }
}
