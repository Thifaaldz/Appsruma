import 'package:flutter/material.dart';

class DashboardNotice {
  const DashboardNotice({
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final String? trailing;
}

class PaymentMethodOption {
  const PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.period,
    required this.amount,
    required this.dateLabel,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.trailingIcon,
  });

  final String period;
  final String amount;
  final String dateLabel;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final IconData trailingIcon;
}

class NotificationItem {
  const NotificationItem({
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final String time;
}

class RoomFeatureItem {
  const RoomFeatureItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class ProfileFieldItem {
  const ProfileFieldItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class ComplaintHistoryItem {
  const ComplaintHistoryItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.date,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String date;
}

class TenantDesignData {
  static const String name = 'Dita';
  static const String kosName = 'RUMA';
  static const String roomNumber = 'A1';
  static const String roomLabel = 'Kamar A1';
  static const String floorAndSize = 'Lantai 1  + Ukuran 3x4 m';
  static const String monthlyBill = 'Rp. 1.500.000';
  static const String dueDate = '10 April 2026';
  static const String dueDateNote = 'Jatuh tempo : 10 April 2026';

  static const dashboardNotices = <DashboardNotice>[
    DashboardNotice(
      icon: Icons.notifications_none,
      backgroundColor: Color(0xFFF8F3AE),
      title: 'Pengingat Aktif',
      subtitle: '3 hari, 1 hari sebelum jatuh tempo & di hari H',
      trailing: 'Akan dikirim',
    ),
  ];

  static const topNotifications = <NotificationItem>[
    NotificationItem(
      icon: Icons.notifications_none,
      backgroundColor: Color(0xFFDDE8FF),
      title: 'Pengingat Pembayaran',
      subtitle: 'Jatuh tempo 3 hari lagi',
      time: 'Hari ini, 08.00',
    ),
    NotificationItem(
      icon: Icons.campaign_outlined,
      backgroundColor: Color(0xFFF9DCDC),
      title: 'Pengumuman',
      subtitle: 'Kebersihan lingkungan kos',
      time: 'Kemarin, 18.30',
    ),
  ];

  static const paymentMethods = <PaymentMethodOption>[
    PaymentMethodOption(
      icon: Icons.qr_code_2,
      title: 'QRIS',
      subtitle: 'Bayar mudah dengan QRIS',
      selected: true,
    ),
    PaymentMethodOption(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Virtual Account',
      subtitle: 'Transver via VA',
    ),
    PaymentMethodOption(
      icon: Icons.account_balance_outlined,
      title: 'Transfer Bank',
      subtitle: 'Transfer ke rekening kos',
    ),
  ];

  static const paymentHistory = <PaymentHistoryItem>[
    PaymentHistoryItem(
      period: 'Mei 2026',
      amount: 'Rp 1.500.000',
      dateLabel: 'Jatuh tempo 10 Mei 2026',
      status: 'Belum Bayar',
      statusColor: Color(0xFFFFE17E),
      statusTextColor: Color(0xFF6F5600),
      trailingIcon: Icons.chevron_right,
    ),
    PaymentHistoryItem(
      period: 'April 2026',
      amount: 'Rp 1.500.000',
      dateLabel: 'Dibayar 7 April 2026',
      status: 'Lunas',
      statusColor: Color(0xFFD5F0D8),
      statusTextColor: Color(0xFF295433),
      trailingIcon: Icons.download_outlined,
    ),
    PaymentHistoryItem(
      period: 'Maret 2026',
      amount: 'Rp 1.500.000',
      dateLabel: 'Dibayar 7 Maret 2026',
      status: 'Lunas',
      statusColor: Color(0xFFD5F0D8),
      statusTextColor: Color(0xFF295433),
      trailingIcon: Icons.download_outlined,
    ),
    PaymentHistoryItem(
      period: 'Februari 2026',
      amount: 'Rp 1.500.000',
      dateLabel: 'Dibayar 7 Feb 2026',
      status: 'Lunas',
      statusColor: Color(0xFFD5F0D8),
      statusTextColor: Color(0xFF295433),
      trailingIcon: Icons.download_outlined,
    ),
    PaymentHistoryItem(
      period: 'Januari 2026',
      amount: 'Rp 1.500.000',
      dateLabel: 'Dibayar 7 Jan 2026',
      status: 'Lunas',
      statusColor: Color(0xFFD5F0D8),
      statusTextColor: Color(0xFF295433),
      trailingIcon: Icons.download_outlined,
    ),
    PaymentHistoryItem(
      period: 'Desember 2025',
      amount: 'Rp 1.500.000',
      dateLabel: 'Dibayar 7 Des 2025',
      status: 'Lunas',
      statusColor: Color(0xFFD5F0D8),
      statusTextColor: Color(0xFF295433),
      trailingIcon: Icons.download_outlined,
    ),
  ];

  static const notifications = <NotificationItem>[
    NotificationItem(
      icon: Icons.notifications_active_outlined,
      backgroundColor: Color(0xFFF9DCDC),
      title: 'Jatuh Tempo Hari Ini',
      subtitle: 'Pembayaran jatuh tempo hari ini',
      time: '10 Mei 2026, 8.00',
    ),
    NotificationItem(
      icon: Icons.notifications_none,
      backgroundColor: Color(0xFFFFF6B9),
      title: 'Pengingat Pembayaran',
      subtitle: 'Jatuh tempo 1 hari lagi',
      time: '9 Mei 2026, 8.00',
    ),
    NotificationItem(
      icon: Icons.notifications_none,
      backgroundColor: Color(0xFFDDF5E4),
      title: 'Pengingat Pembayaran',
      subtitle: 'Jatuh tempo 3 hari lagi',
      time: '7 Mei 2026, 8.00',
    ),
    NotificationItem(
      icon: Icons.check_circle_outline,
      backgroundColor: Color(0xFFDDF5E4),
      title: 'Pembayaran Berhasil',
      subtitle: 'Pembayaran bulan april 2026 berhasil',
      time: '1 April 2026, 16.00',
    ),
    NotificationItem(
      icon: Icons.campaign_outlined,
      backgroundColor: Color(0xFFDDF5E4),
      title: 'Pengumuman',
      subtitle: 'Jaga lingkungan kos',
      time: '28 Maret 2026, 8.00',
    ),
    NotificationItem(
      icon: Icons.warning_amber_outlined,
      backgroundColor: Color(0xFFFFDADA),
      title: 'Informasi Denda',
      subtitle: 'Keterlambatan dikenakan denda Rp 50.000/minggu',
      time: '25 Maret 2026, 8.00',
    ),
  ];

  static const roomFeatures = <RoomFeatureItem>[
    RoomFeatureItem(icon: Icons.king_bed_outlined, label: 'Kamar Mandi Dalam'),
    RoomFeatureItem(icon: Icons.ac_unit, label: 'AC'),
    RoomFeatureItem(icon: Icons.check_box_outline_blank, label: 'Lemari'),
    RoomFeatureItem(icon: Icons.table_restaurant_outlined, label: 'Meja'),
    RoomFeatureItem(icon: Icons.wifi, label: 'Wi-Fi'),
  ];

  static const profileFields = <ProfileFieldItem>[
    ProfileFieldItem(
      icon: Icons.phone_outlined,
      label: 'Nomor Telepon',
      value: '0812-7866-2341',
    ),
    ProfileFieldItem(
      icon: Icons.mail_outline,
      label: 'Email',
      value: 'kath.anysaa@gmail.com',
    ),
    ProfileFieldItem(
      icon: Icons.meeting_room_outlined,
      label: 'Nomor Kamar',
      value: 'A1',
    ),
    ProfileFieldItem(
      icon: Icons.calendar_month_outlined,
      label: 'Mulai Sewa',
      value: '4 September 2025',
    ),
    ProfileFieldItem(
      icon: Icons.event_note_outlined,
      label: 'Masa Sewa',
      value: '1 Tahun',
    ),
  ];

  static const complaintHistory = <ComplaintHistoryItem>[
    ComplaintHistoryItem(
      title: 'AC tidak dingin',
      subtitle: 'Ruangan terasa panas sejak pagi',
      status: 'Diproses',
      statusColor: Color(0xFFDDE9F8),
      statusTextColor: Color(0xFF2D4F7E),
      date: '10 Mei 2026',
    ),
    ComplaintHistoryItem(
      title: 'Lampu kamar mati',
      subtitle: 'Lampu utama tidak menyala',
      status: 'Selesai',
      statusColor: Color(0xFFD5F0D8),
      statusTextColor: Color(0xFF295433),
      date: '2 Mei 2026',
    ),
  ];
}
