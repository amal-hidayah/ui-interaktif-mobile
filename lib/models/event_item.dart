import 'package:flutter/material.dart';

/// Kategori seminar yang dipakai untuk filter di halaman utama.
enum EventCategory {
  ai('AI', 'AI & Data Science', Icons.auto_awesome_rounded),
  mobile('Mobile', 'Mobile Development', Icons.phone_iphone_rounded),
  iot('IoT', 'IoT & Hardware', Icons.memory_rounded),
  cybersecurity('Cybersecurity', 'Cybersecurity', Icons.shield_rounded);

  const EventCategory(this.label, this.longLabel, this.icon);

  final String label;
  final String longLabel;
  final IconData icon;
}

/// Satu sesi seminar/workshop yang tampil di NusaEvent Hub.
@immutable
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.tagline,
    required this.category,
    required this.speaker,
    required this.speakerRole,
    required this.date,
    required this.timeRange,
    required this.venue,
    required this.price,
    required this.quota,
    required this.seatsLeft,
    required this.description,
    required this.highlights,
    required this.posterStart,
    required this.posterEnd,
  });

  final String id;
  final String title;
  final String tagline;
  final EventCategory category;
  final String speaker;
  final String speakerRole;
  final DateTime date;
  final String timeRange;
  final String venue;
  final int price;
  final int quota;
  final int seatsLeft;
  final String description;
  final List<String> highlights;
  final Color posterStart;
  final Color posterEnd;

  String get posterCode => 'NEH·${id.split('-').last.toUpperCase()}';
  String get dateLabel => formatDate(date);
  String get priceLabel => formatRupiah(price);
  bool get isSoldOut => seatsLeft <= 0;
  bool get isAlmostFull => !isSoldOut && seatsLeft <= 10;

  String get seatsLabel {
    if (isSoldOut) return 'Kuota habis';
    if (isAlmostFull) return 'Sisa $seatsLeft kursi';
    return '$seatsLeft kursi tersedia';
  }
}

const List<String> _shortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const List<String> _longMonths = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const List<String> _weekdays = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];

/// Contoh: `12 Nov 2026`.
String formatDate(DateTime date) =>
    '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';

/// Contoh: `Kamis, 12 November 2026`.
String formatFullDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} '
    '${_longMonths[date.month - 1]} ${date.year}';

/// Contoh: `Rp 75.000`.
String formatRupiah(num value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp $buffer';
}
