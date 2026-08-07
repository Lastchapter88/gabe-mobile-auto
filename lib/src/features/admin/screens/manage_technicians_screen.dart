import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../src/config/theme.dart';

class ManageTechniciansScreen extends StatefulWidget {
  const ManageTechniciansScreen({super.key});

  @override
  State<ManageTechniciansScreen> createState() =>
      _ManageTechniciansScreenState();
}

class _ManageTechniciansScreenState extends State<ManageTechniciansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Manage Staff'),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Technicians'),
            Tab(text: 'All Users'),
            Tab(text: 'Timesheets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTechniciansList(),
          _buildAllUsersList(),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildTechniciansList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'technician')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final technicians = snapshot.data!.docs;

        if (technicians.isEmpty) {
          return Center(
            child: Text(
              "No technicians found.",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: technicians.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tech = technicians[index];
            final data = tech.data() as Map<String, dynamic>;
            final isApproved = data['isApproved'] == true;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isApproved
                      ? AppColors.primaryLight
                      : AppColors.textMuted.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: isApproved
                        ? AppColors.primaryBlue
                        : AppColors.textMuted,
                  ),
                ),
                title: Text(
                  data['displayName'] ?? 'Unknown Technician',
                  style: AppTextStyles.bodyLarge,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['email'] ?? '', style: AppTextStyles.bodySmall),
                    if (data['employeeId'] != null)
                      Text(
                        'ID: ${data['employeeId']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                trailing: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isApproved,
                    activeColor: AppColors.success,
                    onChanged: (value) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(tech.id)
                          .update({'isApproved': value});
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllUsersList() {
    return Column(
      children: [
        // Search could be added here
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isNotEqualTo: 'technician')
                .orderBy('role')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading users',
                    style: TextStyle(color: AppColors.error),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['role'] != 'admin';
              }).toList();

              if (users.isEmpty) {
                return Center(
                  child: Text(
                    "No eligible users found.",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: users.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final data = user.data() as Map<String, dynamic>;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.scaffoldBg,
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      title: Text(
                        data['displayName'] ?? 'Unknown User',
                        style: AppTextStyles.bodyLarge,
                      ),
                      subtitle: Text(
                        data['email'] ?? '',
                        style: AppTextStyles.bodySmall,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'technician') {
                            _appointTechnician(
                              context,
                              user.id,
                              data['displayName'],
                            );
                          } else if (value == 'hr') {
                            _appointHR(context, user.id, data['displayName']);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'technician',
                                child: Text('Appoint as Technician'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'hr',
                                child: Text('Appoint as HR Manager'),
                              ),
                            ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.sm,
                            ),
                          ),
                          child: Text(
                            'Appoint',
                            style: AppTextStyles.button.copyWith(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .where('status', isEqualTo: 'pending_approval')
          .orderBy('clockIn', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data!.docs;

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.success.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'All timesheets approved!',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: entries.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final data = entry.data() as Map<String, dynamic>;
            final userId = data['userId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, userSnapshot) {
                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>?;
                final userName = userData?['displayName'] ?? 'Unknown User';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    title: Text(userName, style: AppTextStyles.bodyLarge),
                    subtitle: Text(
                      'Duration: ${data['durationMinutes'] ?? 'N/A'} mins',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          onPressed: () => _approveAttendance(entry.id),
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: AppColors.error,
                          ),
                          onPressed: () => _rejectAttendance(entry.id),
                          tooltip: 'Reject',
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _approveAttendance(String docId) async {
    await FirebaseFirestore.instance.collection('attendance').doc(docId).update(
      {'status': 'approved', 'approvedAt': FieldValue.serverTimestamp()},
    );
  }

  Future<void> _rejectAttendance(String docId) async {
    await FirebaseFirestore.instance.collection('attendance').doc(docId).update(
      {'status': 'rejected', 'rejectedAt': FieldValue.serverTimestamp()},
    );
  }

  void _appointHR(BuildContext context, String userId, String? name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Appoint $name as HR Manager'),
        content: const Text(
          'Are you sure you want to grant HR access to this user?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({'role': 'hr', 'isApproved': true});
                if (context.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('HR Manager appointed successfully'),
                  ),
                );
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _appointTechnician(BuildContext context, String userId, String? name) {
    final employeeIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Appoint $name as Technician'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Employee Number to confirm appointment:'),
            const SizedBox(height: 16),
            TextField(
              controller: employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (employeeIdController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                        'role': 'technician',
                        'employeeId': employeeIdController.text.trim(),
                        'isApproved':
                            true, // Auto-approve when appointed by admin
                      });
                  if (context.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Technician appointed successfully'),
                    ),
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
