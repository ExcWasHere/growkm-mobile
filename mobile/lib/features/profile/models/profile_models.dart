const Map<String, String> businessTypeLabels = {
  'kuliner': 'Kuliner',
  'fashion_craft': 'Fashion & Kerajinan',
  'jasa_personal_care': 'Jasa & Personal Care',
};

const List<String> businessTypeOptions = ['kuliner', 'fashion_craft', 'jasa_personal_care'];

class UserAccountInfo {
  final String id;
  final String email;
  final String name;
  final DateTime? createdAt;

  const UserAccountInfo({required this.id, required this.email, required this.name, this.createdAt});

  factory UserAccountInfo.fromJson(Map<String, dynamic> json) {
    return UserAccountInfo(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}

class BusinessProfileData {
  final String id;
  final String businessName;
  final String businessType;
  final String kbliCode;
  final String description;
  final String province;
  final String city;
  final String district;
  final String productionLocation;
  final int employeeCount;
  final int? monthlyRevenueEstimate;
  final bool hasNib;
  final bool hasPirt;
  final bool hasHalal;
  final bool hasBpom;
  final bool hasMerek;
  final String level;
  final int score;
  final int streakDays;
  final bool onboardingCompleted;

  const BusinessProfileData({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.kbliCode,
    required this.description,
    required this.province,
    required this.city,
    required this.district,
    required this.productionLocation,
    required this.employeeCount,
    required this.hasNib,
    required this.hasPirt,
    required this.hasHalal,
    required this.hasBpom,
    required this.hasMerek,
    required this.level,
    required this.score,
    required this.streakDays,
    required this.onboardingCompleted,
    this.monthlyRevenueEstimate,
  });

  String get businessTypeLabel => businessTypeLabels[businessType] ?? businessType;

  factory BusinessProfileData.fromJson(Map<String, dynamic> json) {
    return BusinessProfileData(
      id: json['id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      businessType: json['business_type'] as String? ?? 'lainnya',
      kbliCode: json['kbli_code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      productionLocation: json['production_location'] as String? ?? '',
      employeeCount: json['employee_count'] as int? ?? 1,
      monthlyRevenueEstimate: json['monthly_revenue_estimate'] as int?,
      hasNib: json['has_nib'] as bool? ?? false,
      hasPirt: json['has_pirt'] as bool? ?? false,
      hasHalal: json['has_halal'] as bool? ?? false,
      hasBpom: json['has_bpom'] as bool? ?? false,
      hasMerek: json['has_merek'] as bool? ?? false,
      level: json['level'] as String? ?? 'starter',
      score: json['score'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 0,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
    );
  }
}

class ProfileOverview {
  final UserAccountInfo user;
  final BusinessProfileData business;

  const ProfileOverview({required this.user, required this.business});

  factory ProfileOverview.fromMeJson(Map<String, dynamic> data) {
    final userJson = data['user'] as Map<String, dynamic>?;
    final bpJson = data['business_profile'] as Map<String, dynamic>?;
    return ProfileOverview(
      user: userJson != null
          ? UserAccountInfo.fromJson(userJson)
          : const UserAccountInfo(id: '', email: '', name: 'Sobat UMKM'),
      business: bpJson != null
          ? BusinessProfileData.fromJson(bpJson)
          : const BusinessProfileData(
              id: '', businessName: '', businessType: 'lainnya', kbliCode: '', description: '',
              province: '', city: '', district: '', productionLocation: '', employeeCount: 1,
              hasNib: false, hasPirt: false, hasHalal: false, hasBpom: false, hasMerek: false,
              level: 'starter', score: 0, streakDays: 0, onboardingCompleted: false,
            ),
    );
  }
}

class UpsertBusinessProfileInput {
  final String businessName;
  final String businessType;
  final String kbliCode;
  final String description;
  final String province;
  final String city;
  final String? district;
  final String productionLocation;
  final int employeeCount;
  final int? monthlyRevenueEstimate;
  final bool hasNib;
  final bool hasPirt;
  final bool hasHalal;
  final bool hasBpom;
  final bool hasMerek;
  final bool onboardingCompleted;

  const UpsertBusinessProfileInput({
    required this.businessName,
    required this.businessType,
    required this.kbliCode,
    required this.description,
    required this.province,
    required this.city,
    required this.productionLocation,
    required this.employeeCount,
    required this.hasNib,
    required this.hasPirt,
    required this.hasHalal,
    required this.hasBpom,
    required this.hasMerek,
    required this.onboardingCompleted,
    this.district,
    this.monthlyRevenueEstimate,
  });

  Map<String, dynamic> toJson() => {
        'business_name': businessName,
        'business_type': businessType,
        'kbli_code': kbliCode,
        'description': description,
        'province': province,
        'city': city,
        if (district != null) 'district': district,
        'production_location': productionLocation,
        'employee_count': employeeCount,
        if (monthlyRevenueEstimate != null) 'monthly_revenue_estimate': monthlyRevenueEstimate,
        'has_nib': hasNib,
        'has_pirt': hasPirt,
        'has_halal': hasHalal,
        'has_bpom': hasBpom,
        'has_merek': hasMerek,
        'onboarding_completed': onboardingCompleted,
      };
}