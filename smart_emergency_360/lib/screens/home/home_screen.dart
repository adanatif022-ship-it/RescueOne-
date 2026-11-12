import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/hospital.dart';
import '../../core/models/incident.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/incident_repository.dart';
import '../../core/services/notifications_repository.dart';
import '../../core/services/settings_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/display_name.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/premium_card.dart';
import '../../core/widgets/service_icon.dart';
import '../../core/widgets/responsive_section.dart';
import '../../core/widgets/section_title.dart';
import '../assistant/ai_assistant_screen.dart';
import '../contacts/trusted_contacts_screen.dart';
import '../history/incident_details_screen.dart';
import '../history/incident_history_screen.dart';
import '../hospitals/hospital_details_screen.dart';
import '../hospitals/hospital_list_screen.dart';
import '../maps/maps_screen.dart';
import '../notifications/notifications_screen.dart';
import '../places/saved_places_screen.dart';
import '../profile/emergency_profile_screen.dart';
import '../profile/profile_screen.dart';
import '../sos/emergency_type_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidentRepo = context.watch<IncidentRepository>();
    final hospitalRepo = context.watch<HospitalRepository>();
    final activeIncident = incidentRepo.activeIncident;
    final showLocationCard =
        !hospitalRepo.hasRealFix &&
        (hospitalRepo.locationErrorKey != null || !hospitalRepo.hasStarted);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => hospitalRepo.refresh(force: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ResponsiveSection(
              vertical: AppTheme.space3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HomeHeader(),
                  const SizedBox(height: AppTheme.space5),
                  // The emergency action comes first - visible without
                  // scrolling on every phone.
                  if (activeIncident != null) ...[
                    _ActiveIncidentCard(incident: activeIncident),
                    const SizedBox(height: AppTheme.space4),
                  ],
                  const _SosHero(),
                  const SizedBox(height: AppTheme.space3),
                  if (activeIncident == null) const _SafetyStatusRow(),
                  const SizedBox(height: AppTheme.space5),
                  SectionTitle(title: context.tr('home_quick_services')),
                  const _QuickServicesRow(),
                  if (showLocationCard) ...[
                    const SizedBox(height: AppTheme.space5),
                    _LocationStatusCard(hospitalRepo: hospitalRepo),
                  ],
                  const SizedBox(height: AppTheme.space5),
                  SectionTitle(
                    title: context.tr('home_hospital_routing_title'),
                    trailing: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HospitalListScreen(),
                        ),
                      ),
                      child: Text(context.tr('view_all')),
                    ),
                  ),
                  _RecommendedHospitalCard(repo: hospitalRepo),
                  const SizedBox(height: AppTheme.space5),
                  SectionTitle(title: context.tr('home_shortcuts_title')),
                  const _ShortcutsGrid(),
                  const SizedBox(height: AppTheme.space5),
                  SectionTitle(
                    title: context.tr('home_recent_incidents'),
                    trailing: incidentRepo.incidents.isEmpty
                        ? null
                        : TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const IncidentHistoryScreen(),
                              ),
                            ),
                            child: Text(context.tr('view_all')),
                          ),
                  ),
                  _RecentIncidentsList(incidents: incidentRepo.incidents),
                  const SizedBox(height: 112), // clears the central SOS FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand line, greeting with the user's name, live location status, and
