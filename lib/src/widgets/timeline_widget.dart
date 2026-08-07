import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/job_model.dart';

class TimelineWidget extends StatelessWidget {
  final JobStatus activeStatus;

  const TimelineWidget({super.key, required this.activeStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {
        'status': JobStatus.pending,
        'label': 'Booked',
        'icon': Icons.calendar_today,
      },
      {
        'status': JobStatus.quoteSent,
        'label': 'Quote',
        'icon': Icons.request_quote,
      },
      {'status': JobStatus.inProgress, 'label': 'Working', 'icon': Icons.build},
      {'status': JobStatus.ready, 'label': 'Ready', 'icon': Icons.car_repair},
      {
        'status': JobStatus.completed,
        'label': 'Done',
        'icon': Icons.check_circle,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          int idx = entry.key;
          var step = entry.value;
          JobStatus stepStatus = step['status'] as JobStatus;

          bool isCompleted = activeStatus.index > stepStatus.index;
          bool isActive = activeStatus == stepStatus;
          bool isFuture = activeStatus.index < stepStatus.index;

          Color circleColor;
          Color iconColor = Colors.white;

          if (isCompleted) {
            circleColor = AppColors.primaryBlue;
          } else if (isActive) {
            circleColor =
                AppColors.primaryBlue; // Active is also Blue in mockup
          } else {
            circleColor = Colors.white;
            iconColor = AppColors.textMuted;
          }

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Left Connector
                    Expanded(
                      child: Container(
                        height: 2,
                        color: idx == 0
                            ? Colors.transparent
                            : (isCompleted || isActive
                                  ? AppColors.primaryBlue
                                  : AppColors.border),
                      ),
                    ),
                    // Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFuture ? AppColors.border : circleColor,
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: circleColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 16,
                        color: iconColor,
                      ),
                    ),
                    // Right Connector
                    Expanded(
                      child: Container(
                        height: 2,
                        color: idx == steps.length - 1
                            ? Colors.transparent
                            : (isCompleted
                                  ? AppColors.primaryBlue
                                  : AppColors.border),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  step['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isFuture
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
