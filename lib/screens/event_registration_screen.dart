import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';

/// Formulir pendaftaran dengan validasi, date picker, dan indikator loading.
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();

  ParticipantType _participantType = ParticipantType.mahasiswa;
  SeminarKit _kit = SeminarKit.standard;
  DateTime? _attendanceDate;
  double _donation = 0;
  bool _agreed = false;
  bool _isSubmitting = false;

  static final RegExp _namePattern = RegExp(r"^[a-zA-Z .'\-]+$");
  static final RegExp _nimPattern = RegExp(r'^\d{8,12}$');
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _phonePattern = RegExp(r'^(\+62|62|0)8\d{8,11}$');

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  int get _total =>
      widget.event.price +
      _participantType.surcharge +
      _kit.price +
      _donation.round();

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Nama lengkap wajib diisi';
    if (text.length < 3) return 'Nama minimal 3 karakter';
    if (!_namePattern.hasMatch(text)) {
      return 'Gunakan huruf, spasi, titik, atau tanda hubung';
    }
    return null;
  }

  String? _validateNim(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'NIM wajib diisi';
    if (!_nimPattern.hasMatch(text)) return 'NIM harus 8–12 digit angka';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email wajib diisi';
    if (!_emailPattern.hasMatch(text)) {
      return 'Format email belum benar, contoh: nama@nusaputra.ac.id';
    }
    return null;
  }

  String? _validateWhatsapp(String? value) {
    final text = _normalizePhone(value ?? '');
    if (text.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (!_phonePattern.hasMatch(text)) {
      return 'Gunakan format 08xxxxxxxxxx atau +62xxxxxxxxxx';
    }
    return null;
  }

  String _normalizePhone(String value) =>
      value.replaceAll(RegExp(r'[\s-]'), '').trim();

  Future<void> _pickAttendanceDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final eventLastDay = widget.event.date.add(const Duration(days: 7));
    final lastDate = eventLastDay.isBefore(firstDate)
        ? firstDate
        : eventLastDay;
    final initial = _attendanceDate ?? widget.event.date;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate) ? lastDate : initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Pilih tanggal kehadiran',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      fieldLabelText: 'Tanggal kehadiran',
      fieldHintText: 'dd/mm/yyyy',
    );

    if (picked == null || !mounted) return;
    setState(() => _attendanceDate = picked);
    field.didChange(picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Lengkapi dulu data yang ditandai merah.'),
          ),
        );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final ticket = RegistrationTicket.create(
      event: widget.event,
      participantName: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      email: _emailController.text.trim(),
      whatsapp: _normalizePhone(_whatsappController.text),
      participantType: _participantType,
      attendanceDate: _attendanceDate!,
      kit: _kit,
      donation: _donation.round(),
    );

    Navigator.of(context).pop(ticket);
  }

  void _showRules() {
    final rules = <String>[
      'Hadir minimal 15 menit sebelum sesi dimulai dan membawa kartu identitas.',
      'Tiket berlaku untuk satu peserta dan tidak dapat dipindahtangankan.',
      'Menjaga ketertiban, kebersihan, dan etika selama acara berlangsung.',
      'Pembatalan tiket dilakukan paling lambat 1 hari sebelum acara.',
      'Panitia berhak mengubah susunan acara dengan pemberitahuan terlebih dahulu.',
    ];

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.gavel_rounded, size: 28),
          title: const Text('Tata tertib acara'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < rules.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}.',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rules[i])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return PopScope(
      canPop: !_isSubmitting,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pendaftaran'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.event.category.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _EventSummaryCard(event: widget.event),
                const SizedBox(height: 14),
                _Section(
                  icon: Icons.badge_rounded,
                  title: 'Data peserta',
                  subtitle: 'Isi sesuai kartu identitas agar tiket valid.',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                          hintText: 'Contoh: Amal Hidayah',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nimController,
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'NIM',
                          hintText: '8–12 digit angka',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: _validateNim,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'nama@nusaputra.ac.id',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _whatsappController,
                        enabled: !_isSubmitting,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nomor WhatsApp',
                          hintText: '08xxxxxxxxxx',
                          prefixIcon: Icon(Icons.chat_outlined),
                        ),
                        validator: _validateWhatsapp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Section(
                  icon: Icons.event_seat_rounded,
                  title: 'Detail kehadiran',
                  subtitle: 'Pilih tipe peserta dan tanggal kamu hadir.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipe peserta',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final type in ParticipantType.values)
                            ChoiceChip(
                              avatar: Icon(type.icon, size: 16),
                              label: Text(type.label),
                              selected: _participantType == type,
                              onSelected: _isSubmitting
                                  ? null
                                  : (_) =>
                                        setState(() => _participantType = type),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _participantType.surcharge == 0
                            ? '${_participantType.description} • tanpa tambahan biaya.'
                            : '${_participantType.description} • tambahan '
                                  '${formatRupiah(_participantType.surcharge)}.',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FormField<DateTime>(
                        initialValue: _attendanceDate,
                        validator: (value) => value == null
                            ? 'Tanggal kehadiran wajib dipilih'
                            : null,
                        builder: (field) {
                          return InkWell(
                            onTap: _isSubmitting
                                ? null
                                : () => _pickAttendanceDate(field),
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tanggal kehadiran',
                                errorText: field.errorText,
                                prefixIcon: const Icon(
                                  Icons.calendar_month_rounded,
                                ),
                                suffixIcon: const Icon(
                                  Icons.expand_more_rounded,
                                ),
                              ),
                              child: Text(
                                _attendanceDate == null
                                    ? 'Pilih tanggal'
                                    : formatFullDate(_attendanceDate!),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _attendanceDate == null
                                      ? scheme.onSurfaceVariant
                                      : scheme.onSurface,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sesi event: ${formatFullDate(widget.event.date)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Section(
                  icon: Icons.inventory_2_rounded,
                  title: 'Seminar kit & donasi',
                  subtitle: 'Opsional, bisa diubah sebelum dikirim.',
                  child: Column(
                    children: [
                      for (final kit in SeminarKit.values) ...[
                        _KitOption(
                          kit: kit,
                          selected: _kit == kit,
                          enabled: !_isSubmitting,
                          onTap: () => setState(() => _kit = kit),
                        ),
                        if (kit != SeminarKit.values.last)
                          const SizedBox(height: 8),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Donasi pendidikan',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(_donation),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _donation,
                        max: 100000,
                        divisions: 20,
                        label: formatRupiah(_donation),
                        onChanged: _isSubmitting
                            ? null
                            : (value) => setState(() => _donation = value),
                      ),
                      Row(
                        children: [
                          Text(
                            'Rp 0',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Rp 100.000',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final preset in const [0, 10000, 25000, 50000])
                            ChoiceChip(
                              label: Text(
                                preset == 0
                                    ? 'Tanpa donasi'
                                    : formatRupiah(preset),
                              ),
                              selected: _donation.round() == preset,
                              onSelected: _isSubmitting
                                  ? null
                                  : (_) => setState(
                                      () => _donation = preset.toDouble(),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Section(
                  icon: Icons.receipt_long_rounded,
                  title: 'Ringkasan & persetujuan',
                  subtitle: 'Periksa total biaya sebelum mengirim.',
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Harga tiket (${_participantType.label})',
                        value: formatRupiah(
                          widget.event.price + _participantType.surcharge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Paket kit ${_kit.label}',
                        value: _kit.price == 0
                            ? 'Gratis'
                            : formatRupiah(_kit.price),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Donasi pendidikan',
                        value: formatRupiah(_donation),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total bayar',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            formatRupiah(_total),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: scheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FormField<bool>(
                        initialValue: _agreed,
                        validator: (value) => (value ?? false)
                            ? null
                            : 'Persetujuan tata tertib wajib dicentang',
                        builder: (field) {
                          final hasError = field.hasError;
                          return Material(
                            color: scheme.surfaceContainerLowest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: hasError
                                    ? scheme.error
                                    : scheme.outlineVariant,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 2, 8, 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CheckboxListTile(
                                    value: _agreed,
                                    onChanged: _isSubmitting
                                        ? null
                                        : (value) {
                                            final checked = value ?? false;
                                            setState(() => _agreed = checked);
                                            field.didChange(checked);
                                          },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'Saya menyetujui tata tertib acara',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    subtitle: Text(
                                      'Hadir tepat waktu, membawa identitas, dan '
                                      'menjaga ketertiban selama sesi.',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                    ),
                                  ),
                                  if (hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        bottom: 4,
                                      ),
                                      child: Text(
                                        field.errorText!,
                                        style: TextStyle(
                                          color: scheme.error,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: _showRules,
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        minimumSize: const Size(0, 34),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Baca tata tertib'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isSubmitting) ...[
                  const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _isSubmitting
                          ? const Row(
                              key: ValueKey('loading'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Memproses pendaftaran...'),
                              ],
                            )
                          : const Row(
                              key: ValueKey('idle'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 19,
                                ),
                                SizedBox(width: 8),
                                Text('Kirim pendaftaran'),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Data hanya dipakai untuk keperluan acara.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  const _EventSummaryCard({required this.event});

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 108,
            child: EventPoster(event: event, compact: true),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
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
                const SizedBox(height: 7),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MiniInfo(
                      icon: Icons.calendar_today_rounded,
                      label: event.dateLabel,
                    ),
                    _MiniInfo(
                      icon: Icons.schedule_rounded,
                      label: event.timeRange,
                    ),
                    _MiniInfo(icon: Icons.place_rounded, label: event.venue),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Text(
                      'Harga tiket',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      event.priceLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.primary,
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

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 190),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _KitOption extends StatelessWidget {
  const _KitOption({
    required this.kit,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final SeminarKit kit;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.45)
              : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? scheme.primary : scheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kit.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    kit.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              kit.price == 0 ? 'Gratis' : '+${formatRupiah(kit.price)}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
