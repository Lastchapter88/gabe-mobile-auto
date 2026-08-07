import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../src/config/theme.dart';
import '../../../../src/models/job_model.dart';
import '../../../../src/models/quotation_model.dart';
import '../../../../src/models/part_item_model.dart';

class CreateQuotationScreen extends StatefulWidget {
  final String jobId;
  final Quotation? existingQuotation;

  const CreateQuotationScreen({
    super.key,
    required this.jobId,
    this.existingQuotation,
  });

  @override
  State<CreateQuotationScreen> createState() => _CreateQuotationScreenState();
}

class _CreateQuotationScreenState extends State<CreateQuotationScreen> {
  final TextEditingController _searchController = TextEditingController();
  late TextEditingController _labourController;
  List<PartItem> _selectedParts = [];
  bool _isSubmitting = false;

  // Mock parts catalog - Replace with Firebase collection in real app or use this for MVP
  final List<Map<String, dynamic>> _partsCatalog = [
    {'name': 'Brake Pads', 'price': 900.00, 'partNo': 'BRK-001'},
    {'name': 'Oil Filter', 'price': 150.00, 'partNo': 'OFLTR-E50.23'},
    {'name': 'Spark Plug', 'price': 80.00, 'partNo': 'SPRE-003'},
    {'name': 'Air Filter', 'price': 230.00, 'partNo': 'AF-004'},
    {'name': 'Alternator', 'price': 2500.00, 'partNo': 'ALTR-005'},
    {'name': 'Brake Fluid (1L)', 'price': 250.00, 'partNo': 'BFLUID-1L'},
  ];

  List<Map<String, dynamic>> _filteredParts = [];

  @override
  void initState() {
    super.initState();
    _filteredParts = _partsCatalog;

    if (widget.existingQuotation != null) {
      _selectedParts = List.from(widget.existingQuotation!.parts);
      _labourController = TextEditingController(
        text: widget.existingQuotation!.labourCost.toStringAsFixed(2),
      );
    } else {
      _labourController = TextEditingController();
    }
  }

