import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/osm_place.dart';
import '../../core/services/hospital_data.dart';
import '../../core/services/hospital_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/services/nearby_services_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/ltr_text.dart';

enum _Filter { all, hospitals, police, fire, pharmacy }

class _Place {
  final String name;
  final OsmPlaceKind kind;
  final double lat;
  final double lng;
  final double distanceKm;
  final bool recommended;
  final String? phone;

  const _Place({
    required this.name,
    required this.kind,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.recommended = false,
    this.phone,
  });
}

/// Nearby assistance: real hospitals, clinics, police stations, fire
/// stations and pharmacies around the user, all from OpenStreetMap,
/// sorted by real distance. There is no embedded map (that needs a paid
/// maps key) - each place opens directly in Google Maps instead.
class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool force = false}) async {
    final hospitals = context.read<HospitalRepository>();
    final nearby = context.read<NearbyServicesRepository>();
    if (!hospitals.hasRealFix || force) {
      await hospitals.refresh(force: force);
    }
    if (!mounted || !hospitals.hasRealFix) return;
    await nearby.ensureLoaded(
      hospitals.currentLat,
      hospitals.currentLng,
      force: force,
    );
  }

  bool _matches(_Place p) {
    switch (_filter) {
      case _Filter.all:
        return true;
      case _Filter.hospitals:
        return p.kind == OsmPlaceKind.hospital || p.kind == OsmPlaceKind.clinic;
      case _Filter.police:
        return p.kind == OsmPlaceKind.police;
      case _Filter.fire:
        return p.kind == OsmPlaceKind.fireStation;
      case _Filter.pharmacy:
        return p.kind == OsmPlaceKind.pharmacy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hospitalRepo = context.watch<HospitalRepository>();
    final nearby = context.watch<NearbyServicesRepository>();
    final recommendedId = hospitalRepo.topRecommendation?.id;
    final isArabic = context.lang.isArabic;
    final lat = hospitalRepo.currentLat;
    final lng = hospitalRepo.currentLng;

    final places = <_Place>[
      for (final h in hospitalRepo.hospitals)
        _Place(
          name: h.nameFor(arabic: isArabic),
          kind: h.isClinic ? OsmPlaceKind.clinic : OsmPlaceKind.hospital,
          lat: h.latitude,
          lng: h.longitude,
          distanceKm: h.distanceKm,
          recommended: h.id == recommendedId,
          phone: h.phone,
        ),
      for (final p in nearby.places)
        _Place(
          name: p.displayName(arabic: isArabic),
          kind: p.kind,
          lat: p.latitude,
          lng: p.longitude,
          distanceKm: haversineKm(lat, lng, p.latitude, p.longitude),
          phone: p.phone,
        ),
    ]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    final filtered = places.where(_matches).toList();
    final loading = hospitalRepo.isLoading || nearby.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('maps_title'))),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      leading: Icon(
                        Icons.my_location_rounded,
                        color: AppColors.primaryBlue,
                      ),
                      title: Text(context.tr('maps_current_location')),
                      subtitle: hospitalRepo.hasRealFix
                          ? LtrText(
                              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                              style: TextStyle(color: AppColors.textSecondary),
                            )
                          : Text(context.tr('maps_need_location')),
                      trailing: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton(
                              onPressed: () => _load(force: true),
                              child: Text(context.tr('maps_locate_me')),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const DisclaimerBanner(
                    textKey: 'maps_real_data_notice',
                    icon: Icons.public_rounded,
                  ),
                  if (nearby.errorKey != null && nearby.places.isEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr('maps_services_error'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _load(force: true),
                          child: Text(context.tr('retry')),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  for (final (filter, key, count) in [
                    (_Filter.all, 'maps_filter_all', places.length),
                    (
                      _Filter.hospitals,
                      'maps_hospitals',
                      places
                          .where(
                            (p) =>
                                p.kind == OsmPlaceKind.hospital ||
                                p.kind == OsmPlaceKind.clinic,
                          )
                          .length,
                    ),
                    (
                      _Filter.police,
                      'maps_police',
                      places.where((p) => p.kind == OsmPlaceKind.police).length,
                    ),
                    (
                      _Filter.fire,
                      'maps_fire',
                      places
                          .where((p) => p.kind == OsmPlaceKind.fireStation)
                          .length,
                    ),
                    (
                      _Filter.pharmacy,
                      'maps_pharmacies',
                      places
                          .where((p) => p.kind == OsmPlaceKind.pharmacy)
                          .length,
                    ),
                  ])
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text('${context.tr(key)} ($count)'),
                        selected: _filter == filter,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _filter = filter),
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          color: _filter == filter
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: loading
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 12),
                                  Text(
                                    context.tr('maps_services_loading'),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                hospitalRepo.hasRealFix
                                    ? context.tr('maps_no_places')
                                    : context.tr('maps_need_location'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _load(force: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _PlaceTile(place: filtered[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final _Place place;
  const _PlaceTile({required this.place});

  @override
  Widget build(BuildContext context) {
    final color = placeKindColor(place.kind);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            final ok = await LauncherService().openMapsForCoordinates(
              latitude: place.lat,
              longitude: place.lng,
            );
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.trRead('maps_open_failed'))),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: color.withValues(alpha: 0.13),
                  child: Icon(placeKindIcon(place.kind), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${context.tr(placeKindKey(place.kind))} · '
                            '${place.distanceKm.toStringAsFixed(1)} ${context.tr('hospitals_km_short')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (place.recommended)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                context.tr('maps_recommended'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (place.phone != null)
                  IconButton(
                    tooltip: context.tr('hospitals_phone'),
                    icon: const Icon(
                      Icons.call_rounded,
                      color: AppColors.success,
                    ),
                    onPressed: () => LauncherService().callNumber(place.phone!),
                  ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
