import 'package:cloud_firestore/cloud_firestore.dart';
import 'part_item_model.dart';

enum QuotationStatus { draft, sent, approved, declined }

class Quotation {
  final String id;
  final String jobId;
  final List<PartItem> parts;
  final double labourCost;
  final double tax;
  final double totalCost;
  final QuotationStatus status;
  final DateTime createdAt;

  Quotation({
    required this.id,
    required this.jobId,
    required this.parts,
    required this.labourCost,
    required this.tax,
    required this.totalCost,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'parts': parts.map((x) => x.toMap()).toList(),
      'labourCost': labourCost,
      'tax': tax,
      'totalCost': totalCost,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Quotation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Quotation(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      parts: List<PartItem>.from(
        (data['parts'] ?? []).map((x) => PartItem.fromMap(x)),
      ),
      labourCost: (data['labourCost'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      totalCost: (data['totalCost'] ?? 0).toDouble(),
      status: QuotationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'draft'),
        orElse: () => QuotationStatus.draft,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
