import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; // Added for base64Decode
import '../../../../src/config/theme.dart';
import '../../../../src/models/job_model.dart';
import '../../../../src/models/job_task_model.dart';
import '../../../../src/models/quotation_model.dart';
import 'create_quotation_screen.dart';

import '../../invoicing/screens/generate_invoice_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../chat/screens/chat_screen.dart'; // Import ChatScreen
import 'package:provider/provider.dart';
import '../../../../src/providers/job_provider.dart';

class AdminJobWorkspaceScreen extends StatefulWidget {
  final String jobId;

  // Constructor to accept jobId (and optional data if passed, but relying on ID for stream)
  const AdminJobWorkspaceScreen({
    super.key,
    required this.jobId,
    Map<String, dynamic>? data,
  });

  @override
  State<AdminJobWorkspaceScreen> createState() =>
      _AdminJobWorkspaceScreenState();
}

class _AdminJobWorkspaceScreenState extends State<AdminJobWorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Admin Job Workspace'),
        actions: [IconButton(icon: const Icon(Icons.person), onPressed: () {})],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Job not found"));
          }

          Job job = Job.fromFirestore(snapshot.data!);
          final jobProvider = Provider.of<JobProvider>(context, listen: false);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Customer Header
                      _buildCustomerHeader(job),

                      // Technician Assignment
                      _buildTechnicianSection(context, job, jobProvider),

                      // Licence Disc
                      _buildLicenceDiscSection(job),

                      // Licence Disc Photo
                      _buildLicencePhotoSection(job),

                      // Job Checklist
                      _buildJobChecklist(job),

                      // Quotation Section
                      _buildQuotationSection(job),
                    ],
                  ),
                ),
              ),

              // Bottom Action Buttons
              _buildBottomActions(job),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerHeader(Job job) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.scaffoldBg,
            child: Text(
              job.customerName.isNotEmpty
                  ? job.customerName[0].toUpperCase()
                  : 'U',
              style: AppTextStyles.h3.copyWith(color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.customerName, style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  '${job.carMake} ${job.carModel} • ${job.registration}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: AppColors.primaryBlue),
            onPressed: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: job.phoneNumber);
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not launch ${job.phoneNumber}'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: AppColors.primaryBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    jobId: job.id,
                    currentUserId:
                        FirebaseAuth.instance.currentUser?.uid ?? 'admin',
                    userRole: 'admin',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLicenceDiscSection(Job job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F5596), Color(0xFF1E3A5F)],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              child: const Icon(
                Icons.badge,
                color: AppColors.primaryBlue,
                size: 32,
              ),
              // Use actual image if available in Job model
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Licence Disc',
                  style: AppTextStyles.h4.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.carMake} ${job.registration}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildLicencePhotoSection(Job job) {
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
          Text('Issue & Images', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.sm),
          Text(
            job.description.isEmpty
                ? 'No description provided.'
                : job.description,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('jobs')
                .doc(job.id)
                .collection('images')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const SizedBox();

              final licenceDocs = docs
                  .where((d) => d.id == 'licenceDisc')
                  .toList();
              final otherDocs = docs
                  .where((d) => d.id != 'licenceDisc')
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (licenceDocs.isNotEmpty) ...[
                    Text('Licence Disc:', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    _buildBase64Image(licenceDocs.first['base64']),
                    const SizedBox(height: 16),
                  ],
                  if (otherDocs.isNotEmpty) ...[
                    Text('Additional Images:', style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: otherDocs.map((d) {
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: _buildBase64Image(d['base64']),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return const SizedBox();
    try {
      // Need dart:convert imported
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      );
    } catch (e) {
      return const Icon(Icons.error);
    }
  }

  Widget _buildJobChecklist(Job job) {
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
          Text('Job Checklist', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jobTasks')
                .where('jobId', isEqualTo: widget.jobId)
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              List<JobTask> tasks = snapshot.data!.docs
                  .map((doc) => JobTask.fromFirestore(doc))
                  .toList();

              if (tasks.isEmpty) {
                // Nothing to show, maybe show empty state or allowing add
              }

              return Column(
                children: [
                  ...tasks.map((task) => _buildTaskItem(task)),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _addTask(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(JobTask task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            onChanged: (value) async {
              await FirebaseFirestore.instance
                  .collection('jobTasks')
                  .doc(task.id)
                  .update({'completed': value});
            },
            activeColor: AppColors.success,
          ),
          Expanded(
            child: Text(
              task.taskName,
              style: AppTextStyles.bodyMedium.copyWith(
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Icon(
            Icons.check_circle,
            color: task.completed ? AppColors.success : AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationSection(Job job) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quotations')
          .where('jobId', isEqualTo: widget.jobId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        Quotation quotation = Quotation.fromFirestore(
          snapshot.data!.docs.first,
        );

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quotation', style: AppTextStyles.h4),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateQuotationScreen(
                            jobId: widget.jobId,
                            existingQuotation: quotation,
                          ),
                        ),
                      );
                    },
                    child: const Text('View/Edit'),
                  ),
                ],
              ),
              const Divider(),
              ...quotation.parts.map((part) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.build_circle,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          part.partName,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Text(
                        '${part.quantity} x R${part.unitPrice}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'R${part.total.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VAT - ${(quotation.tax / (quotation.totalCost - quotation.tax) * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    'R${quotation.tax.toStringAsFixed(2)}',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.bodyMedium),
                  Text(
                    'R${quotation.totalCost.toStringAsFixed(2)}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomActions(Job job) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.statusInProgress.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  // Removed const here as style is not const
                  'Current Status',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  job.status.toString().split('.').last.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.statusInProgress,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Invoice Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenerateInvoiceScreen(job: job),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Generate / View Invoice'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Main Action Button
          if (job.status == JobStatus.pending)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateQuotationScreen(jobId: widget.jobId),
                    ),
                  );
                },
                child: Text('Create Quotation', style: AppTextStyles.button),
              ),
            )
          else if (job.status == JobStatus.inProgress)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(widget.jobId)
                      .update({'status': 'ready'});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusReady,
                ),
                child: Text(
                  'Mark Ready for Pickup',
                  style: AppTextStyles.button,
                ),
              ),
            )
          else if (job.status == JobStatus.ready)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(widget.jobId)
                      .update({'status': 'completed'});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                child: Text('Mark Completed', style: AppTextStyles.button),
              ),
            ),
        ],
      ),
    );
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Task name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('jobTasks').add({
                    'jobId': widget.jobId,
                    'taskName': controller.text,
                    'completed': false,
                    'order': DateTime.now().millisecondsSinceEpoch,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTechnicianSection(
    BuildContext context,
    Job job,
    JobProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.statusWorking.withOpacity(0.1),
            child: const Icon(Icons.settings, color: AppColors.statusWorking),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Technician', style: AppTextStyles.bodySmall),
                Text(
                  job.technicianName ?? 'Unassigned',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                _showAssignTechnicianDialog(context, job, provider),
            child: Text(job.technicianId == null ? 'Assign' : 'Change'),
          ),
        ],
      ),
    );
  }

  void _showAssignTechnicianDialog(
    BuildContext context,
    Job job,
    JobProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Technician'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'technician')
                .where('isApproved', isEqualTo: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No active technicians found.');
              }

              final techs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                itemCount: techs.length,
                itemBuilder: (context, index) {
                  final data = techs[index].data() as Map<String, dynamic>;
                  final name = data['displayName'] ?? 'Unknown';
                  final email = data['email'] ?? '';
                  final uid = techs[index].id;

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name),
                    subtitle: Text(email),
                    selected: job.technicianId == uid,
                    onTap: () {
                      provider.assignTechnician(job.id, uid, name);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Assigned to $name')),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
