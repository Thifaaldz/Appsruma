import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/theme.dart';
import '../models/payment.dart';
import '../models/expense.dart';
import '../providers/payment_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/boarding_house_provider.dart';
import '../widgets/owner_widgets.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _mode = 'Mingguan'; // 'Mingguan' or 'Bulanan'
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<int> _years = [2024, 2025, 2026, 2027];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final bhId = context.read<BoardingHouseProvider>().selectedBoardingHouse?.id;
      context.read<PaymentProvider>().fetchPayments(boardingHouseId: bhId);
      context.read<ExpenseProvider>().fetchExpenses(boardingHouseId: bhId);
    });
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Future<void> _generatePdfReport(List<Payment> payments, List<Expense> expenses, double totalIncome, double totalExpense, double netProfit) async {
    final pdf = pw.Document();

    final periodLabel = _mode == 'Mingguan'
        ? '${_months[_selectedMonth - 1]} $_selectedYear'
        : 'Tahun $_selectedYear';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('LAPORAN KEUANGAN RUMA', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Periode: $periodLabel', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 15),

            // Summary Table
            pw.Text('Ringkasan Keuangan', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Kategori', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Total Nominal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Pendapatan')),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(_formatCurrency(totalIncome))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total Pengeluaran')),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(_formatCurrency(totalExpense))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Laba Bersih', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(_formatCurrency(netProfit), style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Details Table
            pw.Text('Detail Transaksi', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tanggal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tipe', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Deskripsi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Nominal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...payments.map((p) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(DateFormat('dd/MM/yyyy').format(p.paymentDate))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pendapatan')),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Bayar Kos - ${p.tenant?.userName ?? "Tenant"} (${p.billingPeriod})')),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(_formatCurrency(p.amount))),
                  ],
                )),
                ...expenses.map((e) => pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(DateFormat('dd/MM/yyyy').format(e.date))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pengeluaran')),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${e.title} [${e.category}]')),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(_formatCurrency(e.amount))),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_Keuangan_Ruma_${periodLabel.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    // 1. Get database records
    final allPayments = paymentProvider.payments.where((p) => p.status == 'paid').toList();
    final allExpenses = expenseProvider.expenses;

    // 2. Filter based on selected month & year
    List<Payment> filteredPayments = [];
    List<Expense> filteredExpenses = [];

    if (_mode == 'Mingguan') {
      // Filter to current selected month and year
      filteredPayments = allPayments.where((p) =>
          p.paymentDate.month == _selectedMonth && p.paymentDate.year == _selectedYear).toList();
      filteredExpenses = allExpenses.where((e) =>
          e.date.month == _selectedMonth && e.date.year == _selectedYear).toList();
    } else {
      // Filter to selected year
      filteredPayments = allPayments.where((p) => p.paymentDate.year == _selectedYear).toList();
      filteredExpenses = allExpenses.where((e) => e.date.year == _selectedYear).toList();
    }

    // 3. Totals
    final totalIncome = filteredPayments.fold<double>(0, (sum, p) => sum + p.amount);
    final totalExpense = filteredExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netProfit = totalIncome - totalExpense;

    // 4. Group data for chart & list
    final List<Map<String, dynamic>> rekapData = [];
    if (_mode == 'Mingguan') {
      // Group by 4 weeks
      for (int week = 1; week <= 4; week++) {
        final startDay = (week - 1) * 7 + 1;
        final endDay = week == 4 ? 31 : week * 7;

        final weekPayments = filteredPayments.where((p) =>
            p.paymentDate.day >= startDay && p.paymentDate.day <= endDay).toList();
        final weekExpenses = filteredExpenses.where((e) =>
            e.date.day >= startDay && e.date.day <= endDay).toList();

        final weekIncome = weekPayments.fold<double>(0, (sum, p) => sum + p.amount);
        final weekExpense = weekExpenses.fold<double>(0, (sum, e) => sum + e.amount);

        rekapData.add({
          'label': week == 1 ? 'Minggu Pertama' : week == 2 ? 'Minggu Kedua' : week == 3 ? 'Minggu Ketiga' : 'Minggu Keempat',
          'transaksi': weekPayments.length + weekExpenses.length,
          'pendapatan': weekIncome,
          'pengeluaran': weekExpense,
          'laba': weekIncome - weekExpense,
        });
      }
    } else {
      // Group by 12 months
      for (int m = 1; m <= 12; m++) {
        final monthPayments = filteredPayments.where((p) => p.paymentDate.month == m).toList();
        final monthExpenses = filteredExpenses.where((e) => e.date.month == m).toList();

        final monthIncome = monthPayments.fold<double>(0, (sum, p) => sum + p.amount);
        final monthExpense = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);

        rekapData.add({
          'label': _months[m - 1],
          'transaksi': monthPayments.length + monthExpenses.length,
          'pendapatan': monthIncome,
          'pengeluaran': monthExpense,
          'laba': monthIncome - monthExpense,
        });
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final bhId = context.read<BoardingHouseProvider>().selectedBoardingHouse?.id;
            await context.read<PaymentProvider>().fetchPayments(boardingHouseId: bhId);
            await context.read<ExpenseProvider>().fetchExpenses(boardingHouseId: bhId);
          },
          color: AppTheme.darkOlive,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.darkOlive),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Laporan Keuangan',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Top actions: Unduh & Cetak
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _generatePdfReport(filteredPayments, filteredExpenses, totalIncome, totalExpense, netProfit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text(
                        'Unduh Laporan',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _generatePdfReport(filteredPayments, filteredExpenses, totalIncome, totalExpense, netProfit),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text(
                        'Cetak',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tan/Orange Filter Panel
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E6D2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Mingguan vs Bulanan Toggles
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            _modeButton('Mingguan'),
                            _modeButton('Bulanan'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Pilih Bulan (if Mingguan)
                      if (_mode == 'Mingguan') ...[
                        Expanded(
                          child: Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedMonth,
                                items: List.generate(12, (index) {
                                  return DropdownMenuItem(
                                    value: index + 1,
                                    child: Text(
                                      _months[index],
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedMonth = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Pilih Tahun
                      Expanded(
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedYear,
                              items: _years.map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text(
                                    y.toString(),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedYear = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: _smallMetricCard('Total Pendapatan', totalIncome, const Color(0xFFD5F0D8), const Color(0xFF295433)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _smallMetricCard('Total Pengeluaran', totalExpense, const Color(0xFFF9DCDC), const Color(0xFFB23A48)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _smallMetricCard('Laba Bersih', netProfit, const Color(0xFFE8F4FD), const Color(0xFF2D4F7E)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grafik Pendapatan vs Pengeluaran
                OwnerPanel(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grafik Pendapatan vs. Pengeluaran',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: rekapData.map((data) {
                            final inc = data['pendapatan'] as double;
                            final exp = data['pengeluaran'] as double;
                            final maxVal = rekapData.map((d) {
                              final i = d['pendapatan'] as double;
                              final e = d['pengeluaran'] as double;
                              return i > e ? i : e;
                            }).reduce((a, b) => a > b ? a : b);

                            final incHeight = maxVal > 0 ? (inc / maxVal) * 110 : 0.0;
                            final expHeight = maxVal > 0 ? (exp / maxVal) * 110 : 0.0;

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Income Bar (Green)
                                    Container(
                                      width: 14,
                                      height: incHeight.clamp(2.0, 110.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF295433),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Expense Bar (Red)
                                    Container(
                                      width: 14,
                                      height: expHeight.clamp(2.0, 110.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB23A48),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _mode == 'Mingguan'
                                      ? 'W${rekapData.indexOf(data) + 1}'
                                      : DateFormat('MMM').format(DateTime(_selectedYear, rekapData.indexOf(data) + 1)),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Rekap Section Header
                Text(
                  _mode == 'Mingguan' ? 'Rekap Mingguan' : 'Rekap Bulanan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),

                // Rekap List
                ...rekapData.map((data) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFE0DDD6)),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFFE0DDD6)),
                      ),
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: Colors.white,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['label'],
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${data['transaksi']} Transaksi',
                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: Column(
                            children: [
                              _rekapRow('Pendapatan', data['pendapatan'] as double, const Color(0xFF295433)),
                              const Divider(height: 12),
                              _rekapRow('Pengeluaran', data['pengeluaran'] as double, const Color(0xFFB23A48)),
                              const Divider(height: 12),
                              _rekapRow('Laba Bersih', data['laba'] as double, const Color(0xFF2D4F7E), isBold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label) {
    final active = _mode == label;
    return GestureDetector(
      onTap: () => setState(() => _mode = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.darkOlive : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _smallMetricCard(String title, double value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0DDD6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rekapRow(String label, double val, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          _formatCurrency(val),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
