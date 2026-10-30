import 'package:flutter/material.dart';

import '../models/event_item.dart';

enum EventSort {
  soonest('Terdekat', Icons.event_available_rounded),
  priceLow('Harga terendah', Icons.south_rounded),
  priceHigh('Harga tertinggi', Icons.north_rounded);

  const EventSort(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// State filter yang dipakai halaman Seminar & Workshop.
@immutable
class EventFilter {
  const EventFilter({
    this.categories = const <EventCategory>{},
    this.sort = EventSort.soonest,
    this.onlyAvailable = false,
  });

  final Set<EventCategory> categories;
  final EventSort sort;
  final bool onlyAvailable;

  bool get isActive =>
      categories.isNotEmpty || sort != EventSort.soonest || onlyAvailable;

  int get activeCount =>
      categories.length +
      (sort != EventSort.soonest ? 1 : 0) +
      (onlyAvailable ? 1 : 0);

  EventFilter copyWith({
    Set<EventCategory>? categories,
    EventSort? sort,
    bool? onlyAvailable,
  }) {
    return EventFilter(
      categories: categories ?? this.categories,
      sort: sort ?? this.sort,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
    );
  }

  List<EventItem> apply(List<EventItem> events) {
    final filtered = events.where((event) {
      final matchesCategory =
          categories.isEmpty || categories.contains(event.category);
      final matchesAvailability = !onlyAvailable || !event.isSoldOut;
      return matchesCategory && matchesAvailability;
    }).toList();

    switch (sort) {
      case EventSort.soonest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
      case EventSort.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case EventSort.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
    }
    return filtered;
  }
}

/// Membuka bottom sheet filter dan mengembalikan filter baru bila diterapkan.
Future<EventFilter?> showEventFilterSheet(
  BuildContext context,
  EventFilter current,
) {
  return showModalBottomSheet<EventFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final EventFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<EventCategory> _categories;
  late EventSort _sort;
  late bool _onlyAvailable;

  @override
  void initState() {
    super.initState();
    _categories = {...widget.initial.categories};
    _sort = widget.initial.sort;
    _onlyAvailable = widget.initial.onlyAvailable;
  }

  EventFilter get _result => EventFilter(
    categories: _categories,
    sort: _sort,
    onlyAvailable: _onlyAvailable,
  );

  void _toggleCategory(EventCategory category, bool selected) {
    setState(() {
      if (selected) {
        _categories = {..._categories, category};
      } else {
        _categories = {..._categories}..remove(category);
      }
    });
  }

  void _reset() {
    setState(() {
      _categories = <EventCategory>{};
      _sort = EventSort.soonest;
      _onlyAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter & urutkan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pilih kategori, urutan tampil, dan ketersediaan kursi.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _Label(text: 'Kategori'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in EventCategory.values)
                  FilterChip(
                    avatar: Icon(category.icon, size: 16),
                    label: Text(category.label),
                    selected: _categories.contains(category),
                    onSelected: (selected) =>
                        _toggleCategory(category, selected),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            _Label(text: 'Urutkan'),
            const SizedBox(height: 6),
            for (final sort in EventSort.values)
              _SortOption(
                icon: sort.icon,
                label: sort.label,
                selected: _sort == sort,
                onTap: () => setState(() => _sort = sort),
              ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _onlyAvailable,
              onChanged: (value) => setState(() => _onlyAvailable = value),
              title: const Text(
                'Hanya event tersedia',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text('Sembunyikan event yang kuotanya habis'),
              secondary: Icon(
                Icons.event_seat_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_result),
                    child: Text(
                      _result.isActive
                          ? 'Terapkan (${_result.activeCount})'
                          : 'Terapkan',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.2),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? scheme.primary : scheme.outline,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 17, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
