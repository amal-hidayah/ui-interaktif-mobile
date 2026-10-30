import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Data contoh seminar & workshop NusaEvent Hub.
final List<EventItem> sampleEvents = [
  EventItem(
    id: 'sem-ai-01',
    title: 'AI Summit: Ngobrol Produktif dengan Generative AI',
    tagline: 'Bikin konten, kode, dan riset jadi lebih cepat tanpa kehilangan konteks.',
    category: EventCategory.ai,
    speaker: 'Dr. Rani Puspitasari',
    speakerRole: 'AI Researcher, NusaAI Lab',
    date: DateTime(2026, 11, 12),
    timeRange: '09.00 – 15.00 WIB',
    venue: 'Auditorium Nusa Putra',
    price: 75000,
    quota: 200,
    seatsLeft: 46,
    description:
        'Sesi sehari penuh membedah cara kerja model generatif, menyusun prompt yang '
        'bisa diulang, sampai membangun asisten kecil untuk tugas kampus. Semua materi '
        'langsung dipraktikkan dengan studi kasus nyata.',
    highlights: [
      'Prompt pattern untuk tugas akademik',
      'Membangun asisten riset sederhana',
      'Etika & batas penggunaan AI',
    ],
    posterStart: Color(0xFF1E3A8A),
    posterEnd: Color(0xFF7C3AED),
  ),
  EventItem(
    id: 'sem-mobile-01',
    title: 'Flutter Fast Track: Rilis Aplikasi dalam Sehari',
    tagline: 'Dari widget pertama sampai build APK, semuanya dalam satu alur.',
    category: EventCategory.mobile,
    speaker: 'Bagas Wirawan',
    speakerRole: 'Mobile Engineer, Tokoloka',
    date: DateTime(2026, 11, 14),
    timeRange: '08.30 – 16.00 WIB',
    venue: 'Lab Mobile Lt. 4',
    price: 60000,
    quota: 60,
    seatsLeft: 12,
    description:
        'Workshop intensif untuk kamu yang baru masuk dunia Flutter. Kita susun UI '
        'responsif, sambungkan data, lalu hasilkan build yang siap dipasang di HP sendiri.',
    highlights: [
      'Struktur project yang rapi',
      'Layout responsif tanpa overflow',
      'Build & install APK di perangkat',
    ],
    posterStart: Color(0xFF0F766E),
    posterEnd: Color(0xFF22D3EE),
  ),
  EventItem(
    id: 'sem-iot-01',
    title: 'IoT Smart Campus Bootcamp',
    tagline: 'Sensor, MQTT, dan dashboard untuk kampus yang lebih pintar.',
    category: EventCategory.iot,
    speaker: 'Ir. Fajar Nugraha',
    speakerRole: 'IoT Architect, SmartNusa',
    date: DateTime(2026, 11, 16),
    timeRange: '09.00 – 15.30 WIB',
    venue: 'Lab IoT Lt. 2',
    price: 85000,
    quota: 40,
    seatsLeft: 8,
    description:
        'Merakit perangkat pemantau ruangan dari nol: pilih sensor, kirim data lewat '
        'MQTT, lalu tampilkan di dashboard realtime. Perangkat praktik disediakan panitia.',
    highlights: [
      'Rangkaian ESP32 + sensor',
      'Kirim data dengan MQTT',
      'Dashboard monitoring realtime',
    ],
    posterStart: Color(0xFFB45309),
    posterEnd: Color(0xFFF59E0B),
  ),
  EventItem(
    id: 'sem-cyber-01',
    title: 'Cyber Defense 101: Ethical Hacking untuk Pemula',
    tagline: 'Belajar menyerang secara legal supaya bisa membangun pertahanan.',
    category: EventCategory.cybersecurity,
    speaker: 'Nadia Kumala',
    speakerRole: 'Penetration Tester, Sekurindo',
    date: DateTime(2026, 11, 18),
    timeRange: '13.00 – 17.00 WIB',
    venue: 'Hall Cybersecurity',
    price: 70000,
    quota: 80,
    seatsLeft: 25,
    description:
        'Pengantar keamanan ofensif dengan lab virtual: enumerasi, eksploitasi dasar, '
        'dan cara menulis laporan temuan yang bisa dipahami tim developer.',
    highlights: [
      'Setup lab latihan aman',
      'Teknik recon & scanning',
      'Menulis laporan kerentanan',
    ],
    posterStart: Color(0xFF0F172A),
    posterEnd: Color(0xFF334155),
  ),
  EventItem(
    id: 'sem-ai-02',
    title: 'LLM Ops & RAG: dari Demo ke Produksi',
    tagline: 'Aplikasi AI yang rapi: evaluasi, biaya, dan data yang terkendali.',
    category: EventCategory.ai,
    speaker: 'Yoga Pratama',
    speakerRole: 'ML Platform Lead, DataSagara',
    date: DateTime(2026, 11, 21),
    timeRange: '09.00 – 14.00 WIB',
    venue: 'Studio AI Lt. 5',
    price: 95000,
    quota: 50,
    seatsLeft: 19,
    description:
        'Menyusun pipeline retrieval-augmented generation yang bisa dipantau: chunking, '
        'embedding, evaluasi jawaban, sampai strategi menekan biaya token.',
    highlights: [
      'Arsitektur RAG yang terukur',
      'Evaluasi kualitas jawaban',
      'Monitoring & kontrol biaya',
    ],
    posterStart: Color(0xFF7C2D12),
    posterEnd: Color(0xFFF97316),
  ),
  EventItem(
    id: 'sem-mobile-02',
    title: 'Design System untuk Aplikasi Mobile',
    tagline: 'Satu set komponen, dipakai konsisten di seluruh layar.',
    category: EventCategory.mobile,
    speaker: 'Sinta Maharani',
    speakerRole: 'Product Designer, RuangUI',
    date: DateTime(2026, 11, 23),
    timeRange: '10.00 – 15.00 WIB',
    venue: 'Ruang Kolaborasi B',
    price: 55000,
    quota: 70,
    seatsLeft: 31,
    description:
        'Membangun token warna, tipografi, dan komponen dasar yang siap dipakai tim. '
        'Ditutup dengan sesi audit tampilan aplikasi peserta.',
    highlights: [
      'Token warna & tipografi',
      'Komponen dasar yang reusable',
      'Audit konsistensi tampilan',
    ],
    posterStart: Color(0xFF1E40AF),
    posterEnd: Color(0xFF06B6D4),
  ),
  EventItem(
    id: 'sem-iot-02',
    title: 'Smart Farming dengan ESP32 & Sensor',
    tagline: 'Otomasi penyiraman berbasis data tanah dan cuaca.',
    category: EventCategory.iot,
    speaker: 'Dedi Kurniawan',
    speakerRole: 'Embedded Engineer, TaniTech',
    date: DateTime(2026, 11, 25),
    timeRange: '08.00 – 13.00 WIB',
    venue: 'Green Lab',
    price: 65000,
    quota: 35,
    seatsLeft: 0,
    description:
        'Merancang sistem penyiraman otomatis: kalibrasi sensor kelembapan, logika ambang '
        'batas, dan pengiriman notifikasi saat kondisi lahan berubah.',
    highlights: [
      'Kalibrasi sensor tanah',
      'Logika otomasi penyiraman',
      'Notifikasi kondisi lahan',
    ],
    posterStart: Color(0xFF14532D),
    posterEnd: Color(0xFF84CC16),
  ),
  EventItem(
    id: 'sem-cyber-02',
    title: 'Zero Trust Security Forum',
    tagline: 'Tidak ada yang otomatis dipercaya, semua diverifikasi.',
    category: EventCategory.cybersecurity,
    speaker: 'Rizky Ardiansyah',
    speakerRole: 'Security Consultant, TrustLine',
    date: DateTime(2026, 11, 28),
    timeRange: '09.00 – 16.00 WIB',
    venue: 'Auditorium Utama',
    price: 110000,
    quota: 150,
    seatsLeft: 64,
    description:
        'Forum diskusi penerapan zero trust di lingkungan kampus dan startup: identitas, '
        'segmentasi akses, sampai kebijakan yang realistis untuk tim kecil.',
    highlights: [
      'Prinsip identitas & akses',
      'Segmentasi jaringan praktis',
      'Studi kasus insiden nyata',
    ],
    posterStart: Color(0xFF4C1D95),
    posterEnd: Color(0xFF6D28D9),
  ),
];

/// Dipakai untuk preview poster di tab galeri.
List<EventItem> eventsByCategory(EventCategory category) =>
    sampleEvents.where((event) => event.category == category).toList();
