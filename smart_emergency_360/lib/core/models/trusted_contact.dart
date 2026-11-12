class TrustedContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;
  final bool notifyDuringSos;
  final bool shareLiveLocation;

  const TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.isPrimary = false,
    this.notifyDuringSos = true,
    this.shareLiveLocation = false,
  });

  TrustedContact copyWith({
    String? name,
    String? phone,
    String? relationship,
    bool? isPrimary,
    bool? notifyDuringSos,
    bool? shareLiveLocation,
  }) => TrustedContact(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    relationship: relationship ?? this.relationship,
    isPrimary: isPrimary ?? this.isPrimary,
    notifyDuringSos: notifyDuringSos ?? this.notifyDuringSos,
    shareLiveLocation: shareLiveLocation ?? this.shareLiveLocation,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'relationship': relationship,
    'isPrimary': isPrimary,
    'notifyDuringSos': notifyDuringSos,
    'shareLiveLocation': shareLiveLocation,
  };

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    relationship: json['relationship'] as String? ?? '',
    isPrimary: json['isPrimary'] as bool? ?? false,
    notifyDuringSos: json['notifyDuringSos'] as bool? ?? true,
    shareLiveLocation: json['shareLiveLocation'] as bool? ?? false,
  );
}
