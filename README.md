# NusaEvent Hub

Aplikasi Flutter untuk Tugas Sesi 5: hub seminar, workshop, galeri poster, denah venue, dan pendaftaran tiket.

## Fitur

- **Seminar & Workshop** — daftar event dengan `ListView.builder`, kartu `InkWell`, filter kategori AI / Mobile / IoT / Cybersecurity lewat chip dan bottom sheet.
- **Galeri & Denah Venue** — poster dengan `GridView.builder`, denah venue yang bisa digeser dan di-zoom dengan `InteractiveViewer`.
- **Tiket Terdaftar** — tiket aktif, pembatalan lewat `Dismissible` dengan konfirmasi `AlertDialog`.
- **Formulir pendaftaran** — validasi nama, NIM, email, WhatsApp dengan `GlobalKey<FormState>`, `showDatePicker`, tipe peserta, paket seminar kit, donasi, dan persetujuan tata tertib.

## Menjalankan

```bash
flutter pub get
flutter run
```

Target utama Android (API 31+), tetap responsif di layar lebar. Satu tiket contoh
(`NEH-2026-DEMO`) sudah tersedia di tab **Tiket** agar fitur geser-untuk-membatalkan
langsung bisa dicoba.

## Verifikasi

```bash
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d <device-id>
```

Integration test menjalankan alur lengkap di perangkat: filter kategori, buka detail,
isi formulir + date picker, kirim pendaftaran, lalu batalkan tiket lewat `Dismissible`.


## Struktur

```
lib/
├── models/
│   ├── event_item.dart
│   └── registration_ticket.dart
├── data/
│   └── sample_events.dart
├── widgets/
│   ├── event_card.dart
│   ├── filter_bottom_sheet.dart
│   └── venue_map_viewer.dart
├── screens/
│   ├── home_events_screen.dart
│   ├── event_registration_screen.dart
│   └── registered_tickets_screen.dart
└── main.dart
```
