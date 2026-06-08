import 'package:flutter/material.dart';

class OwnerMetric {
  const OwnerMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.backgroundColor = const Color(0xFFF7F4EB),
  });

  final IconData icon;
  final String label;
  final String value;
  final Color backgroundColor;
}

class OwnerAction {
  const OwnerAction({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class OwnerRoomCard {
  const OwnerRoomCard({
    required this.roomNumber,
    required this.boardingHouseName,
    required this.status,
    required this.price,
    required this.period,
  });

  final String roomNumber;
  final String boardingHouseName;
  final String status;
  final String price;
  final String period;
}

class OwnerBoardingHouseCard {
  const OwnerBoardingHouseCard({
    required this.name,
    required this.roomCount,
    required this.emptyCount,
    required this.image,
  });

  final String name;
  final String roomCount;
  final String emptyCount;
  final String image;
}

class OwnerTenantCard {
  const OwnerTenantCard({
    required this.name,
    required this.houseName,
    required this.roomNumber,
    required this.phone,
    required this.checkIn,
  });

  final String name;
  final String houseName;
  final String roomNumber;
  final String phone;
  final String checkIn;
}

class OwnerComplaintCard {
  const OwnerComplaintCard({
    required this.title,
    required this.tenantName,
    required this.houseName,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
  });

  final String title;
  final String tenantName;
  final String houseName;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
}

class OwnerFinanceEntry {
  const OwnerFinanceEntry({
    required this.label,
    required this.amount,
    required this.dateLabel,
    required this.isIncome,
  });

  final String label;
  final String amount;
  final String dateLabel;
  final bool isIncome;
}

class OwnerDesignData {
  static const ownerName = 'Ibu Ani!';
  static const houseName = 'Kos Anggrek';
  static const monthlyIncome = 'Rp. 10.000.000';
  static const newIncome = 'Rp. 5.500.000';
  static const expense = 'Rp. 1.500.000';

  static const metrics = <OwnerMetric>[
    OwnerMetric(
      icon: Icons.home_outlined,
      label: 'Total Kamar',
      value: '10 Kamar',
    ),
    OwnerMetric(
      icon: Icons.meeting_room_outlined,
      label: 'Kosong',
      value: '5 Kosong',
    ),
    OwnerMetric(
      icon: Icons.bar_chart_outlined,
      label: 'Pemasukan Bulan Ini',
      value: 'Rp. 5.500.000',
    ),
    OwnerMetric(
      icon: Icons.trending_down_outlined,
      label: 'Pengeluaran',
      value: 'Rp 1.500.000',
    ),
  ];

  static const actions = <OwnerAction>[
    OwnerAction(icon: Icons.payments_outlined, label: 'Pembayaran'),
    OwnerAction(icon: Icons.people_outline, label: 'Penghuni'),
    OwnerAction(icon: Icons.apartment_outlined, label: 'Kamar Kos'),
    OwnerAction(icon: Icons.receipt_long_outlined, label: 'Laporan\nKeuangan'),
  ];

  static const reminders = <String>['Pengingat Jatuh tempo!', 'Keluhan Baru!'];

  static const rooms = <OwnerRoomCard>[
    OwnerRoomCard(
      roomNumber: 'A1',
      boardingHouseName: 'Kos Anggrek',
      status: 'Terisi',
      price: 'Rp. 1.500.000',
      period: 'April s/d Oktober',
    ),
    OwnerRoomCard(
      roomNumber: 'A2',
      boardingHouseName: 'Kos Anggrek',
      status: 'Terisi',
      price: 'Rp. 1.500.000',
      period: 'April s/d Oktober',
    ),
    OwnerRoomCard(
      roomNumber: 'A3',
      boardingHouseName: 'Kos Anggrek',
      status: 'Kosong',
      price: 'Rp. 1.500.000',
      period: '...',
    ),
  ];

  static const boardingHouses = <OwnerBoardingHouseCard>[
    OwnerBoardingHouseCard(
      name: 'Kosan Anggrek',
      roomCount: '7 Kamar',
      emptyCount: '3 Kosong',
      image: 'assets/RUMA LOGO 1.png',
    ),
    OwnerBoardingHouseCard(
      name: 'Kosan Rajeg',
      roomCount: '7 Kamar',
      emptyCount: '3 Kosong',
      image: 'assets/RUMA LOGO 1.png',
    ),
  ];

  static const tenants = <OwnerTenantCard>[
    OwnerTenantCard(
      name: 'Rosita Samsulelika Putri',
      houseName: 'Kos Anggrek',
      roomNumber: 'Kamar A1',
      phone: '0812-7653-2261',
      checkIn: '5 April 2026',
    ),
    OwnerTenantCard(
      name: 'Rosita Samsulelika Putri',
      houseName: 'Kos Anggrek',
      roomNumber: 'Kamar A1',
      phone: '0812-7653-2261',
      checkIn: '5 April 2026',
    ),
  ];

  static const complaints = <OwnerComplaintCard>[
    OwnerComplaintCard(
      title: 'Toilet Mampet',
      tenantName: 'Annisa NF',
      houseName: 'Kos Anggrek A1',
      status: 'Belum diproses',
      statusColor: Color(0xFFF0CBD0),
      statusTextColor: Color(0xFF6E2E39),
    ),
    OwnerComplaintCard(
      title: 'Air Suka Mati',
      tenantName: 'Dimas A',
      houseName: 'Kos Anggrek A1',
      status: 'Done',
      statusColor: Color(0xFFD4F0DA),
      statusTextColor: Color(0xFF2B5A34),
    ),
    OwnerComplaintCard(
      title: 'AC Bocor',
      tenantName: 'Fahra Fazira',
      houseName: 'Kos Anggrek A1',
      status: 'Sedang di proses',
      statusColor: Color(0xFFD8E6F7),
      statusTextColor: Color(0xFF2D4F7E),
    ),
  ];

  static const financeEntries = <OwnerFinanceEntry>[
    OwnerFinanceEntry(
      label: 'Pembayaran Kamar A1',
      amount: 'Rp 1.500.000',
      dateLabel: '10 Mei 2026',
      isIncome: true,
    ),
    OwnerFinanceEntry(
      label: 'Pembayaran Kamar A2',
      amount: 'Rp 1.500.000',
      dateLabel: '10 Mei 2026',
      isIncome: true,
    ),
    OwnerFinanceEntry(
      label: 'Perbaikan Lampu',
      amount: 'Rp 150.000',
      dateLabel: '9 Mei 2026',
      isIncome: false,
    ),
    OwnerFinanceEntry(
      label: 'Gaji Cleaning Service',
      amount: 'Rp 350.000',
      dateLabel: '8 Mei 2026',
      isIncome: false,
    ),
  ];
}
