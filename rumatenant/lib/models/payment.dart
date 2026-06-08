class Payment {
  final int id;
  final int tenantId;
  final double amount;
  final String paymentDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.tenantId,
    this.amount = 0,
    this.paymentDate = '',
    this.status = 'pending',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentDate: json['payment_date'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'amount': amount,
      'payment_date': paymentDate,
      'status': status,
    };
  }
}
