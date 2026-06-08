import 'tenant.dart';

class Payment {
  final int id;
  final int tenantId;
  final double amount;
  final DateTime paymentDate;
  final String status;
  final DateTime createdAt;
  final Tenant? tenant;

  Payment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.createdAt,
    this.tenant,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
