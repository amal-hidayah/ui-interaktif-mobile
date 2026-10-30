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

## Screenshot

Diambil langsung dari perangkat Android (1080 × 2340) memakai `flutter drive`:

<p>
  <img src="screenshots/01-seminar-list.png" width="200" alt="Daftar seminar" />
  <img src="screenshots/02-filter-bottom-sheet.png" width="200" alt="Filter kategori" />
  <img src="screenshots/04-detail-event.png" width="200" alt="Detail event" />
  <img src="screenshots/05-form-data-peserta.png" width="200" alt="Formulir pendaftaran" />
  <img src="screenshots/07-form-kit-donasi.png" width="200" alt="Kit dan donasi" />
  <img src="screenshots/10-pendaftaran-berhasil.png" width="200" alt="Tiket terdaftar" />
  <img src="screenshots/11-konfirmasi-batal.png" width="200" alt="Konfirmasi pembatalan" />
  <img src="screenshots/12-galeri-poster.png" width="200" alt="Galeri poster" />
  <img src="screenshots/13-denah-venue.png" width="200" alt="Denah venue" />
</p>

| # | Fitur | File |
|---|---|---|
| 1 | Daftar seminar | `screenshots/01-seminar-list.png` |
| 2 | Bottom sheet filter | `screenshots/02-filter-bottom-sheet.png` |
| 3 | Filter kategori IoT | `screenshots/03-filter-kategori-iot.png` |
| 4 | Detail event | `screenshots/04-detail-event.png` |
| 5 | Formulir — data peserta | `screenshots/05-form-data-peserta.png` |
| 6 | Date picker | `screenshots/06-date-picker.png` |
| 7 | Formulir — kit & donasi | `screenshots/07-form-kit-donasi.png` |
| 8 | Formulir — ringkasan & tata tertib | `screenshots/08-form-ringkasan-tata-tertib.png` |
| 9 | Loading pendaftaran | `screenshots/09-loading-pendaftaran.png` |
| 10 | Pendaftaran berhasil + tiket | `screenshots/10-pendaftaran-berhasil.png` |
| 11 | Dialog konfirmasi batal | `screenshots/11-konfirmasi-batal.png` |
| 12 | Galeri poster | `screenshots/12-galeri-poster.png` |
| 13 | Denah venue | `screenshots/13-denah-venue.png` |
| 14 | Denah setelah zoom | `screenshots/14-denah-venue-zoom.png` |

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
