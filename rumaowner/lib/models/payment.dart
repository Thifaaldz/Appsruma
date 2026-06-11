import 'tenant.dart';

class Payment {
  final int id;
  final int tenantId;
  final double amount;
  final DateTime dueDate;
  final String billingPeriod;
  final DateTime paymentDate;
  final DateTime? paidAt;
  final String status;
  final DateTime createdAt;
  final Tenant? tenant;

  Payment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.dueDate,
    this.billingPeriod = '',
    required this.paymentDate,
    this.paidAt,
    required this.status,
    required this.createdAt,
    this.tenant,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      billingPeriod: json['billing_period'] ?? '',
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : DateTime.now(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
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
      'due_date': dueDate.toIso8601String(),
      'billing_period': billingPeriod,
      'payment_date': paymentDate.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
