import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';

/// Tab ketiga: tiket aktif dengan pembatalan lewat [Dismissible].
class RegisteredTicketsScreen extends StatelessWidget {
  const RegisteredTicketsScreen({
    super.key,
    required this.tickets,
    required this.onCancel,
    required this.onBrowseEvents,
  });

  final List<RegistrationTicket> tickets;
  final ValueChanged<RegistrationTicket> onCancel;
  final VoidCallback onBrowseEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tiket Terdaftar',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${tickets.length} aktif',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tickets.isEmpty
                    ? 'Belum ada tiket aktif.'
                    : 'Geser kartu ke kiri atau kanan untuk membatalkan tiket.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tickets.isEmpty
              ? _EmptyTickets(onBrowseEvents: onBrowseEvents)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == tickets.length - 1 ? 0 : 12,
                      ),
                      child: Dismissible(
                        key: ValueKey(ticket.code),
                        direction: DismissDirection.horizontal,
                        background: const _DismissBackground(
                          alignment: Alignment.centerLeft,
                        ),
                        secondaryBackground: const _DismissBackground(
                          alignment: Alignment.centerRight,
                        ),
                        confirmDismiss: (_) => _confirmCancel(context, ticket),
                        onDismissed: (_) => _cancelNow(context, ticket),
                        child: _TicketCard(
                          ticket: ticket,
                          onCancel: () async {
                            final confirmed = await _confirmCancel(
                              context,
                              ticket,
                            );
                            if (!confirmed || !context.mounted) return;
                            _cancelNow(context, ticket);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<bool> _confirmCancel(
    BuildContext context,
    RegistrationTicket ticket,
  ) async {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.event_busy_rounded, size: 30, color: scheme.error),
          title: const Text('Batalkan tiket?'),
          content: Text(
            'Tiket ${ticket.code} untuk "${ticket.event.title}" akan dibatalkan '
            'dan tidak bisa dipakai lagi saat hari acara.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Kembali'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              child: const Text('Ya, batalkan'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  void _cancelNow(BuildContext context, RegistrationTicket ticket) {
    onCancel(ticket);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Tiket ${ticket.code} dibatalkan')),
            ],
          ),
        ),
      );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onCancel});

  final RegistrationTicket ticket;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final event = ticket.event;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [event.posterStart, event.posterEnd],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        event.category.icon,
                        size: 18,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            ticket.code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: scheme.onTertiaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AKTIF',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _DashedDivider(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    _TicketFact(
                      icon: Icons.event_available_rounded,
                      label: 'Hadir',
                      value: formatDate(ticket.attendanceDate),
                    ),
                    _TicketFact(
                      icon: Icons.person_rounded,
                      label: 'Peserta',
                      value: ticket.participantName,
                    ),
                    _TicketFact(
                      icon: Icons.school_rounded,
                      label: 'Tipe',
                      value: ticket.participantType.label,
                    ),
                    _TicketFact(
                      icon: Icons.inventory_2_rounded,
                      label: 'Kit',
                      value: ticket.kit.label,
                    ),
                    _TicketFact(
                      icon: Icons.payments_rounded,
                      label: 'Total',
                      value: formatRupiah(ticket.total),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.place_rounded,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.delete_outline_rounded, size: 17),
                      label: const Text('Batalkan'),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketFact extends StatelessWidget {
  const _TicketFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(
              Icons.delete_sweep_rounded,
              color: scheme.onErrorContainer,
              size: 22,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            'Batalkan',
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          if (!isLeft) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.delete_sweep_rounded,
              color: scheme.onErrorContainer,
              size: 22,
            ),
          ],
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashPainter(Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 8) {
      canvas.drawLine(Offset(x, 0.5), Offset(x + 4, 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _EmptyTickets extends StatelessWidget {
  const _EmptyTickets({required this.onBrowseEvents});

  final VoidCallback onBrowseEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.confirmation_number_outlined,
                      size: 32,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada tiket aktif',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daftar seminar favoritmu, tiket akan muncul di tab ini dan '
                    'bisa dibatalkan kapan saja.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: onBrowseEvents,
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: const Text('Cari seminar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
