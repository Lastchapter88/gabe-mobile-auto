class PartItem {
  final String partName;
  final double unitPrice;
  final int quantity;

  PartItem({
    required this.partName,
    required this.unitPrice,
    required this.quantity,
  });

  double get total => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {'partName': partName, 'unitPrice': unitPrice, 'quantity': quantity};
  }

  factory PartItem.fromMap(Map<String, dynamic> map) {
    return PartItem(
      partName: map['partName'] ?? '',
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}
