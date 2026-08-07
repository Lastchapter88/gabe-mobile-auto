import 'package:flutter/material.dart';

import '../../../../src/config/theme.dart';

import '../../dashboard/customer_dashboard_screen.dart';
import '../../technician/screens/technician_dashboard_screen.dart';
import '../../hr/screens/hr_dashboard_screen.dart';
import '../../../providers/job_provider.dart';
import 'package:provider/provider.dart';
// cleaned import
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      // Removed Drawer to match mockup clean look (or user can add back if needed)
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/app_icon.png', height: 24),
            const SizedBox(width: 8),
            Text(
              'GMA SYSTEMS',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildPortalSelectionContent()
          : _selectedIndex == 1
          ? _buildJobsTab()
          : const Center(child: Text("Section under construction")),
      bottomNavigationBar: _buildBottomNav(),
      // Removed FAB as it's not in the 'Welcome' mockup
    );
  }

  Widget _buildPortalSelectionContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('Welcome', style: AppTextStyles.h2.copyWith(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  'Select your workspace portal',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // Portal Cards
          _buildPortalCard(
            title: 'Technician Dashboard',
            subtitle: 'Enable jobs',
            icon: Icons.build,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechnicianDashboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildPortalCard(
            title: 'Customer Dashboard',
            subtitle: 'View and approve work',
            icon: Icons.directions_car,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerDashboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildPortalCard(
            title: 'HR Dashboard',
            subtitle: 'Manage staff records',
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HRDashboardScreen(),
                ),
              );
            },
          ),

          const Spacer(),
          // Footer
          Center(
            child: Text(
              'Powered by GMA Systems',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPortalCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
            // Mockup link to Reports/Stats? Maybe S2?
            // For now just keep placeholder
            // Or navigate to PartsCatalog if that was the intent
            // But usually nav bar switches body content.
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.brandPrimary,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, _) {
        final jobs = jobProvider.jobs;
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.brandPrimary,
            onPressed: () => _showAddJobDialog(context),
            child: const Icon(Icons.add),
          ),
          body: jobs.isEmpty
              ? const Center(child: Text('No active jobs'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.brandPrimaryLight,
                          child: const Icon(
                            Icons.build,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                        title: Text('${job.carMake} ${job.carModel}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.description),
                            if (job.technicianName != null)
                              Text(
                                'Tech: ${job.technicianName}',
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: job.status.toString().contains('completed')
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.pending, color: Colors.orange),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _showAddJobDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String customerName = '';
    String phoneNumber = '';
    String carMake = '';
    String carModel = '';
    String description = '';
    String? selectedTechId;
    String? selectedTechName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Job'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                        ),
                        onSaved: (v) => customerName = v!,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Phone'),
                        onSaved: (v) => phoneNumber = v!,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Make',
                              ),
                              onSaved: (v) => carMake = v!,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Model',
                              ),
                              onSaved: (v) => carModel = v!,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                        onSaved: (v) => description = v!,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      // Technician Dropdown
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('role', isEqualTo: 'technician')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final techs = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            value: selectedTechId,
                            hint: const Text('Assign Technician'),
                            items: techs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: doc.id,
                                child: Text(data['displayName'] ?? 'Unknown'),
                                onTap: () {
                                  selectedTechName = data['displayName'];
                                },
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => selectedTechId = val);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      // Logic to save job
                      try {
                        await FirebaseFirestore.instance.collection('jobs').add(
                          {
                            'customerName': customerName,
                            'phoneNumber': phoneNumber,
                            'carMake': carMake,
                            'carModel': carModel,
                            'carYear': 2024, // Default for now
                            'registration': 'NEW-JOB',
                            'serviceType': 'Repair',
                            'description': description,
                            'status': 'pending',
                            'serviceLocation': 'Workshop',
                            'technicianId': selectedTechId,
                            'technicianName': selectedTechName,
                            'createdAt': FieldValue.serverTimestamp(),
                            'updatedAt': FieldValue.serverTimestamp(),
                            'completedChecklist': [],
                            'userId':
                                'customer_placeholder', // Or link strictly
                          },
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job Created')),
                          );
                        }
                      } catch (e) {
                        debugPrint('Error creating job: $e');
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
