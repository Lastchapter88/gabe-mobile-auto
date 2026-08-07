import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/invoice_model.dart';
import '../../../models/job_model.dart';
import '../services/invoice_service.dart';

class GenerateInvoiceScreen extends StatefulWidget {
  final Job job;
  final Invoice? existingInvoice;

  const GenerateInvoiceScreen({
    super.key,
    required this.job,
    this.existingInvoice,
  });

  @override
  State<GenerateInvoiceScreen> createState() => _GenerateInvoiceScreenState();
}

class _GenerateInvoiceScreenState extends State<GenerateInvoiceScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _mileageController;
  late TextEditingController _nextServiceController; // Could be date picker
  DateTime? _nextServiceDate;

  List<InvoiceItem> _items = [];
  bool _isSaving = false;

  // Helper controllers for dynamic list?
  // We'll regenerate them on build or simpler: just edit dialogs.

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    Invoice? invoice = widget.existingInvoice;
    invoice ??= await _invoiceService.getInvoiceByJobId(widget.job.id);

    if (invoice != null) {
      _mileageController = TextEditingController(
        text: invoice.mileage.toString(),
      );
      _nextServiceDate = invoice.nextServiceDate;
      _items = List.from(invoice.items);
      _nextServiceController = TextEditingController(
        text: _nextServiceDate != null
            ? DateFormat('yyyy-MM-dd').format(_nextServiceDate!)
            : '',
      );
    } else {
      final draft = _invoiceService.createDraftFromJob(widget.job);
      _mileageController = TextEditingController(text: '');
      _nextServiceDate = DateTime.now().add(const Duration(days: 365));
      _items = List.from(draft.items);
      _nextServiceController = TextEditingController(
        text: _nextServiceDate != null
            ? DateFormat('yyyy-MM-dd').format(_nextServiceDate!)
            : '',
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.amount);

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) {
        String desc = '';
        String price = '';
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => desc = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price (ZAR)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => price = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (desc.isNotEmpty && price.isNotEmpty) {
                  setState(() {
                    _items.add(
                      InvoiceItem(
                        description: desc,
                        amount: double.tryParse(price) ?? 0.0,
                      ),
                    );
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

  Future<void> _saveInvoice({required String status}) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final invoice = Invoice(
        id:
            widget.existingInvoice?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(), // Simplify ID gen
        jobId: widget.job.id,
        customerName: widget.job.customerName,
        customerVhicle:
            '${widget.job.carYear ?? ''} ${widget.job.carMake} ${widget.job.carModel} (${widget.job.registration})',
        mileage: int.tryParse(_mileageController.text) ?? 0,
        nextServiceDate: _nextServiceDate,
        items: _items,
        totalAmount: _total,
        status: status,
        createdAt: DateTime.now(),
      );

      await _invoiceService.saveInvoice(invoice);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invoice $status successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Generate Invoice')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Info (Read Only from Job)
            Card(
              child: ListTile(
                title: Text(widget.job.customerName),
                subtitle: Text(
                  '${widget.job.carMake} ${widget.job.carModel} (${widget.job.registration})',
                ),
                trailing: Text(
                  widget.job.serviceType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Mileage & Next Service
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Current Mileage (km)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _nextServiceController,
                    decoration: const InputDecoration(
                      labelText: 'Next Service Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            _nextServiceDate ??
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                      );
                      if (date != null) {
                        setState(() {
                          _nextServiceDate = date;
                          _nextServiceController.text = DateFormat(
                            'yyyy-MM-dd',
                          ).format(date);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Items List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Invoice Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                ),
              ],
            ),
            ..._items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'R ${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _items.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: R ${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveInvoice(status: 'draft'),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveInvoice(status: 'issued'),
                    child: const Text('Issue Invoice'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
