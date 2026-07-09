import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/payment.dart';
import '../providers/tenant_provider.dart';
import '../widgets/tenant_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'Semua';

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _mapStatusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'paid') return 'Lunas';
    if (s == 'pending') return 'Belum Bayar';
    if (s == 'overdue') return 'Overdue';
    if (s == 'cancelled') return 'Dibatalkan';
    return status;
  }

  bool _isPaid(String status) {
    return status.toLowerCase() == 'paid';
  }

  String _periodLabel(Payment item) {
    if (item.billingPeriod.isNotEmpty) return item.billingPeriod;
    try {
      final date = DateTime.parse(
        item.dueDate.isNotEmpty ? item.dueDate : item.paymentDate,
      );
      return DateFormat('MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '-';
    }
  }

  String _paymentDateLabel(Payment item) {
    final paid = _isPaid(item.status);
    if (paid && item.paidAt != null && item.paidAt!.isNotEmpty) {
      try {
        final paidDate = DateTime.parse(item.paidAt!);
        return 'Dibayar ${DateFormat('d MMMM yyyy', 'id_ID').format(paidDate)}';
      } catch (_) {
        return 'Dibayar';
      }
    }

    try {
      final dueDate = DateTime.parse(
        item.dueDate.isNotEmpty ? item.dueDate : item.paymentDate,
      );
      return 'Jatuh tempo ${DateFormat('d MMMM yyyy', 'id_ID').format(dueDate)}';
    } catch (_) {
      return '-';
    }
  }

  String _fileSafe(String value) {
    return value
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> _downloadInvoice(Payment item, TenantProvider tp) async {
    final tenantName = tp.user?.name ?? 'Penghuni';
    final roomNumber = tp.room?.roomNumber ?? '-';
    final boardingHouseName = tp.boardingHouse?.name ?? 'Kos RUMA';
    final statusLabel = _mapStatusLabel(item.status);
    final invoiceNumber = 'INV-RUMA-${item.id.toString().padLeft(5, '0')}';
    final periodLabel = _periodLabel(item);
    final dateLabel = _paymentDateLabel(item);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RUMA',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Invoice Pembayaran Kos',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      statusLabel.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 28),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _invoiceInfo('Nomor Invoice', invoiceNumber),
                  _invoiceInfo(
                    'Tanggal Cetak',
                    DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now()),
                    alignEnd: true,
                  ),
                ],
              ),
              pw.SizedBox(height: 22),
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 22),
              pw.Text(
                'Ditagihkan Kepada',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(tenantName),
              pw.Text('$boardingHouseName - Kamar $roomNumber'),
              pw.SizedBox(height: 22),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: .6),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                    ),
                    children: [
                      _tableCell('Deskripsi', bold: true),
                      _tableCell('Periode', bold: true),
                      _tableCell('Nominal', bold: true, alignEnd: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _tableCell('Pembayaran sewa kamar kos'),
                      _tableCell(periodLabel),
                      _tableCell(_formatCurrency(item.amount), alignEnd: true),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        _formatCurrency(item.amount),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Text(dateLabel, style: const pw.TextStyle(fontSize: 11)),
              if (item.midtransOrderId != null &&
                  item.midtransOrderId!.isNotEmpty)
                pw.Text(
                  'Order ID: ${item.midtransOrderId}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              pw.Spacer(),
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Text(
                'Invoice ini dibuat otomatis oleh aplikasi RUMA.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Invoice_${invoiceNumber}_${_fileSafe(periodLabel)}.pdf',
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal membuat invoice.')));
    }
  }

  pw.Widget _invoiceInfo(String label, String value, {bool alignEnd = false}) {
    return pw.Column(
      crossAxisAlignment: alignEnd
          ? pw.CrossAxisAlignment.end
          : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  pw.Widget _tableCell(
    String text, {
    bool bold = false,
    bool alignEnd = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: alignEnd ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TenantProvider>();
    final payments = tp.payments;

    final visibleItems = payments.where((item) {
      final label = _mapStatusLabel(item.status);
      if (_selectedFilter == 'Lunas') return label == 'Lunas';
      if (_selectedFilter == 'Belum Lunas') {
        return label != 'Lunas';
      }
      return true;
    }).toList();

    final paidCount = payments.where((item) => _isPaid(item.status)).length;
    final unpaidCount = payments.length - paidCount;

    return SafeArea(
      bottom: false,
      child: tp.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.olive),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const RumaBrandLogo(height: 22),
                  const SizedBox(height: 34),
                  const RumaPageTitle(title: 'Riwayat Pembayaran'),
                  const SizedBox(height: 24),
                  RumaPanel(
                    padding: const EdgeInsets.all(6),
                    backgroundColor: const Color(0xFFF8F0E4),
                    borderColor: const Color(0xFFEADCC7),
                    child: Row(
                      children: [
                        _PaymentFilterButton(
                          label: 'Semua',
                          count: payments.length,
                          icon: Icons.receipt_long_outlined,
                          selected: _selectedFilter == 'Semua',
                          onTap: () =>
                              setState(() => _selectedFilter = 'Semua'),
                        ),
                        const SizedBox(width: 6),
                        _PaymentFilterButton(
                          label: 'Lunas',
                          count: paidCount,
                          icon: Icons.check_circle_outline,
                          selected: _selectedFilter == 'Lunas',
                          onTap: () =>
                              setState(() => _selectedFilter = 'Lunas'),
                        ),
                        const SizedBox(width: 6),
                        _PaymentFilterButton(
                          label: 'Belum Lunas',
                          count: unpaidCount,
                          icon: Icons.schedule_outlined,
                          selected: _selectedFilter == 'Belum Lunas',
                          onTap: () =>
                              setState(() => _selectedFilter = 'Belum Lunas'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (visibleItems.isEmpty)
                    RumaPanel(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat pembayaran',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    RumaPanel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: visibleItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            children: [
                              _HistoryItemRow(
                                item: item,
                                formatCurrency: _formatCurrency,
                                mapStatusLabel: _mapStatusLabel,
                                isPaid: _isPaid,
                                periodLabel: _periodLabel,
                                dateLabel: _paymentDateLabel,
                                onInvoice: () => _downloadInvoice(item, tp),
                              ),
                              if (index != visibleItems.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _HistoryItemRow extends StatelessWidget {
  const _HistoryItemRow({
    required this.item,
    required this.formatCurrency,
    required this.mapStatusLabel,
    required this.isPaid,
    required this.periodLabel,
    required this.dateLabel,
    required this.onInvoice,
  });

  final Payment item;
  final String Function(double) formatCurrency;
  final String Function(String) mapStatusLabel;
  final bool Function(String) isPaid;
  final String Function(Payment) periodLabel;
  final String Function(Payment) dateLabel;
  final VoidCallback onInvoice;

  @override
  Widget build(BuildContext context) {
    final paid = isPaid(item.status);
    final overdue = item.isOverdue;
    final statusLabel = mapStatusLabel(item.status);
    final periodText = periodLabel(item);
    final dateText = dateLabel(item);

    Color bgColor = paid ? AppTheme.statusMintBg : AppTheme.statusYellowBg;
    Color iconColor = paid
        ? AppTheme.statusGreenText
        : AppTheme.statusYellowText;
    IconData iconData = paid ? Icons.check_circle_outline : Icons.access_time;
    Color chipBg = paid ? AppTheme.statusGreenBg : AppTheme.statusYellowBg;
    Color chipText = paid
        ? AppTheme.statusGreenText
        : AppTheme.statusYellowText;

    if (overdue) {
      bgColor = const Color(0xFFFDE8E8);
      iconColor = const Color(0xFFB23A48);
      iconData = Icons.warning_amber_rounded;
      chipBg = const Color(0xFFFDE8E8);
      chipText = const Color(0xFFB23A48);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  periodText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 146),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(item.amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: RumaStatusChip(
                        label: statusLabel,
                        backgroundColor: chipBg,
                        textColor: chipText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: 'Download invoice',
                      child: InkWell(
                        onTap: onInvoice,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppTheme.olive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.download_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
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

class _PaymentFilterButton extends StatelessWidget {
  const _PaymentFilterButton({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.olive : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppTheme.olive : const Color(0xFFEADCC7),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? Colors.white : AppTheme.textDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : AppTheme.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
