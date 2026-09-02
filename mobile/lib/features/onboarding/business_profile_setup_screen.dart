import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/services/region_service.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_select_field.dart';
import '../auth/pin_setup_screen.dart';
import 'models/onboard_models.dart';
import 'theme/onboard_colors.dart';
import 'widgets/onboard_card.dart';
import 'widgets/onboard_step.dart';

class BusinessProfileSetupScreen extends StatefulWidget {
  static const routeName = '/business-profile-setup';
  const BusinessProfileSetupScreen({super.key});

  @override
  State<BusinessProfileSetupScreen> createState() => _BusinessProfileSetupScreenState();
}

class _BusinessProfileSetupScreenState extends State<BusinessProfileSetupScreen> {
  static const _totalSteps = 11;

  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productionLocationController = TextEditingController();

  int _currentStep = 0;
  String? _selectedBusinessType;
  int? _selectedEmployeeCount;
  int? _selectedMonthlyRevenue;
  bool _revenueSkipped = false;

  List<RegionOption> _provinces = [];
  List<RegionOption> _regencies = [];
  List<RegionOption> _districts = [];
  RegionOption? _selectedProvince;
  RegionOption? _selectedRegency;
  RegionOption? _selectedDistrict;
  bool _loadingProvinces = true;
  bool _loadingRegencies = false;
  bool _loadingDistricts = false;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _productionLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    final provinces = await RegionService.instance.getProvinces();
    if (mounted) setState(() { _provinces = provinces; _loadingProvinces = false; });
  }

  Future<void> _onProvinceSelected(RegionOption province) async {
    setState(() {
      _selectedProvince = province;
      _selectedRegency = null;
      _selectedDistrict = null;
      _regencies = [];
      _districts = [];
      _loadingRegencies = true;
    });
    final regencies = await RegionService.instance.getRegencies(province.id);
    if (mounted) setState(() { _regencies = regencies; _loadingRegencies = false; });
  }

  Future<void> _onRegencySelected(RegionOption regency) async {
    setState(() {
      _selectedRegency = regency;
      _selectedDistrict = null;
      _districts = [];
      _loadingDistricts = true;
    });
    final districts = await RegionService.instance.getDistricts(regency.id);
    if (mounted) setState(() { _districts = districts; _loadingDistricts = false; });
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Gagal',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: OnboardingColors.orangeDark,
    ).show();
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return _businessNameController.text.trim().isNotEmpty;
      case 2:
        return _selectedBusinessType != null;
      case 3:
        return _descriptionController.text.trim().length >= 10;
      case 4:
        return _selectedProvince != null;
      case 5:
        return _selectedRegency != null;
      case 6:
        return true;
      case 7:
        return true;
      case 8:
        return _selectedEmployeeCount != null;
      case 9:
        return _selectedMonthlyRevenue != null || _revenueSkipped;
      case 10:
        return true;
      default:
        return false;
    }
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _currentStep--);
  }

  void _goNext() {
    if (_currentStep == _totalSteps - 1) {
      _submit();
      return;
    }
    setState(() => _currentStep++);
  }

  void _skipStep({int? employeeCount, int? monthlyRevenue}) {
    setState(() {
      if (_currentStep == 9) _revenueSkipped = true;
    });
    _goNext();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiClient.instance.post('/api/users/business-profile', {
        'business_name': _businessNameController.text.trim(),
        'business_type': _selectedBusinessType,
        'kbli_code': '',
        'description': _descriptionController.text.trim(),
        'province': _selectedProvince!.name,
        'city': _selectedRegency!.name,
        'district': _selectedDistrict?.name,
        'production_location': _productionLocationController.text.trim(),
        'employee_count': _selectedEmployeeCount ?? 1,
        'monthly_revenue_estimate': _revenueSkipped ? null : _selectedMonthlyRevenue,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showError('Gagal simpan profil usaha, coba lagi ya (${response.statusCode})');
        return;
      }

      await AuthStorageService.instance.setProfileComplete(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PinSetupScreen.routeName);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError('Koneksi bermasalah, coba lagi ya');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(child: _buildStep()),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _stepScaffold(
          mascot: MascotPose.sapa,
          question: 'Hai! Aku Lexa yang akan bantu kamu lengkapin profil usaha, cuma butuh beberapa menit kok!',
          content: const SizedBox.shrink(),
          continueLabel: 'Yuk!',
          centerMascot: true,
        );
      case 1:
        return _stepScaffold(
          mascot: MascotPose.tanya,
          question: 'Apa nama usahamu?',
          content: TextField(
            controller: _businessNameController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Contoh: Dikichi', prefixIcon: Icon(Icons.storefront_outlined)),
          ),
        );
      case 2:
        return _stepScaffold(
          mascot: MascotPose.tanya,
          question: 'Usaha kamu bergerak di bidang apa?',
          content: Column(
            children: businessTypeChoices
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OnboardingChoiceCard(
                        label: c.label,
                        sublabel: c.sublabel,
                        selected: _selectedBusinessType == c.value,
                        onTap: () => setState(() => _selectedBusinessType = c.value),
                      ),
                    ))
                .toList(),
          ),
        );
      case 3:
        return _stepScaffold(
          mascot: MascotPose.ide,
          question: 'Ceritain usahamu dong! Produk apa yang dijual dan siapa target pasarnya?',
          content: TextField(
            controller: _descriptionController,
            autofocus: true,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Minimal 10 karakter biar Lexa bisa analisa usahamu',
              alignLabelWithHint: true,
            ),
          ),
        );
      case 4:
        return _stepScaffold(
          mascot: MascotPose.catat,
          question: 'Usahamu berlokasi di provinsi mana?',
          content: _loadingProvinces
              ? const Center(child: CircularProgressIndicator())
              : AppSelectField<RegionOption>(
                  label: 'Provinsi',
                  icon: Icons.map_outlined,
                  value: _selectedProvince,
                  options: _provinces,
                  labelBuilder: (r) => r.name,
                  onSelected: _onProvinceSelected,
                ),
        );
      case 5:
        return _stepScaffold(
          mascot: MascotPose.catat,
          question: 'Kalau kota atau kabupatennya?',
          content: _loadingRegencies
              ? const Center(child: CircularProgressIndicator())
              : AppSelectField<RegionOption>(
                  label: 'Kota / Kabupaten',
                  icon: Icons.location_city_outlined,
                  value: _selectedRegency,
                  options: _regencies,
                  labelBuilder: (r) => r.name,
                  onSelected: _onRegencySelected,
                ),
        );
      case 6:
        return _stepScaffold(
          mascot: MascotPose.catat,
          question: 'Kecamatannya apa? Boleh diisi nanti di menu profile kok',
          content: _loadingDistricts
              ? const Center(child: CircularProgressIndicator())
              : AppSelectField<RegionOption>(
                  label: 'Kecamatan (opsional)',
                  icon: Icons.pin_drop_outlined,
                  value: _selectedDistrict,
                  options: _districts,
                  labelBuilder: (r) => r.name,
                  onSelected: (v) => setState(() => _selectedDistrict = v),
                ),
          onSkip: () => _goNext(),
        );
      case 7:
        return _stepScaffold(
          mascot: MascotPose.tanya,
          question: 'Di mana biasanya kamu produksi atau operasional?',
          content: TextField(
            controller: _productionLocationController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Contoh: Rumah / Ruko', prefixIcon: Icon(Icons.factory_outlined)),
          ),
          onSkip: () => _goNext(),
        );
      case 8:
        return _stepScaffold(
          mascot: MascotPose.tanya,
          question: 'Berapa karyawan yang kamu punya?',
          content: Column(
            children: employeeCountChoices
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OnboardingChoiceCard(
                        label: c.label,
                        selected: _selectedEmployeeCount == c.value,
                        onTap: () => setState(() => _selectedEmployeeCount = c.value),
                      ),
                    ))
                .toList(),
          ),
        );
      case 9:
        return _stepScaffold(
          mascot: MascotPose.ide,
          question: 'Kira-kira berapa omzet usahamu per bulan?',
          content: Column(
            children: monthlyRevenueChoices
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OnboardingChoiceCard(
                        label: c.label,
                        selected: !_revenueSkipped && _selectedMonthlyRevenue == c.value,
                        onTap: () => setState(() {
                          _selectedMonthlyRevenue = c.value;
                          _revenueSkipped = false;
                        }),
                      ),
                    ))
                .toList(),
          ),
          onSkip: () => _skipStep(),
        );
      case 10:
        return _stepScaffold(
          mascot: MascotPose.sapa,
          question: 'Mantap! Semua udah keisi, yuk simpan profil usahamu.',
          content: _buildRecap(),
          continueLabel: 'Selesai',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _stepScaffold({
    required MascotPose mascot,
    required String question,
    required Widget content,
    String continueLabel = 'Lanjutkan',
    VoidCallback? onSkip,
    bool centerMascot = false,
  }) {
    return OnboardingStepScaffold(
      currentStep: _currentStep,
      totalSteps: _totalSteps,
      mascot: mascot,
      question: question,
      content: content,
      canContinue: _canContinue,
      submitting: _isSubmitting,
      continueLabel: continueLabel,
      onBack: _goBack,
      onContinue: _goNext,
      onSkip: onSkip,
      centerMascot: centerMascot,
    );
  }

  Widget _buildRecap() {
    final rows = <(String, String)>[
      ('Nama usaha', _businessNameController.text.trim()),
      ('Kategori', businessTypeChoices.firstWhere((c) => c.value == _selectedBusinessType, orElse: () => businessTypeChoices.first).label),
      ('Lokasi', '${_selectedRegency?.name ?? '-'}, ${_selectedProvince?.name ?? '-'}'),
      ('Karyawan', employeeCountChoices.firstWhere((c) => c.value == _selectedEmployeeCount, orElse: () => employeeCountChoices.first).label),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingColors.amber200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1, style: const TextStyle(fontSize: 11, color: OnboardingColors.gray500)),
                      Text(r.$2, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: OnboardingColors.gray800)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}