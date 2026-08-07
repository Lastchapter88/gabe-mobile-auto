class InvoiceItem {
  final String description;
  final double amount;

  InvoiceItem({required this.description, required this.amount});

  Map<String, dynamic> toMap() {
    return {'description': description, 'amount': amount};
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }
}

class Invoice {
  final String id;
  final String jobId;
  final String customerName;
  final String customerVhicle; // make model year reg
  final int mileage;
  final DateTime? nextServiceDate;
  final List<InvoiceItem> items;
  final double totalAmount;
  final String status; // 'draft', 'issued', 'paid'
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.jobId,
    required this.customerName,
    required this.customerVhicle,
    required this.mileage,
    this.nextServiceDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'customerName': customerName,
      'customerVhicle': customerVhicle,
      'mileage': mileage,
      'nextServiceDate': nextServiceDate?.toIso8601String(),
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerVhicle: map['customerVhicle'] ?? '',
      mileage: map['mileage'] ?? 0,
      nextServiceDate: map['nextServiceDate'] != null
          ? DateTime.parse(map['nextServiceDate'])
          : null,
      items: List<InvoiceItem>.from(
        (map['items'] as List<dynamic>? ?? []).map<InvoiceItem>(
          (x) => InvoiceItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'draft',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
