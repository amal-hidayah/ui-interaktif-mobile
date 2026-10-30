import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tugas_sesi_5/main.dart';
import 'package:tugas_sesi_5/screens/event_registration_screen.dart';
import 'package:tugas_sesi_5/screens/home_events_screen.dart';
import 'package:tugas_sesi_5/widgets/event_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('alur lengkap: filter, daftar, tiket, batal, galeri', (
    tester,
  ) async {
    await tester.pumpWidget(const NusaEventApp());
    await tester.pumpAndSettle();

    // --- Tab seminar & filter kategori ---
    expect(find.text('Seminar & Workshop'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'IoT'));
    await tester.pumpAndSettle();
    expect(find.text('2 sesi tersedia • 8 total event'), findsOneWidget);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text('Filter & urutkan'), findsOneWidget);
    await tester.tap(find.text('Terapkan (1)'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Semua'));
    await tester.pumpAndSettle();
    expect(find.text('8 sesi tersedia • 8 total event'), findsOneWidget);

    // --- Detail event lalu buka formulir ---
    await tester.tap(
      find.text('AI Summit: Ngobrol Produktif dengan Generative AI'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tentang sesi'), findsOneWidget);

    await tester.tap(find.text('Daftar sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Pendaftaran'), findsOneWidget);

    // --- Isi formulir ---
    await _scrollTo(tester, find.byKey(const Key('input_nama')));
    await tester.enterText(find.byKey(const Key('input_nama')), 'Peserta Uji');

    await _scrollTo(tester, find.byKey(const Key('input_nim')));
    await tester.enterText(find.byKey(const Key('input_nim')), '2410100123');

    await _scrollTo(tester, find.byKey(const Key('input_email')));
    await tester.enterText(
      find.byKey(const Key('input_email')),
      'peserta.uji@nusaputra.ac.id',
    );

    await _scrollTo(tester, find.byKey(const Key('input_whatsapp')));
    await tester.enterText(
      find.byKey(const Key('input_whatsapp')),
      '081234567890',
    );

    // --- Tanggal kehadiran lewat showDatePicker ---
    await _scrollTo(tester, find.byKey(const Key('field_tanggal')));
    await tester.tap(find.byKey(const Key('field_tanggal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();
    expect(find.text('Kamis, 12 November 2026'), findsOneWidget);

    // --- Tipe peserta, kit, donasi, tata tertib ---
    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Umum'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Umum'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Premium'));
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Rp 25.000'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Rp 25.000'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const Key('checkbox_terms')));
    await tester.tap(find.byKey(const Key('checkbox_terms')));
    await tester.pumpAndSettle();

    // --- Kirim dan cek SnackBar ---
    await _scrollTo(tester, find.byKey(const Key('button_submit')));
    await tester.tap(find.byKey(const Key('button_submit')));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.textContaining('Pendaftaran berhasil'), findsOneWidget);
    expect(find.text('Tiket Terdaftar'), findsOneWidget);
    expect(find.text('Peserta Uji'), findsOneWidget);

    // --- Batalkan tiket lewat Dismissible + AlertDialog ---
    await tester.drag(find.text('Peserta Uji'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Batalkan tiket?'), findsOneWidget);

    await tester.tap(find.text('Ya, batalkan'));
    await tester.pumpAndSettle();
    expect(find.text('Peserta Uji'), findsNothing);
    expect(find.textContaining('dibatalkan'), findsOneWidget);

    // --- Galeri poster & denah venue ---
    await tester.tap(find.text('Galeri & Venue'));
    await tester.pumpAndSettle();
    expect(find.text('Galeri & Denah'), findsOneWidget);

    await _scrollTo(tester, find.text('Denah venue'), of: GalleryVenueScreen);
    await _scrollTo(tester, find.byTooltip('Perbesar'), of: GalleryVenueScreen);
    await tester.tap(find.byTooltip('Perbesar'));
    await tester.pumpAndSettle();
    expect(find.text('135%'), findsOneWidget);

    await tester.tap(find.byTooltip('Reset tampilan'));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);

    final poster = find
        .descendant(
          of: find.byType(GalleryVenueScreen),
          matching: find.byType(EventPoster),
        )
        .first;
    await _scrollTo(tester, poster, of: GalleryVenueScreen);
    await tester.tap(poster);
    await tester.pumpAndSettle();
    expect(find.text('Cubit & geser untuk memperbesar poster'), findsOneWidget);

    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();
    expect(
      find.text('Cubit & geser untuk memperbesar poster'),
      findsNothing,
    );
  });
}

Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  Type of = EventRegistrationScreen,
}) async {
  final scrollable = find
      .descendant(of: find.byType(of), matching: find.byType(Scrollable))
      .first;
  await tester.scrollUntilVisible(finder, 320, scrollable: scrollable);
  await tester.pumpAndSettle();
}
