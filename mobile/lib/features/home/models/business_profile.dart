enum BusinessLevel { starter, berkembang, mapan }

class LevelConfig {
  final String label;
  const LevelConfig(this.label);
}

const Map<BusinessLevel, LevelConfig> kLevelConfig = {
  BusinessLevel.starter: LevelConfig('Starter'),
  BusinessLevel.berkembang: LevelConfig('Berkembang'),
  BusinessLevel.mapan: LevelConfig('Mapan'),
};

BusinessLevel _parseLevel(String? value) {
  switch (value) {
    case 'berkembang':
      return BusinessLevel.berkembang;
    case 'mapan':
      return BusinessLevel.mapan;
    default:
      return BusinessLevel.starter;
  }
}

class UserProfile {
  final String name;
  final String email;

  const UserProfile({required this.name, required this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'Sobat UMKM',
      email: (json['email'] as String?) ?? '',
    );
  }
}

class BusinessProfile {
  final String businessName;
  final String businessType;
  final String city;
  final BusinessLevel level;
  final int streakDays;
  final bool hasNib;
  final bool hasPirt;
  final bool hasHalal;
  final bool hasBpom;
  final bool hasMerek;

  const BusinessProfile({
    required this.businessName,
    required this.businessType,
    required this.city,
    this.level = BusinessLevel.starter,
    this.streakDays = 0,
    this.hasNib = false,
    this.hasPirt = false,
    this.hasHalal = false,
    this.hasBpom = false,
    this.hasMerek = false,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      businessName: (json['business_name'] as String?) ?? 'Usahaku',
      businessType: (json['business_type'] as String?) ?? '-',
      city: (json['city'] as String?) ?? '-',
      level: _parseLevel(json['level'] as String?),
      streakDays: (json['streak_days'] as num?)?.toInt() ?? 0,
      hasNib: (json['has_nib'] as bool?) ?? false,
      hasPirt: (json['has_pirt'] as bool?) ?? false,
      hasHalal: (json['has_halal'] as bool?) ?? false,
      hasBpom: (json['has_bpom'] as bool?) ?? false,
      hasMerek: (json['has_merek'] as bool?) ?? false,
    );
  }

  double get formalizationPercent {
    final flags = [hasNib, hasPirt, hasHalal, hasBpom, hasMerek];
    return flags.where((f) => f).length / flags.length;
  }

  String formatBusinessType() {
    // TODO: samain sama util formatBusinessType() di web kalau formatnya beda
    return businessType
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class GreetingData {
  final bool hasGreeting;
  final String? type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final String? actionUrl;

  const GreetingData({
    required this.hasGreeting,
    this.type,
    this.title,
    this.message,
    this.actionLabel,
    this.actionUrl,
  });

  factory GreetingData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GreetingData(hasGreeting: false);
    return GreetingData(
      hasGreeting: (json['has_greeting'] as bool?) ?? false,
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      actionLabel: json['action_label'] as String?,
      actionUrl: json['action_url'] as String?,
    );
  }
}

class BadgeData {
  final String icon;
  final String name;
  final bool earned;
  const BadgeData({required this.icon, required this.name, required this.earned});
}

List<BadgeData> getBadges(BusinessProfile p) {
  // TODO: samain logic-nya sama getBadges() di web (constants.ts) biar konsisten
  return [
    BadgeData(icon: '📋', name: 'Punya NIB', earned: p.hasNib),
    BadgeData(icon: '🍱', name: 'Punya PIRT', earned: p.hasPirt),
    BadgeData(icon: '☪️', name: 'Sertifikat Halal', earned: p.hasHalal),
    BadgeData(icon: '💊', name: 'Izin Edar BPOM', earned: p.hasBpom),
    BadgeData(icon: '™️', name: 'Merek Terdaftar', earned: p.hasMerek),
    BadgeData(icon: '🚀', name: 'Formalisasi 100%', earned: p.formalizationPercent >= 1.0),
  ];
}