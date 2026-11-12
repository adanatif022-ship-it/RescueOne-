import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language/app_language.dart';
import '../../core/models/emergency_profile.dart';
import '../../core/services/profile_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/disclaimer_banner.dart';
import '../../core/widgets/responsive_section.dart';

class EmergencyProfileScreen extends StatefulWidget {
  const EmergencyProfileScreen({super.key});

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _phone;
  late final TextEditingController _emergencyContact;
  late final TextEditingController _bloodType;
  late final TextEditingController _allergies;
  late final TextEditingController _chronicConditions;
  late final TextEditingController _medication;
  late final TextEditingController _notes;
  late final TextEditingController _orgName;
  late final TextEditingController _idNumber;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileRepository>().profile;
    _fullName = TextEditingController(text: profile.fullName);
    _phone = TextEditingController(text: profile.phone);
    _emergencyContact = TextEditingController(text: profile.emergencyContact);
    _bloodType = TextEditingController(text: profile.bloodType);
    _allergies = TextEditingController(text: profile.allergies);
    _chronicConditions = TextEditingController(text: profile.chronicConditions);
    _medication = TextEditingController(text: profile.medication);
    _notes = TextEditingController(text: profile.notes);
    _orgName = TextEditingController(text: profile.organizationName);
    _idNumber = TextEditingController(text: profile.idNumber);
  }

  @override
  void dispose() {
    for (final c in [
      _fullName,
      _phone,
      _emergencyContact,
      _bloodType,
      _allergies,
      _chronicConditions,
      _medication,
      _notes,
      _orgName,
      _idNumber,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = EmergencyProfile(
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim(),
      emergencyContact: _emergencyContact.text.trim(),
      bloodType: _bloodType.text.trim(),
      allergies: _allergies.text.trim(),
      chronicConditions: _chronicConditions.text.trim(),
      medication: _medication.text.trim(),
      notes: _notes.text.trim(),
      organizationName: _orgName.text.trim(),
      idNumber: _idNumber.text.trim(),
    );
    await context.read<ProfileRepository>().saveProfile(profile);
    if (!mounted) return;
    // trRead, not tr: this runs after an `await`, outside any build phase.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.trRead('profile_saved'))));
  }

  Widget _field(
    String labelKey,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextDirection? textDirection,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(labelKey),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            textDirection: textDirection,
            decoration: const InputDecoration(),
            validator: validator,
          ),
        ],
      ),
    );
  }

  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  /// Dropdown instead of free text, so responders always read a valid
  /// blood type ('' = not known).
  Widget _bloodTypeField() {
    final current = _bloodType.text.trim();
    final options = [
      '',
      ..._bloodTypes,
      if (current.isNotEmpty && !_bloodTypes.contains(current)) current,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('profile_blood_type'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: current,
            dropdownColor: AppColors.surface,
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: option.isEmpty
                      ? Text(context.tr('profile_blood_unknown'))
                      : Text(option, textDirection: TextDirection.ltr),
                ),
            ],
            onChanged: (value) => _bloodType.text = value ?? '',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Captured during build - validators run outside the build phase (via
    // FormState.validate()), so a listening context.tr there would throw.
    final phoneValidationMsg = context.tr('profile_validation_phone');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('profile_title'))),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ResponsiveSection(
              vertical: 16,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DisclaimerBanner(
                      textKey: 'profile_optional_notice',
                      icon: Icons.privacy_tip_outlined,
                    ),
                    const SizedBox(height: 20),
                    _field('profile_full_name', _fullName),
                    _field(
                      'profile_phone',
                      _phone,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                        return digits.length < 6 ? phoneValidationMsg : null;
                      },
                    ),
                    _field('profile_emergency_contact', _emergencyContact),
                    _bloodTypeField(),
                    _field('profile_allergies', _allergies, maxLines: 2),
                    _field(
                      'profile_chronic_conditions',
                      _chronicConditions,
                      maxLines: 2,
                    ),
                    _field('profile_medication', _medication, maxLines: 2),
                    _field('profile_notes', _notes, maxLines: 3),
                    _field('profile_org_name', _orgName),
                    _field('profile_id_number', _idNumber),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(context.tr('save')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
