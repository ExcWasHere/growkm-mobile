enum MascotPose { sapa, tanya, ide, catat }

extension MascotPoseX on MascotPose {
  String get assetPath => switch (this) {
        MascotPose.sapa => 'assets/images/mascot/sapa.png',
        MascotPose.tanya => 'assets/images/mascot/tanya.png',
        MascotPose.ide => 'assets/images/mascot/ide.png',
        MascotPose.catat => 'assets/images/mascot/catat.png',
      };
}

class OnboardingChoice<T> {
  final String label;
  final String? sublabel;
  final T value;

  const OnboardingChoice({required this.label, required this.value, this.sublabel});
}

const businessTypeChoices = [
  OnboardingChoice(label: 'Kuliner', value: 'kuliner', sublabel: 'Makanan & minuman'),
  OnboardingChoice(label: 'Fashion & Kerajinan', value: 'fashion_craft', sublabel: 'Pakaian, aksesoris, kriya'),
  OnboardingChoice(label: 'Jasa & Personal Care', value: 'jasa_personal_care', sublabel: 'Salon, laundry, jasa lainnya'),
];

const employeeCountChoices = [
  OnboardingChoice(label: 'Cuma aku sendiri', value: 1),
  OnboardingChoice(label: '2-5 orang', value: 3),
  OnboardingChoice(label: '6-10 orang', value: 8),
  OnboardingChoice(label: 'Lebih dari 10 orang', value: 15),
];

const monthlyRevenueChoices = [
  OnboardingChoice(label: 'Di bawah Rp1 juta', value: 500000),
  OnboardingChoice(label: 'Rp1 - 5 juta', value: 3000000),
  OnboardingChoice(label: 'Rp5 - 20 juta', value: 12000000),
  OnboardingChoice(label: 'Rp20 - 50 juta', value: 35000000),
  OnboardingChoice(label: 'Di atas Rp50 juta', value: 75000000),
];