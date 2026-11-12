import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/language/app_language.dart';
import '../../core/models/trusted_contact.dart';
import '../../core/services/contact_picker.dart';
import '../../core/services/contacts_repository.dart';
import '../../core/services/launcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/ltr_text.dart';
import '../../core/widgets/section_title.dart';

class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({super.key});

  Future<void> _openEditor(
    BuildContext context, {
    TrustedContact? existing,
    PickedContact? picked,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ContactEditorSheet(existing: existing, picked: picked),
    );
  }

  /// Opens the phone's own contact picker, then the editor pre-filled with
  /// the chosen name and number (relationship/options still to set).
  Future<void> _pickFromPhone(BuildContext context) async {
    final picker = ContactPickerService();
    if (!picker.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.trRead('contacts_from_device_unavailable')),
        ),
      );
      return;
    }
    final picked = await picker.pick();
    if (picked == null || !context.mounted) return;
    await _openEditor(context, picked: picked);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TrustedContact contact,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('contacts_delete_confirm_title')),
        content: Text(context.tr('contacts_delete_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
            ),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ContactsRepository>().deleteContact(contact.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsRepository>().contacts;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('contacts_title'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(context.tr('contacts_add')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DisclaimerBanner(textKey: 'contacts_simulated_notice'),
            const SizedBox(height: 16),
            SectionTitle(
              title: context.tr('contacts_favorites'),
              trailing: TextButton.icon(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.tr('contacts_add')),
              ),
            ),
            if (contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  context.tr('contacts_empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ...contacts.map(
                (contact) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
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
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              contact.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            const SizedBox(width: 6),
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
                                context.tr('contacts_primary'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          // The number keeps left-to-right order even in the
                          // Arabic layout ("+967..." not "967...+").
                          LtrText(contact.phone),
                          if (contact.relationship.isNotEmpty)
                            Flexible(
                              child: Text(
                                ' · ${contact.relationship}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (contact.shareLiveLocation) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.call_rounded,
                              color: AppColors.success,
                            ),
                            onPressed: () async {
                              final ok = await LauncherService().callNumber(
                                contact.phone,
                              );
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.trRead(
                                        'contacts_call_unsupported',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.sms_outlined,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () async {
                              final ok = await LauncherService().composeSms(
                                contact.phone,
                              );
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.trRead(
                                        'contacts_message_unsupported',
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'edit':
                                  await _openEditor(context, existing: contact);
                                  break;
                                case 'primary':
                                  await context
                                      .read<ContactsRepository>()
                                      .setPrimary(contact.id);
                                  break;
                                case 'delete':
                                  await _confirmDelete(context, contact);
                                  break;
                              }
                            },
                            // itemBuilder runs synchronously inside this
                            // button's own tap handler (showButtonMenu), not
                            // during a route build phase - a listening
                            // context.tr there throws a Provider assertion.
                            itemBuilder: (menuContext) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(menuContext.trRead('edit')),
                              ),
                              if (!contact.isPrimary)
                                PopupMenuItem(
                                  value: 'primary',
                                  child: Text(
                                    menuContext.trRead('contacts_set_primary'),
                                  ),
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
                ),
              ),
            const SizedBox(height: 12),
            SectionTitle(title: context.tr('contacts_add_new_section')),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.contacts_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    title: Text(context.tr('contacts_from_device')),
                    subtitle: Text(context.tr('contacts_from_device_hint')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _pickFromPhone(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.dialpad_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    title: Text(context.tr('contacts_enter_number')),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _openEditor(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactEditorSheet extends StatefulWidget {
  final TrustedContact? existing;
  final PickedContact? picked;
  const _ContactEditorSheet({this.existing, this.picked});

  @override
  State<_ContactEditorSheet> createState() => _ContactEditorSheetState();
}

class _ContactEditorSheetState extends State<_ContactEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _relationship;
  late bool _notify;
  late bool _isPrimary;
  late bool _shareLiveLocation;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? widget.picked?.name ?? '');
    _phone = TextEditingController(
      text: e?.phone ?? widget.picked?.phone ?? '',
    );
    _relationship = TextEditingController(text: e?.relationship ?? '');
    _notify = e?.notifyDuringSos ?? true;
    _isPrimary = e?.isPrimary ?? false;
    // New contacts get the location link in SOS messages by default -
    // it's the most useful thing to send in an emergency.
    _shareLiveLocation = e?.shareLiveLocation ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relationship.dispose();
    super.dispose();
  }

  bool _nameError = false;
  bool _phoneError = false;

  static bool _validPhone(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '').length >= 6;

  Future<void> _submit() async {
    setState(() {
      _nameError = _name.text.trim().isEmpty;
      _phoneError = !_validPhone(_phone.text);
    });
    if (_nameError || _phoneError) return;
    final repo = context.read<ContactsRepository>();
    if (widget.existing != null) {
      await repo.updateContact(
        widget.existing!.copyWith(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          relationship: _relationship.text.trim(),
          notifyDuringSos: _notify,
          isPrimary: _isPrimary,
          shareLiveLocation: _shareLiveLocation,
        ),
      );
    } else {
      await repo.addContact(
        TrustedContact(
          id: const Uuid().v4().substring(0, 8),
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          relationship: _relationship.text.trim(),
          notifyDuringSos: _notify,
          isPrimary: _isPrimary,
          shareLiveLocation: _shareLiveLocation,
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
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
              context.tr(
                widget.existing != null ? 'contacts_edit' : 'contacts_add',
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('contacts_name'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                errorText: _nameError
                    ? context.tr('contacts_validation_name')
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('contacts_phone'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                errorText: _phoneError
                    ? context.tr('contacts_validation_phone')
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr('contacts_relationship'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _relationship,
              decoration: InputDecoration(
                hintText: context.tr('contacts_relationship_hint'),
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('contacts_notify_during_sos')),
              value: _notify,
              onChanged: (v) => setState(() => _notify = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('contacts_share_live_location')),
              subtitle: Text(
                context.tr('contacts_share_live_location_hint'),
                style: const TextStyle(fontSize: 11.5),
              ),
              value: _shareLiveLocation,
              onChanged: (v) => setState(() => _shareLiveLocation = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.tr('contacts_set_primary')),
              value: _isPrimary,
              onChanged: (v) => setState(() => _isPrimary = v),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _submit, child: Text(context.tr('save'))),
          ],
        ),
      ),
    );
  }
}
