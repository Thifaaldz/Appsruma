import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/boarding_house_provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = '';
  bool _isSaving = false;

  static const categories = [
    'Makanan & Minuman',
    'Transport',
    'Tagihan',
    'Belanja',
    'Kebersihan',
    'Perbaikan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.darkOlive,
              onPrimary: Colors.white,
              surface: AppTheme.lightBeige,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim().replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      id: 0,
      ownerId: 0,
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate ?? DateTime.now(),
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    final bhId = context.read<BoardingHouseProvider>().selectedBoardingHouse?.id;
    final success = await context.read<ExpenseProvider>().addExpense(expense, boardingHouseId: bhId);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengeluaran berhasil disimpan')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan pengeluaran')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tambah Pengeluaran',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Judul
              _SectionLabel(label: 'Judul / Deskripsi'),
              const SizedBox(height: 8),
              _InputField(
                controller: _titleController,
                hint: 'Mis. Makan siang, listrik, transport',
              ),
              const SizedBox(height: 4),
              _HelperText(text: 'Singkat tapi jelas'),
              const SizedBox(height: 18),

              // Nominal
              _SectionLabel(label: 'Nominal'),
              const SizedBox(height: 8),
              _InputField(
                controller: _amountController,
                hint: 'Rp 0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 4),
              _HelperText(text: 'Contoh: 125000'),
              const SizedBox(height: 18),

              // Kategori
              _SectionLabel(label: 'Kategori'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.darkOlive
                            : AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.darkOlive
                              : const Color(0xFFD8D8D8),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              _HelperText(text: 'Pilih kategori yang paling sesuai'),
              const SizedBox(height: 18),

              // Tanggal
              _SectionLabel(label: 'Tanggal Transaksi'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0DDD6)),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID')
                              .format(_selectedDate!)
                        : 'Pilih tanggal',
                    style: TextStyle(
                      color: _selectedDate != null
                          ? AppTheme.textDark
                          : const Color(0xFFB0ACA1),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _HelperText(text: 'Gunakan tanggal kejadian'),
              const SizedBox(height: 18),

              // Catatan
              _SectionLabel(label: 'Catatan (Opsional)'),
              const SizedBox(height: 8),
              _InputField(
                controller: _noteController,
                hint: 'Tambahkan keterangan tambahan',
                maxLines: 3,
              ),
              const SizedBox(height: 4),
              _HelperText(
                text: 'Mis. meeting dengan siapa, lokasi, atau catatan lain',
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.darkOlive),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.darkOlive,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkOlive,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan Pengeluaran',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppTheme.textSecondary,
        fontSize: 12,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0ACA1)),
        filled: true,
        fillColor: AppTheme.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0DDD6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0DDD6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.darkOlive, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
