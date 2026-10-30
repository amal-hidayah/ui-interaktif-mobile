import 'dart:math';

import 'package:flutter/material.dart';

import 'event_item.dart';

/// Tipe peserta menentukan tambahan biaya tiket.
enum ParticipantType {
  mahasiswa('Mahasiswa', 'KTM aktif', 0, Icons.school_rounded),
  umum('Umum', 'Pengunjung umum', 25000, Icons.groups_rounded),
  profesional('Profesional', 'Praktisi & dosen', 50000, Icons.work_rounded);

  const ParticipantType(this.label, this.description, this.surcharge, this.icon);

  final String label;
  final String description;
  final int surcharge;
  final IconData icon;
}

/// Paket seminar kit yang bisa dipilih saat mendaftar.
enum SeminarKit {
  basic('Basic', 'Tote bag + e-sertifikat', 0),
  standard('Standard', 'Tote bag, notebook, dan snack', 25000),
  premium('Premium', 'Semua paket + merchandise eksklusif', 50000);

  const SeminarKit(this.label, this.description, this.price);

  final String label;
  final String description;
  final int price;
}

enum TicketStatus { active, cancelled }

/// Tiket hasil pendaftaran peserta.
@immutable
class RegistrationTicket {
  const RegistrationTicket({
    required this.code,
    required this.event,
    required this.participantName,
    required this.nim,
    required this.email,
    required this.whatsapp,
    required this.participantType,
    required this.attendanceDate,
    required this.kit,
    required this.donation,
    required this.registeredAt,
    this.status = TicketStatus.active,
  });

  factory RegistrationTicket.create({
    required EventItem event,
    required String participantName,
    required String nim,
    required String email,
    required String whatsapp,
    required ParticipantType participantType,
    required DateTime attendanceDate,
    required SeminarKit kit,
    required int donation,
  }) {
    return RegistrationTicket(
      code: _generateCode(),
      event: event,
      participantName: participantName,
      nim: nim,
      email: email,
      whatsapp: whatsapp,
      participantType: participantType,
      attendanceDate: attendanceDate,
      kit: kit,
      donation: donation,
      registeredAt: DateTime.now(),
    );
  }

  final String code;
  final EventItem event;
  final String participantName;
  final String nim;
  final String email;
  final String whatsapp;
  final ParticipantType participantType;
  final DateTime attendanceDate;
  final SeminarKit kit;
  final int donation;
  final DateTime registeredAt;
  final TicketStatus status;

  bool get isActive => status == TicketStatus.active;

  int get ticketPrice => event.price + participantType.surcharge;
  int get total => ticketPrice + kit.price + donation;

  RegistrationTicket copyWith({TicketStatus? status}) {
    return RegistrationTicket(
      code: code,
      event: event,
      participantName: participantName,
      nim: nim,
      email: email,
      whatsapp: whatsapp,
      participantType: participantType,
      attendanceDate: attendanceDate,
      kit: kit,
      donation: donation,
      registeredAt: registeredAt,
      status: status ?? this.status,
    );
  }

  static String _generateCode() {
    final random = Random();
    final suffix = random.nextInt(0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
    return 'NEH-${DateTime.now().year}-$suffix';
  }
}
