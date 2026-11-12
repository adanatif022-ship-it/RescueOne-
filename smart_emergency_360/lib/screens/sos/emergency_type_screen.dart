import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/incident.dart';
import '../../core/models/trusted_contact.dart';
import '../../core/services/contacts_repository.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/incident_repository.dart';
import '../../core/services/location_service.dart';
import '../../core/services/settings_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/responsive_section.dart';
import '../../core/widgets/service_grid_card.dart';
import 'incident_progress_screen.dart';

/// Step 1-5 of the Smart SOS flow: pick the incident type, attach location,
/// optionally toggle Silent SOS, then confirm before anything is created.
/// The SOS button never starts a phone call by itself.
class EmergencyTypeScreen extends StatefulWidget {
  final IncidentType? initialType;
  const EmergencyTypeScreen({super.key, this.initialType});

  @override
  State<EmergencyTypeScreen> createState() => _EmergencyTypeScreenState();
}

enum _LocationState { idle, detecting, attached, failed }

class _EmergencyTypeScreenState extends State<EmergencyTypeScreen> {
  late IncidentType? _selectedType = widget.initialType;
  final _descriptionController = TextEditingController();
  bool _silent = false;
  _LocationState _locationState = _LocationState.idle;
  double? _lat;
  double? _lng;
  double? _accuracyMeters;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    // context.read (listen:false) is safe in initState - unlike context.tr/
    // watch, it never registers a build dependency.
    _silent = context.read<SettingsRepository>().silentModeDefault;
    _detectLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _locationState = _LocationState.detecting);
    final result = await context.read<LocationService>().getCurrentLocation();
    if (!mounted) return;
    if (result.hasLocation) {
      setState(() {
        _lat = result.latitude;
        _accuracyMeters = result.accuracyMeters;
        _lng = result.longitude;
        _locationState = _LocationState.attached;
      });
      // Prepare the hospital recommendation around this exact spot while
      // the user is still choosing - it doesn't block the alert.
      context.read<HospitalRepository>().useLocation(
        _lat!,
        _lng!,
        accuracyMeters: result.accuracyMeters,
        approximateOnly: result.approximateOnly,
      );
    } else {
      setState(() => _locationState = _LocationState.failed);
    }
  }

  Future<void> _openConfirmDialog() async {
    if (_selectedType == null) return;
    final notifiedContacts = context
        .read<ContactsRepository>()
        .notifiedContacts;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _ConfirmDialog(
        type: _selectedType!,
        silent: _silent,
        locationAttached: _locationState == _LocationState.attached,
        notifiedContacts: notifiedContacts,
      ),
    );
    if (confirmed != true || !mounted) return;

    // Gives the user one last cancelable window before the prototype alert
    // is actually created - never sends anything until this counts down.
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _SendingCountdownDialog(),
    );
    if (proceed == true && mounted) {
      await _createIncident();
    }
  }

  Future<void> _createIncident() async {
    setState(() => _creating = true);
    final hospitalRepo = context.read<HospitalRepository>();
    // Uses whatever real hospital data is available right now - creating
    // the alert never waits for the network.
    final recommended = hospitalRepo.recommendationFor(_selectedType!);

    final incident = await context.read<IncidentRepository>().createIncident(
      type: _selectedType!,
      description: _descriptionController.text.trim(),
      mode: _silent ? AlertMode.silent : AlertMode.normal,
      location: (_lat != null && _lng != null)
          ? IncidentLocation(latitude: _lat!, longitude: _lng!)
          : null,
      recommendedHospital: recommended,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => IncidentProgressScreen(incidentId: incident.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('sos_select_type_title'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveSection(
              vertical: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('sos_select_type_subtitle'),
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  _TypeGrid(
                    selected: _selectedType,
                    onSelected: (type) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = type);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('sos_description_label'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: context.tr('sos_description_hint'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _LocationCard(
                    state: _locationState,
                    onRetry: _detectLocation,
                    accuracyMeters: _accuracyMeters,
                  ),
                  const SizedBox(height: 16),
                  _SilentToggleCard(
                    value: _silent,
                    onChanged: (v) => setState(() => _silent = v),
                  ),
                  const SizedBox(height: 20),
                  const DisclaimerBanner(textKey: 'sos_prototype_notice'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      // Always-visible primary action - no scrolling to the end of the
      // form in an emergency.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: ElevatedButton.icon(
              onPressed: (_selectedType == null || _creating)
                  ? null
                  : _openConfirmDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                disabledBackgroundColor: AppColors.subtleFill,
                disabledForegroundColor: AppColors.textSecondary,
              ),
              icon: _creating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.emergency_share_rounded),
              label: Text(context.tr('sos_continue')),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  final IncidentType? selected;
  final ValueChanged<IncidentType> onSelected;

  const _TypeGrid({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    // Fixed row height instead of an aspect ratio - see ServiceGridCard.
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: ServiceGridCard.gridDelegate(withSubtitle: true),
      itemCount: IncidentType.values.length,
      itemBuilder: (context, index) {
        final type = IncidentType.values[index];
        return ServiceGridCard(
          icon: incidentTypeIcon(type),
          title: context.tr(incidentTypeKey(type)),
          subtitle: context.tr(incidentTypeDescKey(type)),
          selected: type == selected,
          onTap: () => onSelected(type),
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  final _LocationState state;
  final double? accuracyMeters;
  final VoidCallback onRetry;

  const _LocationCard({
    required this.state,
    required this.onRetry,
    this.accuracyMeters,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, textKey, color) = switch (state) {
      _LocationState.idle => (
        Icons.location_searching_rounded,
        'sos_location_attach',
        AppColors.textSecondary,
      ),
      _LocationState.detecting => (
        Icons.location_searching_rounded,
        'sos_location_detecting',
        AppColors.primaryBlue,
      ),
      _LocationState.attached => (
        Icons.location_on_rounded,
        'sos_location_attached',
        AppColors.success,
      ),
      _LocationState.failed => (
        Icons.location_off_rounded,
        'sos_location_failed',
        AppColors.dangerRed,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                // e.g. "Location attached (±12 m)" - so the user knows
                // how close the shared position is.
                state == _LocationState.attached && accuracyMeters != null
                    ? '${context.tr(textKey)} (±${accuracyMeters!.round()} m)'
                    : context.tr(textKey),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (state == _LocationState.failed || state == _LocationState.idle)
              TextButton(
                onPressed: onRetry,
                child: Text(context.tr('sos_location_attach')),
              ),
            if (state == _LocationState.detecting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }
}

class _SilentToggleCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SilentToggleCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: value ? AppColors.darkBlue : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.volume_off_rounded,
              color: value ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('sos_silent_title'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: value ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.tr('sos_silent_description'),
                    style: TextStyle(
                      fontSize: 12,
                      color: value
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.secondaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatelessWidget {
  final IncidentType type;
  final bool silent;
  final bool locationAttached;
  final List<TrustedContact> notifiedContacts;

  const _ConfirmDialog({
    required this.type,
    required this.silent,
    required this.locationAttached,
    required this.notifiedContacts,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('sos_confirm_title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ConfirmRow(
            label: context.tr('sos_confirm_type_label'),
            value: context.tr(incidentTypeKey(type)),
          ),
          _ConfirmRow(
            label: context.tr('sos_confirm_location_label'),
            value: locationAttached
                ? context.tr('sos_confirm_location_yes')
                : context.tr('sos_confirm_location_no'),
          ),
          _ConfirmRow(
            label: context.tr('sos_confirm_mode_label'),
            value: silent
                ? context.tr('sos_confirm_mode_silent')
                : context.tr('sos_confirm_mode_normal'),
          ),
          _ConfirmRow(
            label: context.tr('sos_confirm_contacts_label'),
            value: notifiedContacts.isEmpty
                ? context.tr('none')
                : context.lang.joinList(notifiedContacts.map((c) => c.name)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.tr('sos_cancel_button')),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          // Red like every other step that starts an emergency alert.
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
          icon: const Icon(Icons.emergency_share_rounded),
          label: Text(context.tr('sos_confirm_button')),
        ),
      ],
    );
  }
}

/// A cancelable countdown shown after confirmation and before the
/// prototype incident is actually created - gives the user one last
/// chance to back out. Auto-resolves `true` (proceed) when it reaches
/// zero, or `false` (cancelled) if the user taps Cancel.
class _SendingCountdownDialog extends StatefulWidget {
  const _SendingCountdownDialog();

  @override
  State<_SendingCountdownDialog> createState() =>
      _SendingCountdownDialogState();
}

class _SendingCountdownDialogState extends State<_SendingCountdownDialog>
    with SingleTickerProviderStateMixin {
  static const _startSeconds = 5;
  int _secondsLeft = _startSeconds;
  Timer? _timer;

  // `preserve` keeps real timing even when the system reduces motion -
  // the ring shows time, it isn't decoration.
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _startSeconds),
    animationBehavior: AnimationBehavior.preserve,
  )..forward();

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        Navigator.of(context).pop(true);
        return;
      }
      HapticFeedback.selectionClick();
      setState(() => _secondsLeft--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.tr('sos_sending_countdown_title'),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            liveRegion: true,
            label: '$_secondsLeft',
            child: SizedBox(
              width: 128,
              height: 128,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: AnimatedBuilder(
                      animation: _ring,
                      builder: (context, _) => CircularProgressIndicator(
                        value: 1 - _ring.value,
                        strokeWidth: 9,
                        strokeCap: StrokeCap.round,
                        color: AppColors.dangerRed,
                        backgroundColor: AppColors.dangerRed.withValues(
                          alpha: 0.14,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '$_secondsLeft',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: AppColors.dangerRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('sos_sending_countdown_body'),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerRed,
              side: BorderSide(color: AppColors.dangerRed, width: 1.5),
            ),
            icon: const Icon(Icons.close_rounded),
            label: Text(context.tr('sos_cancel_button')),
          ),
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
