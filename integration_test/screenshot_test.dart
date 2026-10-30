import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tugas_sesi_5/main.dart';
import 'package:tugas_sesi_5/screens/event_registration_screen.dart';
import 'package:tugas_sesi_5/screens/home_events_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ambil screenshot semua fitur', (tester) async {
    await tester.pumpWidget(const NusaEventApp());
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    // 1. Daftar seminar
    await binding.takeScreenshot('01-seminar-list');

    // 2. Filter bottom sheet
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('02-filter-bottom-sheet');
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    // 3. Filter kategori IoT
    await tester.tap(find.widgetWithText(ChoiceChip, 'IoT'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('03-filter-kategori-iot');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Semua'));
    await tester.pumpAndSettle();

    // 4. Detail event
    await tester.tap(
      find.text('AI Summit: Ngobrol Produktif dengan Generative AI'),
    );
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04-detail-event');

    // 5. Formulir pendaftaran
    await tester.tap(find.text('Daftar sekarang'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('05-form-data-peserta');

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

    // 6. Date picker
    await _scrollTo(tester, find.byKey(const Key('field_tanggal')));
    await tester.tap(find.byKey(const Key('field_tanggal')));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('06-date-picker');
    await tester.tap(find.text('Pilih'));
    await tester.pumpAndSettle();

    // 7. Tipe peserta, kit, donasi
    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Umum'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Umum'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Premium'));
    await tester.tap(find.text('Premium'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.widgetWithText(ChoiceChip, 'Rp 25.000'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Rp 25.000'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('07-form-kit-donasi');

    // 8. Ringkasan + tata tertib
    await _scrollTo(tester, find.byKey(const Key('checkbox_terms')));
    await tester.tap(find.byKey(const Key('checkbox_terms')));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('08-form-ringkasan-tata-tertib');

    // 9. Loading saat submit
    await _scrollTo(tester, find.byKey(const Key('button_submit')));
    await tester.tap(find.byKey(const Key('button_submit')));
    await tester.pump(const Duration(milliseconds: 250));
    await binding.takeScreenshot('09-loading-pendaftaran');

    // 10. SnackBar sukses + tiket aktif
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('10-pendaftaran-berhasil');

    // 11. Dialog konfirmasi pembatalan
    await tester.drag(find.text('Peserta Uji'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('11-konfirmasi-batal');
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    // 12. Galeri poster
    await tester.tap(find.text('Galeri & Venue'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('12-galeri-poster');

    // 13. Denah venue
    await _scrollTo(tester, find.text('Denah venue'), of: GalleryVenueScreen);
    await _scrollTo(tester, find.byTooltip('Perbesar'), of: GalleryVenueScreen);
    await binding.takeScreenshot('13-denah-venue');

    // 14. Denah setelah zoom
    await tester.tap(find.byTooltip('Perbesar'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('14-denah-venue-zoom');
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