  double get _partsSubtotal =>
      _selectedParts.fold(0, (sum, part) => sum + part.total);
  double get _labourCost => double.tryParse(_labourController.text) ?? 0;
  double get _subtotal => _partsSubtotal + _labourCost;
  double get _vat => _subtotal * 0.15;
  double get _grandTotal => _subtotal + _vat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Create Quotation'),
        actions: [IconButton(icon: const Icon(Icons.person), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Customer Header
                  _buildCustomerHeader(),

                  // Search/Add Parts Section
                  _buildSearchSection(),

                  // Selected Parts
                  if (_selectedParts.isNotEmpty) _buildSelectedParts(),

                  // Custom Part Button
                  _buildCustomPartButton(),

                  // Labour Section
                  _buildLabourSection(),

                  // Summary
                  _buildSummary(),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildCustomerHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .get(),
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
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.scaffoldBg,
                child: Text(
                  job.customerName.isNotEmpty
                      ? job.customerName[0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryBlue,
                  ),
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
                      '${job.carMake} ${job.carModel} - ${job.registration}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
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
          Text('Search / add Parts', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.sm),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'brake p',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _filteredParts = _partsCatalog;
                        });
                      },
                    ),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                ],
              ),
            ),
            onChanged: (value) {
              setState(() {
                _filteredParts = _partsCatalog
                    .where(
                      (part) => part['name'].toString().toLowerCase().contains(
                        value.toLowerCase(),
                      ),
                    )
                    .toList();
              });
            },
          ),

          // Search Results
          if (_searchController.text.isNotEmpty &&
              _filteredParts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredParts.length,
                itemBuilder: (context, index) {
                  final part = _filteredParts[index];
                  return ListTile(
                    title: Text(part['name'], style: AppTextStyles.bodyMedium),
                    subtitle: Text(
                      'Part No. ${part['partNo']}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Text(
                      'R${part['price'].toStringAsFixed(2)}',
                      style: AppTextStyles.h4,
                    ),
                    onTap: () => _addPartFromCatalog(part),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedParts() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: _selectedParts.asMap().entries.map((entry) {
          int index = entry.key;
          PartItem part = entry.value;
          return _buildPartCard(part, index);
        }).toList(),
      ),
    );
  }

  Widget _buildPartCard(PartItem part, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Quantity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
                Text(
                  'Purchase ${part.quantity}',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Part Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(part.partName, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'R${part.unitPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // Quantity Controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (part.quantity > 1) {
                    setState(() {
                      _selectedParts[index] = PartItem(
                        partName: part.partName,
                        unitPrice: part.unitPrice,
                        quantity: part.quantity - 1,
                      );
                    });
                  }
                },
              ),
              Text('${part.quantity}', style: AppTextStyles.bodyMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    _selectedParts[index] = PartItem(
                      partName: part.partName,
                      unitPrice: part.unitPrice,
                      quantity: part.quantity + 1,
                    );
                  });
                },
              ),
            ],
          ),

          // Total
          Text(
            'R${part.total.toStringAsFixed(2)}',
            style: AppTextStyles.h4.copyWith(color: AppColors.primaryBlue),
          ),

          // Remove Button
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: () => setState(() => _selectedParts.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: OutlinedButton(
        onPressed: _addCustomPart,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add),
            const SizedBox(width: AppSpacing.sm),
            const Text('Custom Part'),
          ],
        ),
      ),
    );
  }

  Widget _buildLabourSection() {
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
          Text('Labour', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _labourController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: 'R',
              hintText: '300.00',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
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
          Text('Summary', style: AppTextStyles.h4),
          const SizedBox(height: AppSpacing.md),

          _buildSummaryRow('Parts Subtotal', _partsSubtotal),
          _buildSummaryRow('Labour', _labourCost),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),

          _buildSummaryRow('Total', _subtotal),
          _buildSummaryRow('VAT (15%)', _vat),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grand Total', style: AppTextStyles.h3),
              Text(
                'R${_grandTotal.toStringAsFixed(2)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            'R${amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _saveDraft,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
              child: const Text('Save Draft'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _sendToCustomer,
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 56)),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send to Customer'),
            ),
          ),
        ],
      ),
    );
  }

  void _addPartFromCatalog(Map<String, dynamic> catalogPart) {
    setState(() {
      _selectedParts.add(
        PartItem(
          partName: catalogPart['name'],
          unitPrice: catalogPart['price'].toDouble(),
          quantity: 1,
        ),
      );
      _searchController.clear();
      _filteredParts = _partsCatalog;
    });
  }

  void _addCustomPart() {
    showDialog(
      context: context,
      builder: (context) => _CustomPartDialog(
        onAdd: (part) => setState(() => _selectedParts.add(part)),
      ),
    );
  }

  void _saveDraft() {
    // Implement draft saving logic if needed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _sendToCustomer() async {
    if (_selectedParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one part'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final isEditing = widget.existingQuotation != null;
      final docId = isEditing
          ? widget.existingQuotation!.id
          : FirebaseFirestore.instance.collection('quotations').doc().id;
      final createdAt = isEditing
          ? widget.existingQuotation!.createdAt
          : DateTime.now();

      Quotation quotation = Quotation(
        id: docId,
        jobId: widget.jobId,
        parts: _selectedParts,
        labourCost: _labourCost,
        tax: _vat,
        totalCost: _grandTotal,
        status: QuotationStatus
            .sent, // When editing, we might reset to 'sent' if it was 'declined'
        createdAt: createdAt,
      );

      await FirebaseFirestore.instance
          .collection('quotations')
          .doc(docId)
          .set(quotation.toMap());

      // Also update job status to quoteSent
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobId)
          .update({'status': 'quoteSent'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Quotation updated and sent!'
                  : 'Quotation sent to customer!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _labourController.dispose();
    super.dispose();
  }
}

// Custom Part Dialog - Private class
class _CustomPartDialog extends StatefulWidget {
  final Function(PartItem) onAdd;

  const _CustomPartDialog({required this.onAdd});

  @override
  State<_CustomPartDialog> createState() => _CustomPartDialogState();
}

class _CustomPartDialogState extends State<_CustomPartDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Part'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Part Name',
                hintText: 'Brake Fluid Flush',
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: 'R',
                hintText: '250.00',
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                PartItem(
                  partName: _nameController.text.trim(),
                  unitPrice: double.parse(_priceController.text),
                  quantity: 1,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
