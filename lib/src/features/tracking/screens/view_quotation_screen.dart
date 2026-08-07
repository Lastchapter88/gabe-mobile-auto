import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../src/config/theme.dart';
import '../../../../src/models/job_model.dart';
import '../../../../src/models/quotation_model.dart';
// import '../../services/quotation_service.dart'; // Using inline firestore for now

class ViewQuotationScreen extends StatelessWidget {
  final String jobId;

  const ViewQuotationScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('View Quotation'),
        actions: [IconButton(icon: const Icon(Icons.person), onPressed: () {})],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quotations')
            .where('jobId', isEqualTo: jobId)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No quotation available'));
          }

          Quotation quotation = Quotation.fromFirestore(
            snapshot.data!.docs.first,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Job Header
                      _buildJobHeader(context),

                      // Quotation Details
                      _buildQuotationDetails(quotation),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              if (quotation.status == QuotationStatus.sent)
                _buildBottomActions(context, quotation),
            ],
          );
        },
      ),
    );
  }

  Widget _buildJobHeader(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        Job job = Job.fromFirestore(snapshot.data!);

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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: const Icon(
                  Icons.build,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.serviceType, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      '${job.carMake} ${job.carModel} • ${job.registration}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Awaiting Approval',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuotationDetails(Quotation quotation) {
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
          Text('Quotation', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),

          // Parts
          ...quotation.parts.map((part) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(part.partName, style: AppTextStyles.bodyMedium),
                  ),
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

          const Divider(height: 24),

          // Labour
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Labour', style: AppTextStyles.bodyMedium),
                Text(
                  'R${quotation.labourCost.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // VAT
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('VAT @ 15%', style: AppTextStyles.bodyMedium),
                Text(
                  'R${quotation.tax.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.h3),
              Text(
                'R${quotation.totalCost.toStringAsFixed(2)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Quotation quotation) {
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
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _approveQuotation(context, quotation),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Approve Quote'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => _requestChanges(context, quotation),
              child: const Text('Request Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveQuotation(
    BuildContext context,
    Quotation quotation,
  ) async {
    // await QuotationService().approveQuotation(quotation.id, quotation.jobId);

    // Inline service logic
    await FirebaseFirestore.instance
        .collection('quotations')
        .doc(quotation.id)
        .update({'status': 'approved'});
    // Set job status to inProgress
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(quotation.jobId)
        .update({'status': 'inProgress'});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quotation approved!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  Future<void> _requestChanges(
    BuildContext context,
    Quotation quotation,
  ) async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Changes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Describe changes needed...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // await QuotationService().declineQuotation(quotation.id, controller.text);
              await FirebaseFirestore.instance
                  .collection('quotations')
                  .doc(quotation.id)
                  .update({
                    'status': 'declined', // or 'changesRequested'
                    // 'notes': controller.text
                  });

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
