import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/saved_place.dart';
import '../../core/services/launcher_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/saved_places_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ltr_text.dart';

/// Places the user saved (home, work, hospitals...). Each one opens in
/// Google Maps or copies a shareable map link - useful for telling
/// someone exactly where you are or where to come.
class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  Future<void> _addCurrentLocation(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddPlaceSheet(),
    );
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.trRead('saved_places_saved'))),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, SavedPlace place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('saved_places_delete_confirm')),
        content: Text(place.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              minimumSize: const Size(88, 44),
            ),
            child: Text(dialogContext.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<SavedPlacesRepository>().remove(place.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = context.watch<SavedPlacesRepository>().places;
    final dateFormat = DateFormat(
      'd MMM yyyy',
      context.lang.isArabic ? 'ar' : 'en',
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile_saved_places'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCurrentLocation(context),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: Text(context.tr('saved_places_add_current')),
      ),
      body: places.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_border_rounded,
                        size: 36,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('profile_no_saved_places'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.warning.withValues(
                              alpha: 0.15,
                            ),
                            child: const Icon(
                              Icons.place_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (place.note != null)
                                  Text(
                                    place.note!,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                LtrText(
                                  '${place.latitude.toStringAsFixed(5)}, '
                                  '${place.longitude.toStringAsFixed(5)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  dateFormat.format(place.savedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: context.tr('open_in_maps'),
                            icon: Icon(
                              Icons.map_rounded,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () =>
                                LauncherService().openMapsForCoordinates(
                                  latitude: place.latitude,
                                  longitude: place.longitude,
                                ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'copy') {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: LauncherService.mapsLink(
                                      place.latitude,
                                      place.longitude,
                                    ),
                                  ),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.trRead('link_copied'),
                                      ),
                                    ),
                                  );
                                }
                              } else if (value == 'delete') {
                                await _confirmDelete(context, place);
                              }
                            },
                            itemBuilder: (menuContext) => [
                              PopupMenuItem(
                                value: 'copy',
                                child: Text(menuContext.trRead('copy_link')),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(menuContext.trRead('delete')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Bottom sheet: gets a GPS fix, then asks for a name.
class _AddPlaceSheet extends StatefulWidget {
  const _AddPlaceSheet();

  @override
  State<_AddPlaceSheet> createState() => _AddPlaceSheetState();
}

class _AddPlaceSheetState extends State<_AddPlaceSheet> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  bool _locating = true;
  bool _failed = false;
  bool _nameMissing = false;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _locate();
  }

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _failed = false;
    });
    final result = await context.read<LocationService>().getCurrentLocation();
    if (!mounted) return;
    setState(() {
      _locating = false;
      _failed = !result.hasLocation;
      _lat = result.latitude;
      _lng = result.longitude;
    });
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameMissing = true);
      return;
    }
    if (_lat == null || _lng == null) return;
    await context.read<SavedPlacesRepository>().add(
      name: _name.text,
      latitude: _lat!,
      longitude: _lng!,
      note: _note.text,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('saved_places_add_current'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_failed ? AppColors.dangerRed : AppColors.primaryBlue)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  if (_locating)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _failed
                          ? Icons.location_off_rounded
                          : Icons.my_location_rounded,
                      color: _failed
                          ? AppColors.dangerRed
                          : AppColors.primaryBlue,
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _locating
                        ? Text(context.tr('saved_places_locating'))
                        : _failed
                        ? Text(context.tr('saved_places_location_failed'))
                        : LtrText(
                            '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                  if (_failed)
                    TextButton(
                      onPressed: _locate,
                      child: Text(context.tr('retry')),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('saved_places_name'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _name,
              autofocus: true,
              onChanged: (_) {
                if (_nameMissing) setState(() => _nameMissing = false);
              },
              decoration: InputDecoration(
                hintText: context.tr('saved_places_name_hint'),
                errorText: _nameMissing
                    ? context.tr('saved_places_validation_name')
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('saved_places_note'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(controller: _note, maxLines: 2),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: (_lat == null || _locating) ? null : _save,
              child: Text(context.tr('save')),
            ),
          ],
        ),
      ),
    );
  }
}
