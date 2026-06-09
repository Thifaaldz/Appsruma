class Payment {
  final int id;
  final int tenantId;
  final double amount;
  final String dueDate;
  final String overdueDate;
  final String billingPeriod;
  final String status;
  final String? midtransOrderId;
  final String? paidAt;
  final String paymentDate;
  final String createdAt;
  final String updatedAt;

  Payment({
    required this.id,
    required this.tenantId,
    this.amount = 0,
    this.dueDate = '',
    this.overdueDate = '',
    this.billingPeriod = '',
    this.status = 'pending',
    this.midtransOrderId,
    this.paidAt,
    this.paymentDate = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      tenantId: json['tenant_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      dueDate: json['due_date'] ?? '',
      overdueDate: json['overdue_date'] ?? '',
      billingPeriod: json['billing_period'] ?? '',
      status: json['status'] ?? 'pending',
      midtransOrderId: json['midtrans_order_id'],
      paidAt: json['paid_at'],
      paymentDate: json['payment_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'amount': amount,
      'due_date': dueDate,
      'status': status,
    };
  }

  /// Check if this payment is overdue
  bool get isOverdue => status == 'overdue';

  /// Check if this payment is pending (belum bayar)
  bool get isPending => status == 'pending' || status == 'overdue';

  /// Check if this payment is paid (lunas)
  bool get isPaid => status == 'paid';

  /// Parse due date
  DateTime? get dueDateParsed {
    try {
      return DateTime.parse(dueDate);
    } catch (_) {
      return null;
    }
  }

  /// Parse overdue date
  DateTime? get overdueDateParsed {
    try {
      return DateTime.parse(overdueDate);
    } catch (_) {
      return null;
    }
  }

  /// Days remaining until overdue (from now)
  int get daysUntilOverdue {
    final od = overdueDateParsed;
    if (od == null) return 0;
    return od.difference(DateTime.now()).inDays;
  }
}
