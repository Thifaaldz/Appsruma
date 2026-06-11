import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/payment.dart';
import '../providers/payment_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../models/boarding_house.dart';
import '../widgets/owner_widgets.dart';

class PaymentBillScreen extends StatefulWidget {
  const PaymentBillScreen({super.key});

  @override
  State<PaymentBillScreen> createState() => _PaymentBillScreenState();
}

class _PaymentBillScreenState extends State<PaymentBillScreen> {
  final _searchController = TextEditingController();
  DateTime? _selectedMonth;
  String _statusFilter = 'Semua Status';
  int? _propertyFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<PaymentProvider>().fetchPayments();
      context.read<BoardingHouseProvider>().fetchBoardingHouses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime _monthKey(DateTime date) => DateTime(date.year, date.month);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  List<DateTime> _monthOptions(List<Payment> payments) {
    final months = <DateTime>{};
    for (final payment in payments) {
      months.add(_monthKey(payment.dueDate));
    }
    final list = months.toList()..sort((a, b) => b.compareTo(a));
    return list;
  }

  bool _sameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _getPropertyName(int? id, List<BoardingHouse> houses) {
    if (id == null) return 'Kos';
    try {
      return houses.firstWhere((bh) => bh.id == id).name;
    } catch (_) {
      return 'Kos';
    }
  }

  List<Payment> _filteredPayments(List<Payment> payments, DateTime month) {
    final query = _searchController.text.trim().toLowerCase();
    return payments.where((payment) {
      if (!_sameMonth(payment.dueDate, month)) return false;

      if (_statusFilter == 'Lunas' && payment.status.toLowerCase() != 'paid') return false;
      if (_statusFilter == 'Belum Bayar' && payment.status.toLowerCase() == 'paid') return false;
      
      if (_propertyFilter != null && payment.tenant?.boardingHouseId != _propertyFilter) return false;

      if (query.isEmpty) return true;

      final tenantName = payment.tenant?.userName?.toLowerCase() ?? '';
      final roomNumber = payment.tenant?.roomNumber?.toLowerCase() ?? '';
      final billingPeriod = payment.billingPeriod.toLowerCase();
      return tenantName.contains(query) ||
          roomNumber.contains(query) ||
          billingPeriod.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();
    final bhProvider = context.watch<BoardingHouseProvider>();
    final monthOptions = _monthOptions(provider.payments);
    final currentMonth =
        _selectedMonth ??
        (monthOptions.isNotEmpty
            ? monthOptions.first
            : _monthKey(DateTime.now()));
    final payments = _filteredPayments(provider.payments, currentMonth);

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.darkOlive,
          onRefresh: provider.fetchPayments,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
                  ),
                  Expanded(
                    child: Text(
                      'List Tagihan Penghuni Bulanan',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _MonthSelector(
                  months: monthOptions,
                  selectedMonth: currentMonth,
                  formatMonth: _formatMonth,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedMonth = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              OwnerSearchBar(
                controller: _searchController,
                hintText: 'Search',
                trailingIcon: Icons.tune,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Semua Status',
                      isSelected: _statusFilter == 'Semua Status',
                      onSelected: (val) => setState(() => _statusFilter = 'Semua Status'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Belum Bayar',
                      isSelected: _statusFilter == 'Belum Bayar',
                      onSelected: (val) => setState(() => _statusFilter = 'Belum Bayar'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Lunas',
                      isSelected: _statusFilter == 'Lunas',
                      onSelected: (val) => setState(() => _statusFilter = 'Lunas'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Semua Kos',
                      isSelected: _propertyFilter == null,
                      onSelected: (val) => setState(() => _propertyFilter = null),
                    ),
                    ...bhProvider.boardingHouses.map(
                      (bh) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _FilterChip(
                          label: bh.name,
                          isSelected: _propertyFilter == bh.id,
                          onSelected: (val) => setState(() => _propertyFilter = bh.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.darkOlive),
                  ),
                )
              else if (provider.payments.isEmpty)
                const _EmptyState(
                  message: 'Belum ada tagihan pembayaran penghuni.',
                )
              else if (payments.isEmpty)
                const _EmptyState(message: 'Tidak ada tagihan di bulan ini.')
              else
                ...payments.map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PaymentBillCard(
                      payment: payment,
                      amountLabel: _formatCurrency(payment.amount),
                      monthLabel: payment.billingPeriod.isNotEmpty
                          ? payment.billingPeriod
                          : _formatMonth(payment.dueDate),
                      propertyName: _getPropertyName(payment.tenant?.boardingHouseId, bhProvider.boardingHouses),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.months,
    required this.selectedMonth,
    required this.formatMonth,
    required this.onChanged,
  });

  final List<DateTime> months;
  final DateTime selectedMonth;
  final String Function(DateTime) formatMonth;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = months.isNotEmpty ? months : <DateTime>[selectedMonth];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E1D4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DateTime>(
          value: selectedMonth,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          borderRadius: BorderRadius.circular(12),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((month) {
            return DropdownMenuItem<DateTime>(
              value: month,
              child: Text(formatMonth(month)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PaymentBillCard extends StatelessWidget {
  const _PaymentBillCard({
    required this.payment,
    required this.amountLabel,
    required this.monthLabel,
    required this.propertyName,
  });

  final Payment payment;
  final String amountLabel;
  final String monthLabel;
  final String propertyName;

  bool get _isPaid => payment.status.toLowerCase() == 'paid';

  @override
  Widget build(BuildContext context) {
    final tenantName = payment.tenant?.userName ?? 'Penghuni';
    final roomNumber = payment.tenant?.roomNumber ?? '-';
    final statusLabel = _isPaid ? 'Lunas' : 'Belum Bayar';
    final statusBg = _isPaid ? AppTheme.statusGreenBg : AppTheme.statusRedBg;
    final statusText = _isPaid
        ? AppTheme.statusGreenText
        : AppTheme.statusRedText;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFD9D9D9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Colors.white.withValues(alpha: 0.78),
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        tenantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(
                      label: statusLabel,
                      backgroundColor: statusBg,
                      textColor: statusText,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$propertyName $roomNumber | $amountLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 21),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        monthLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD8D8D8)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Icons.chevron_right, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppTheme.darkOlive,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textDark,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: isSelected ? AppTheme.darkOlive : const Color(0xFFD8D8D8),
        ),
      ),
    );
  }
}
