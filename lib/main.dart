import 'package:flutter/material.dart';

import 'data/sample_events.dart';
import 'models/event_item.dart';
import 'models/registration_ticket.dart';
import 'screens/event_registration_screen.dart';
import 'screens/home_events_screen.dart';
import 'screens/registered_tickets_screen.dart';

void main() {
  runApp(const NusaEventApp());
}

class NusaEventApp extends StatelessWidget {
  const NusaEventApp({super.key});

  static const Color _seed = Color(0xFF0E7490);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NusaEvent Hub',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const HomeShell(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.2),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.8),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late List<RegistrationTicket> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = <RegistrationTicket>[_demoTicket()];
  }

  List<RegistrationTicket> get _activeTickets =>
      _tickets.where((ticket) => ticket.isActive).toList(growable: false);

  RegistrationTicket _demoTicket() {
    final event = sampleEvents[1];
    return RegistrationTicket(
      code: 'NEH-2026-DEMO',
      event: event,
      participantName: 'Peserta Demo',
      nim: '2410100999',
      email: 'peserta.demo@nusaputra.ac.id',
      whatsapp: '081234567890',
      participantType: ParticipantType.mahasiswa,
      attendanceDate: event.date,
      kit: SeminarKit.standard,
      donation: 10000,
      registeredAt: DateTime.now(),
    );
  }

  Future<void> _openRegistration(EventItem event) async {
    final ticket = await Navigator.of(context).push<RegistrationTicket>(
      MaterialPageRoute<RegistrationTicket>(
        builder: (context) => EventRegistrationScreen(event: event),
      ),
    );
    if (!mounted || ticket == null) return;

    setState(() {
      _tickets = <RegistrationTicket>[..._tickets, ticket];
      _index = 2;
    });
    _showSnack(
      'Pendaftaran berhasil • tiket ${ticket.code} aktif',
      icon: Icons.check_circle_rounded,
    );
  }

  void _cancelTicket(RegistrationTicket ticket) {
    setState(() {
      _tickets = <RegistrationTicket>[
        for (final item in _tickets)
          item.code == ticket.code
              ? item.copyWith(status: TicketStatus.cancelled)
              : item,
      ];
    });
  }

  void _showSnack(String message, {required IconData icon}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activeTickets = _activeTickets;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.hub_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('NusaEvent Hub'),
                  Text(
                    'Seminar & workshop kampus',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tiket terdaftar',
            onPressed: () => setState(() => _index = 2),
            icon: Badge.count(
              count: activeTickets.length,
              isLabelVisible: activeTickets.isNotEmpty,
              child: const Icon(Icons.confirmation_number_outlined),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: IndexedStack(
            index: _index,
            children: [
              HomeEventsScreen(
                onRegister: _openRegistration,
                onOpenTickets: () => setState(() => _index = 2),
                activeTicketCount: activeTickets.length,
              ),
              const GalleryVenueScreen(),
              RegisteredTicketsScreen(
                tickets: activeTickets,
                onCancel: _cancelTicket,
                onBrowseEvents: () => setState(() => _index = 0),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_rounded),
            label: 'Seminar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Galeri & Venue',
          ),
          NavigationDestination(
            icon: Badge.count(
              count: activeTickets.length,
              isLabelVisible: activeTickets.isNotEmpty,
              child: const Icon(Icons.confirmation_number_outlined),
            ),
            selectedIcon: Badge.count(
              count: activeTickets.length,
              isLabelVisible: activeTickets.isNotEmpty,
              child: const Icon(Icons.confirmation_number_rounded),
            ),
            label: 'Tiket',
          ),
        ],
      ),
    );
  }
}
