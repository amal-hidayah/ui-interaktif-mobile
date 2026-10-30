import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_sesi_5/main.dart';
import 'package:tugas_sesi_5/screens/event_registration_screen.dart';
import 'package:tugas_sesi_5/screens/home_events_screen.dart';

void main() {
  testWidgets('tiga tab utama bisa dibuka', (tester) async {
    await tester.pumpWidget(const NusaEventApp());
    await tester.pumpAndSettle();

    expect(find.text('Seminar & Workshop'), findsOneWidget);
    expect(
      find.text('AI Summit: Ngobrol Produktif dengan Generative AI'),
      findsOneWidget,
    );

    await tester.tap(find.text('Galeri & Venue'));
    await tester.pumpAndSettle();
    expect(find.text('Galeri & Denah'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    final galleryScrollable = find
        .descendant(
          of: find.byType(GalleryVenueScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Denah venue'),
      300,
      scrollable: galleryScrollable,
    );
    expect(find.text('Denah venue'), findsOneWidget);

    await tester.tap(find.text('Tiket'));
    await tester.pumpAndSettle();
    expect(find.text('Tiket Terdaftar'), findsOneWidget);
    expect(find.text('NEH-2026-DEMO'), findsOneWidget);
  });

  testWidgets('filter kategori menyaring daftar seminar', (tester) async {
    await tester.pumpWidget(const NusaEventApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'IoT'));
    await tester.pumpAndSettle();

    expect(find.text('2 sesi tersedia • 8 total event'), findsOneWidget);
    expect(find.text('IoT Smart Campus Bootcamp'), findsOneWidget);
    expect(
      find.text('AI Summit: Ngobrol Produktif dengan Generative AI'),
      findsNothing,
    );
  });

  testWidgets('formulir menolak data kosong', (tester) async {
    await tester.pumpWidget(const NusaEventApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('AI Summit: Ngobrol Produktif dengan Generative AI'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daftar sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Pendaftaran'), findsOneWidget);

    final submitButton = find.text('Kirim pendaftaran');
    final formScrollable = find
        .descendant(
          of: find.byType(EventRegistrationScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      submitButton,
      350,
      scrollable: formScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Persetujuan tata tertib wajib dicentang'),
      findsOneWidget,
    );
    expect(
      find.text('Lengkapi dulu data yang ditandai merah.'),
      findsOneWidget,
    );
  });
}
