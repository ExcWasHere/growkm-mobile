import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/services/region_service.dart';
import '../theme/profile_colors.dart';
import '../models/profile_models.dart';
import '../profile_repo.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/legal_status.dart';

enum _LoadState { loading, loaded, error }

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repository = ProfileRepository.instance;
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productionLocationController = TextEditingController();
  final _employeeCountController = TextEditingController();
  final _monthlyRevenueController = TextEditingController();

  _LoadState _loadState = _LoadState.loading;
  String? _loadError;
  ProfileOverview? _overview;

  String? _selectedBusinessType;
  String _originalProvince = '';
  String _originalCity = '';
  String _originalDistrict = '';

  List<RegionOption> _provinces = [];
  List<RegionOption> _regencies = [];
  List<RegionOption> _districts = [];
  RegionOption? _selectedProvince;
  RegionOption? _selectedRegency;
  RegionOption? _selectedDistrict;
  bool _loadingRegions = true;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _productionLocationController.dispose();
    _employeeCountController.dispose();
    _monthlyRevenueController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _loadState = _LoadState.loading);
    try {
      final overview = await _repository.fetchProfile();
      final b = overview.business;

      _businessNameController.text = b.businessName;
      _descriptionController.text = b.description;
      _productionLocationController.text = b.productionLocation;
      _employeeCountController.text = '${b.employeeCount}';
      _monthlyRevenueController.text = b.monthlyRevenueEstimate?.toString() ?? '';
      _selectedBusinessType = businessTypeOptions.contains(b.businessType) ? b.businessType : null;
      _originalProvince = b.province;
      _originalCity = b.city;
      _originalDistrict = b.district;

      if (!mounted) return;
      setState(() {
        _overview = overview;
        _loadState = _LoadState.loaded;
      });

      await _loadProvincesAndPrefill();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat profil';
        _loadState = _LoadState.error;
      });
    }
  }

  bool _sameName(String a, String b) => a.trim().toLowerCase() == b.trim().toLowerCase();

  Future<void> _loadProvincesAndPrefill() async {
    final provinces = await RegionService.instance.getProvinces();
    if (!mounted) return;
    setState(() {
      _provinces = provinces;
      _loadingRegions = false;
    });

    RegionOption? matchedProvince;
    for (final p in provinces) {
      if (_sameName(p.name, _originalProvince)) {
        matchedProvince = p;
        break;
      }
    }
    if (matchedProvince == null) return;
    setState(() => _selectedProvince = matchedProvince);

    final regencies = await RegionService.instance.getRegencies(matchedProvince.id);
    if (!mounted) return;
    setState(() => _regencies = regencies);

    RegionOption? matchedRegency;
    for (final r in regencies) {
      if (_sameName(r.name, _originalCity)) {
        matchedRegency = r;
        break;
      }
    }
    if (matchedRegency == null) return;
    setState(() => _selectedRegency = matchedRegency);

    if (_originalDistrict.trim().isEmpty) return;
    final districts = await RegionService.instance.getDistricts(matchedRegency.id);
    if (!mounted) return;
    setState(() => _districts = districts);

    for (final d in districts) {
      if (_sameName(d.name, _originalDistrict)) {
        if (mounted) setState(() => _selectedDistrict = d);
        break;
      }
    }
  }

  Future<void> _onProvinceChanged(RegionOption province) async {
    setState(() {
      _selectedProvince = province;
      _selectedRegency = null;
      _selectedDistrict = null;
      _regencies = [];
      _districts = [];
    });
    final regencies = await RegionService.instance.getRegencies(province.id);
    if (mounted) setState(() => _regencies = regencies);
  }

  Future<void> _onRegencyChanged(RegionOption regency) async {
    setState(() {
      _selectedRegency = regency;
      _selectedDistrict = null;
      _districts = [];
    });
    final districts = await RegionService.instance.getDistricts(regency.id);
    if (mounted) setState(() => _districts = districts);
  }

  void _showError(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.bottomSlide,
      title: 'Gagal',
      desc: message,
      btnOkOnPress: () {},
      btnOkColor: AppColors.primaryDark,
    ).show();
  }

  void _showSuccess() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: 'Tersimpan',
      desc: 'Profil usahamu berhasil diperbarui',
      btnOkOnPress: () {},
      btnOkColor: AppColors.primaryDark,
    ).show();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBusinessType == null) {
      _showError('Kategori usaha wajib dipilih');
      return;
    }
    final province = _selectedProvince?.name ?? _originalProvince;
    final city = _selectedRegency?.name ?? _originalCity;
    if (province.trim().isEmpty || city.trim().isEmpty) {
      _showError('Provinsi dan kota wajib dipilih');
      return;
    }

    final business = _overview!.business;
    setState(() => _saving = true);
    try {
      await _repository.saveBusinessProfile(UpsertBusinessProfileInput(
        businessName: _businessNameController.text.trim(),
        businessType: _selectedBusinessType!,
        kbliCode: business.kbliCode,
        description: _descriptionController.text.trim(),
        province: province,
        city: city,
        district: _selectedDistrict?.name ?? (_originalDistrict.isNotEmpty ? _originalDistrict : null),
        productionLocation: _productionLocationController.text.trim(),
        employeeCount: int.tryParse(_employeeCountController.text.trim()) ?? 1,
        monthlyRevenueEstimate: _monthlyRevenueController.text.trim().isEmpty
            ? null
            : int.tryParse(_monthlyRevenueController.text.trim()),
        hasNib: business.hasNib,
        hasPirt: business.hasPirt,
        hasHalal: business.hasHalal,
        hasBpom: business.hasBpom,
        hasMerek: business.hasMerek,
        onboardingCompleted: true,
      ));
      if (!mounted) return;
      _showSuccess();
      _init();
    } catch (e) {
      if (!mounted) return;
      _showError('Gagal menyimpan profil, coba lagi ya');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Profil Usaha', style: TextStyle(color: ProfileColors.gray800, fontWeight: FontWeight.w800, fontSize: 16)),
          iconTheme: const IconThemeData(color: ProfileColors.gray800),
        ),
        body: SafeArea(
          top: false,
          child: switch (_loadState) {
            _LoadState.loading => const Center(child: CircularProgressIndicator()),
            _LoadState.error => _buildErrorState(),
            _LoadState.loaded => _buildContent(),
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(_loadError ?? 'Gagal memuat', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: ProfileColors.gray500)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _init, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        ProfileAvatarHeader(overview: _overview!),
        const SizedBox(height: 14),
        ProfileLegalStatusCard(business: _overview!.business),
        const SizedBox(height: 16),
        _buildEditForm(),
      ],
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ProfileColors.amber200),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.pencil, size: 14, color: ProfileColors.orangeDark),
                SizedBox(width: 8),
                Text('Edit Data Usaha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: ProfileColors.gray800)),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Nama usaha', prefixIcon: Icon(Icons.storefront_outlined)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama usaha wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            AppSelectField<String>(
              label: 'Kategori usaha',
              icon: Icons.category_outlined,
              value: _selectedBusinessType,
              options: businessTypeOptions,
              labelBuilder: (v) => businessTypeLabels[v]!,
              searchable: false,
              onSelected: (v) => setState(() => _selectedBusinessType = v),
              validator: (v) => v == null ? 'Kategori usaha wajib dipilih' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Deskripsi usaha',
                hintText: 'Ceritakan usahamu, produk yang dijual, dan target pasarnya',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Deskripsi usaha wajib diisi';
                if (v.trim().length < 10) return 'Minimal 10 karakter biar AI bisa nganalisa';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_loadingRegions)
              const Center(child: CircularProgressIndicator())
            else ...[
              AppSelectField<RegionOption>(
                label: 'Provinsi',
                icon: Icons.map_outlined,
                value: _selectedProvince,
                options: _provinces,
                labelBuilder: (r) => r.name,
                onSelected: _onProvinceChanged,
                validator: (v) => (v == null && _originalProvince.isEmpty) ? 'Provinsi wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              AppSelectField<RegionOption>(
                label: 'Kota / Kabupaten',
                icon: Icons.location_city_outlined,
                value: _selectedRegency,
                options: _regencies,
                labelBuilder: (r) => r.name,
                enabled: _selectedProvince != null,
                onSelected: _onRegencyChanged,
                validator: (v) => (v == null && _originalCity.isEmpty) ? 'Kota wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              AppSelectField<RegionOption>(
                label: 'Kecamatan (opsional)',
                icon: Icons.pin_drop_outlined,
                value: _selectedDistrict,
                options: _districts,
                labelBuilder: (r) => r.name,
                enabled: _selectedRegency != null,
                onSelected: (v) => setState(() => _selectedDistrict = v),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _productionLocationController,
              decoration: const InputDecoration(labelText: 'Lokasi produksi (opsional)', prefixIcon: Icon(Icons.factory_outlined)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _employeeCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah karyawan', prefixIcon: Icon(Icons.groups_outlined)),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n < 1) ? 'Minimal 1 karyawan' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _monthlyRevenueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estimasi omzet bulanan (opsional)', prefixIcon: Icon(Icons.payments_outlined)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}