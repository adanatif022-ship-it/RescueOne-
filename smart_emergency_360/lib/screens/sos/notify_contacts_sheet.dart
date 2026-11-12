import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/incident.dart';
import '../../core/models/trusted_contact.dart';
import '../../core/services/contacts_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/incident_ui.dart';
import '../../core/widgets/ltr_text.dart';
import '../contacts/trusted_contacts_screen.dart';

/// The SOS text sent to a trusted contact. The location link is included
/// when the contact has "Share my location" on (default for new contacts).
String buildSosMessage(
  AppLanguage lang,
  Incident incident, {
  required bool includeLocation,
}) {
  final location = incident.location;
  return [
    '🚨 ${lang.tr('sos_sms_intro')}: ${lang.tr(incidentTypeKey(incident.type))}',
    if (includeLocation)
      location != null
          ? '${lang.tr('sos_sms_location')}: '
                '${LauncherService.mapsLink(location.latitude, location.longitude)}'
          : '${lang.tr('sos_sms_location')}: ${lang.tr('sos_sms_no_location')}',
    if (incident.description.isNotEmpty) incident.description,
    '${lang.tr('history_incident_number')}: ${incident.id}',
    lang.tr('sos_sms_footer'),
  ].join('\n');
}

/// Bottom sheet listing the contacts marked "Notify during SOS" (or all
/// contacts if none are marked), each with a one-tap SMS button that opens
/// the phone's SMS app pre-filled. Nothing is sent automatically.
Future<void> showNotifyContactsSheet(BuildContext context, Incident incident) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _NotifyContactsSheet(incident: incident),
  );
}

class _NotifyContactsSheet extends StatefulWidget {
  final Incident incident;
  const _NotifyContactsSheet({required this.incident});

  @override
  State<_NotifyContactsSheet> createState() => _NotifyContactsSheetState();
}

class _NotifyContactsSheetState extends State<_NotifyContactsSheet> {
  final _sent = <String>{};

  Future<void> _send(TrustedContact contact) async {
    final lang = context.read<AppLanguage>();
    final body = buildSosMessage(
      lang,
      widget.incident,
      includeLocation: contact.shareLiveLocation,
    );
    final ok = await LauncherService().composeSms(contact.phone, body: body);
    if (!mounted) return;
    if (ok) {
      setState(() => _sent.add(contact.id));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.trRead('sos_sms_failed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ContactsRepository>();
    final marked = repo.notifiedContacts;
    final contacts = marked.isNotEmpty ? marked : repo.contacts;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('sos_notify_contacts'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('sos_notify_contacts_hint'),
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            if (contacts.isEmpty) ...[
              Text(
                context.tr('sos_no_contacts'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TrustedContactsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(context.tr('sos_add_contacts')),
              ),
            ] else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final sent = _sent.contains(contact.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryBlue.withValues(
                          alpha: 0.12,
                        ),
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name.characters.first.toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: LtrText(
                          contact.phone,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      trailing: FilledButton.icon(
                        onPressed: () => _send(contact),
                        style: FilledButton.styleFrom(
                          backgroundColor: sent
                              ? AppColors.success
                              : AppColors.primaryBlue,
                          minimumSize: const Size(0, 40),
                        ),
                        icon: Icon(
                          sent ? Icons.check_rounded : Icons.sms_rounded,
                          size: 18,
                        ),
                        label: Text(context.tr('sos_send_sms')),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
