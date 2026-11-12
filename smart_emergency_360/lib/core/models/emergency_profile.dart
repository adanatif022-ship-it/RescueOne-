class EmergencyProfile {
  final String fullName;
  final String phone;
  final String emergencyContact;
  final String bloodType;
  final String allergies;
  final String chronicConditions;
  final String medication;
  final String notes;
  final String organizationName;
  final String idNumber;

  const EmergencyProfile({
    this.fullName = '',
    this.phone = '',
    this.emergencyContact = '',
    this.bloodType = '',
    this.allergies = '',
    this.chronicConditions = '',
    this.medication = '',
    this.notes = '',
    this.organizationName = '',
    this.idNumber = '',
  });

  bool get isEmpty =>
      fullName.isEmpty &&
      phone.isEmpty &&
      emergencyContact.isEmpty &&
      bloodType.isEmpty &&
      allergies.isEmpty &&
      chronicConditions.isEmpty &&
      medication.isEmpty &&
      notes.isEmpty &&
      organizationName.isEmpty &&
      idNumber.isEmpty;

  EmergencyProfile copyWith({
    String? fullName,
    String? phone,
    String? emergencyContact,
    String? bloodType,
    String? allergies,
    String? chronicConditions,
    String? medication,
    String? notes,
    String? organizationName,
    String? idNumber,
  }) => EmergencyProfile(
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    bloodType: bloodType ?? this.bloodType,
    allergies: allergies ?? this.allergies,
    chronicConditions: chronicConditions ?? this.chronicConditions,
    medication: medication ?? this.medication,
    notes: notes ?? this.notes,
    organizationName: organizationName ?? this.organizationName,
    idNumber: idNumber ?? this.idNumber,
  );

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'emergencyContact': emergencyContact,
    'bloodType': bloodType,
    'allergies': allergies,
    'chronicConditions': chronicConditions,
    'medication': medication,
    'notes': notes,
    'organizationName': organizationName,
    'idNumber': idNumber,
  };

  factory EmergencyProfile.fromJson(Map<String, dynamic> json) =>
      EmergencyProfile(
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        emergencyContact: json['emergencyContact'] as String? ?? '',
        bloodType: json['bloodType'] as String? ?? '',
        allergies: json['allergies'] as String? ?? '',
        chronicConditions: json['chronicConditions'] as String? ?? '',
        medication: json['medication'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        organizationName: json['organizationName'] as String? ?? '',
        idNumber: json['idNumber'] as String? ?? '',
      );
}
