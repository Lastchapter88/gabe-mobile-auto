import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/invoice_model.dart';
import '../../../models/job_model.dart';

class InvoiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or Update Invoice
  Future<void> saveInvoice(Invoice invoice) async {
    await _firestore
        .collection('invoices')
        .doc(invoice.id)
        .set(invoice.toMap());

    // Optionally index it in the Job doc for easy access, or just rely on jobId query
    // If status is 'issued', we might want to update the Job status or flag
    if (invoice.status == 'issued') {
      await _firestore.collection('jobs').doc(invoice.jobId).update({
        'hasInvoice': true,
        'invoiceId': invoice.id,
      });
    }
  }

  // Get Invoice by Job ID
  Future<Invoice?> getInvoiceByJobId(String jobId) async {
    final snapshot = await _firestore
        .collection('invoices')
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Invoice.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  // Create Draft from Job
  Invoice createDraftFromJob(Job job) {
    return Invoice(
      id: _firestore.collection('invoices').doc().id,
      jobId: job.id,
      customerName: job.customerName,
      customerVhicle:
          '${job.carYear ?? ''} ${job.carMake} ${job.carModel} (${job.registration})',
      mileage: 0, // Admin to fill
      items: [
        InvoiceItem(description: job.serviceType, amount: 0.0), // Base item
      ],
      totalAmount: 0.0,
      status: 'draft',
      createdAt: DateTime.now(),
    );
  }
}