/// the notification bell - one compact row instead of a large logo block.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final hospitalRepo = context.watch<HospitalRepository>();
    final notifications = context.watch<NotificationsRepository>();
    final alertsOn = context.watch<SettingsRepository>().notificationsEnabled;
    final unread = alertsOn ? notifications.unreadCount : 0;
    final displayName = userDisplayName(context);

    final (locationIcon, locationColor, locationText) = hospitalRepo.isLoading
        ? (
            Icons.location_searching_rounded,
            AppColors.textSecondary,
            context.tr('home_location_detecting'),
          )
        : hospitalRepo.hasRealFix
        ? (
            Icons.location_on_rounded,
            AppColors.success,
            context.tr('home_location_on'),
          )
        : (
            Icons.location_off_rounded,
            AppColors.textSecondary,
            context.tr('home_location_off'),
          );

    return Row(
      children: [
        Tooltip(
          message: context.tr('profile_screen_title'),
          child: Material(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // "Hello, Guest" / "مرحبًا، ضيف" - language-specific comma.
                '${context.tr('home_hello')}${context.tr('comma')}$displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              // Tap to re-detect location.
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => hospitalRepo.refresh(force: true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(locationIcon, size: 15, color: locationColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.tr('notifications_title'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: BorderSide(color: AppColors.border),
            minimumSize: const Size(48, 48),
          ),
          icon: Badge(
            isLabelVisible: unread > 0,
            label: Text(unread > 9 ? '9+' : '$unread'),
            backgroundColor: AppColors.dangerRed,
            child: Icon(
              unread > 0
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The main emergency action: large, high-contrast, at the top of Home,
/// with a slow pulse (skipped when the system asks for reduced motion).
class _SosHero extends StatefulWidget {
  const _SosHero();

  @override
  State<_SosHero> createState() => _SosHeroState();
}

class _SosHeroState extends State<_SosHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A few pulses to draw the eye when Home appears, then rest - an
    // endless animation distracts and costs battery. None at all when the
    // system asks for reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (!_started) {
      _started = true;
      _pulse.repeat(count: 3);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _open() {
    HapticFeedback.heavyImpact();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EmergencyTypeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    return Semantics(
      button: true,
      label: '${context.tr('home_sos_button')}. ${context.tr('home_sos_hint')}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.dangerRed, AppColors.vividDangerRed],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.dangerRed.withValues(
                alpha: AppColors.isDark ? 0.25 : 0.32,
              ),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: _open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Row(
                children: [
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final t = _pulse.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Expanding ring.
                            Container(
                              width: 60 + 24 * t,
                              height: 60 + 24 * t,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(
                                  alpha: 0.22 * (1 - t),
                                ),
                              ),
                            ),
                            child!,
                          ],
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emergency_rounded,
                          color: AppColors.dangerRed,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('home_sos_button'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('home_sos_hint'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Calm one-line status when nothing is happening.
class _SafetyStatusRow extends StatelessWidget {
  const _SafetyStatusRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_rounded,
          size: 18,
          color: AppColors.success,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            context.tr('home_safety_status_ok'),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Prominent card for an incident that is still in progress.
class _ActiveIncidentCard extends StatelessWidget {
  final Incident incident;
  const _ActiveIncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    return Material(
      color: AppColors.dangerRed.withValues(
        alpha: AppColors.isDark ? 0.16 : 0.08,
      ),
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => IncidentDetailsScreen(incidentId: incident.id),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.space4),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: AppColors.dangerRed.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.dangerRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  incidentStatusIcon(incident.status),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('home_safety_status_active'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dangerRed,
                      ),
                    ),
                    Text(
                      '${context.tr(incidentTypeKey(incident.type))} · '
                      '${context.tr(incidentStatusKey(incident.status))}',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ambulance / Police / Fire / Protection as one compact row - each opens
/// the SOS flow with that type preselected.
class _QuickServicesRow extends StatelessWidget {
  const _QuickServicesRow();

  @override
  Widget build(BuildContext context) {
    void openSos(IncidentType type) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EmergencyTypeScreen(initialType: type),
        ),
      );
    }

    final items = [
      (
        Icons.medical_services_rounded,
        'home_call_ambulance',
        AppColors.serviceMedical,
        IncidentType.medical,
      ),
      (
        Icons.local_police_rounded,
        'home_call_police',
        AppColors.servicePolice,
        IncidentType.security,
      ),
      (
        Icons.local_fire_department_rounded,
        'home_call_fire',
        AppColors.serviceFire,
        IncidentType.fire,
      ),
      (
        Icons.security_rounded,
        'home_personal_protection',
        AppColors.serviceProtection,
        IncidentType.danger,
      ),
    ];

    // Equal-height tiles even when one label wraps onto two lines.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppTheme.space2),
            Expanded(
              child: _QuickServiceTile(
                icon: items[i].$1,
                label: context.tr(items[i].$2),
                color: items[i].$3,
                onTap: () => openSos(items[i].$4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickServiceTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.border),
            ),
            // Large accessibility text sizes are capped so the row of four
            // never overflows.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: Column(
                children: [
                  ServiceIcon(icon: icon, color: color),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown only when location is off or failed - with the reason and a
/// retry, so the user knows why hospitals are missing.
class _LocationStatusCard extends StatelessWidget {
  final HospitalRepository hospitalRepo;
  const _LocationStatusCard({required this.hospitalRepo});

  @override
  Widget build(BuildContext context) {
    final loading = hospitalRepo.isLoading;
    final error = hospitalRepo.locationErrorKey;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_rounded, color: Color(0xFFB26A00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loading
                  ? context.tr('home_location_detecting')
                  : error != null
                  ? context.tr(locationErrorKey(error))
                  : context.tr('home_location_off'),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => hospitalRepo.refresh(force: true),
              child: Text(context.tr('retry')),
            ),
        ],
      ),
    );
  }
}

class _RecommendedHospitalCard extends StatelessWidget {
  final HospitalRepository repo;
  const _RecommendedHospitalCard({required this.repo});

  @override
  Widget build(BuildContext context) {
    final Hospital? recommended = repo.topRecommendation;

    if (recommended == null) {
      final loading = repo.isLoading;
      return PremiumCard(
        child: Row(
          children: [
            if (loading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            else
              Icon(
                Icons.local_hospital_outlined,
                color: AppColors.textSecondary,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loading
                    ? context.tr('home_hospitals_loading')
                    : repo.overpassErrorKey != null
                    ? context.tr(overpassErrorKey(repo.overpassErrorKey))
                    : context.tr('home_no_hospitals'),
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            if (!loading)
              TextButton(
                onPressed: () => repo.refresh(force: true),
                child: Text(
                  repo.hasStarted
                      ? context.tr('retry')
                      : context.tr('home_find_hospitals'),
                ),
              ),
          ],
        ),
      );
    }

    final isArabic = context.lang.isArabic;
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              HospitalDetailsScreen(hospital: recommended, isRecommended: true),
        ),
      ),
      child: PremiumCard(
        highlighted: true,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommended.nameFor(arabic: isArabic),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${recommended.distanceKm.toStringAsFixed(1)} ${context.tr('hospitals_km_short')} · '
                    '${recommended.travelTimeMinutes} ${context.tr('hospitals_min_short')} · '
                    '${context.tr(congestionKey(recommended.congestion))}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (repo.usingSavedData) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('home_saved_data_short'),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}

class _ShortcutsGrid extends StatelessWidget {
  const _ShortcutsGrid();

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    final items = [
      (
        Icons.local_hospital_rounded,
        'home_hospital_routing_title',
        AppColors.primaryBlue,
        () => open(const HospitalListScreen()),
      ),
      (
        Icons.contacts_rounded,
        'home_trusted_contacts',
        AppColors.secondaryBlue,
        () => open(const TrustedContactsScreen()),
      ),
      (
        Icons.badge_rounded,
        'settings_profile',
        AppColors.brightBlue,
        () => open(const EmergencyProfileScreen()),
      ),
      (
        Icons.smart_toy_rounded,
        'home_ai_assistant',
        AppColors.softPurple,
        () => open(const AiAssistantScreen()),
      ),
      (
        Icons.map_rounded,
        'home_nearby_assistance',
        AppColors.success,
        () => open(const MapsScreen()),
      ),
      (
        Icons.bookmark_rounded,
        'profile_saved_places',
        AppColors.warning,
        () => open(const SavedPlacesScreen()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 64,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final (icon, key, color, onTap) = items[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.14),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr(key),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
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

class _RecentIncidentsList extends StatelessWidget {
  final List<Incident> incidents;
  const _RecentIncidentsList({required this.incidents});

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.tr('home_no_incidents'),
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    return Column(
      children: incidents.take(3).map((incident) {
        final color = incidentStatusColor(incident.status);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              ),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                child: Icon(
                  incidentTypeIcon(incident.type),
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              title: Text(
                context.tr(incidentTypeKey(incident.type)),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                incident.id,
                textDirection: TextDirection.ltr,
                textAlign: context.lang.isArabic
                    ? TextAlign.right
                    : TextAlign.left,
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.tr(incidentStatusKey(incident.status)),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      IncidentDetailsScreen(incidentId: incident.id),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
