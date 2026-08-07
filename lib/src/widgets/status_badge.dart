import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/job_model.dart';

class StatusBadge extends StatelessWidget {
  final JobStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case JobStatus.pending:
        color = AppColors.statusBooked;
        text = 'Booked';
        break;
      case JobStatus.quoteSent:
        color = AppColors.statusQuoted;
        text = 'Quoted';
        break;
      case JobStatus.inProgress:
        color = AppColors.statusWorking;
        text = 'In Progress';
        break;
      case JobStatus.ready:
        color = AppColors.statusReady;
        text = 'Ready';
        break;
      case JobStatus.completed:
        color = AppColors.statusCompleted;
        text = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
