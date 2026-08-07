import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../config/theme.dart';

class PartsCatalogScreen extends StatelessWidget {
  const PartsCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(title: const Text('Parts Catalog')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPartDialog(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partsCatalog')
            .orderBy('partName')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Catalog is empty', style: AppTextStyles.h4),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  title: Text(
                    data['partName'] ?? 'Unknown',
                    style: AppTextStyles.h4,
                  ),
                  subtitle: Text(
                    'PN: ${data['partNumber']} • ${data['supplier']}',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Text(
                    'R${(data['unitPrice'] ?? 0).toStringAsFixed(2)}',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddPartDialog(BuildContext context) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final supplierController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Catalog'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Part Name'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Part Number'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Unit Price',
                  prefixText: 'R ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('partsCatalog')
                    .add({
                      'partName': nameController.text,
                      'partNumber': numberController.text,
                      'supplier': supplierController.text,
                      'unitPrice': double.tryParse(priceController.text) ?? 0.0,
                    });
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
