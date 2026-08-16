import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/services/product_tour_service.dart';
import '../../core/services/product_tour_step.dart';
import '../../core/services/region_service.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_select_field.dart';
import '../../core/widgets/product_tour_dialog.dart';
import '../auth/pin_setup_screen.dart';

class BusinessProfileSetupScreen extends StatefulWidget {
  static const routeName = '/business-profile-setup';
  const BusinessProfileSetupScreen({super.key});

  @override
  State<BusinessProfileSetupScreen> createState() => _BusinessProfileSetupScreenState();
}

class _BusinessProfileSetupScreenState extends State<BusinessProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productionLocationController = TextEditingController();
  final _employeeCountController = TextEditingController(text: '1');
  final _monthlyRevenueController = TextEditingController();
  final _formFieldsKey = GlobalKey();
  static const _businessTypes = ['kuliner', 'fashion_craft', 'jasa_personal_care'];
  static const _businessTypeLabels = {
    'kuliner': 'Kuliner',
    'fashion_craft': 'Fashion & Kerajinan',
    'jasa_personal_care': 'Jasa & Personal Care',
  };

  String? _selectedBusinessType;
  bool _isLoading = false;

  List<RegionOption> _provinces = [];
  List<RegionOption> _regencies = [];
  List<RegionOption> _districts = [];
  RegionOption? _selectedProvince;
  RegionOption? _selectedRegency;
  RegionOption? _selectedDistrict;
  bool _loadingRegions = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProductTourDialog.showIfNeeded(
        context,
        tourKey: 'business_profile_setup_tour',
        store: ProductTourService.instance,
        steps: [
          const ProductTourStep(
            title: 'Lengkapi Profil Usaha',
            description: 'Data ini bantu GrowKM nyusun roadmap legalitas yang pas buat usahamu.',
            icon: Icons.storefront_outlined,
          ),
          ProductTourStep(
            title: 'Isi Detail Usaha di Sini',
            description:
                'Semakin lengkap dan jelas deskripsi usahamu, semakin akurat rekomendasi KBLI dari AI kami.',
            icon: Icons.edit_note_outlined,
            targetKey: _formFieldsKey,
          ),
        ],
      );
    });
  }

  Future<void> _loadProvinces() async {
    final provinces = await RegionService.instance.getProvinces();
    if (mounted) {
      setState(() {
        _provinces = provinces;
        _loadingRegions = false;
      });
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

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _productionLocationController.dispose();
    _employeeCountController.dispose();
    _monthlyRevenueController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBusinessType == null) {
      _showError('Kategori usaha wajib dipilih');
      return;
    }
    if (_selectedProvince == null || _selectedRegency == null) {
      _showError('Provinsi dan kota wajib dipilih');
      return;
    }

    setState(() => _isLoading = true);

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
        'employee_count': int.tryParse(_employeeCountController.text.trim()) ?? 1,
        'monthly_revenue_estimate': _monthlyRevenueController.text.trim().isEmpty
            ? null
            : int.tryParse(_monthlyRevenueController.text.trim()),
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (!mounted) return;
        _showError('Gagal simpan profil usaha, coba lagi ya (${response.statusCode})');
        return;
      }

      await AuthStorageService.instance.setProfileComplete(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PinSetupScreen.routeName);
    } catch (_) {
      if (mounted) _showError('Koneksi bermasalah, coba lagi ya');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lengkapi profil usaha', style: theme.textTheme.displaySmall),
                      const SizedBox(height: 6),
                      Text(
                        'Data ini bantu kami susun roadmap legalitas yang sesuai',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      Column(
                        key: _formFieldsKey,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _businessNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama usaha',
                              prefixIcon: Icon(Icons.storefront_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nama usaha wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AppSelectField<String>(
                            label: 'Kategori usaha',
                            icon: Icons.category_outlined,
                            value: _selectedBusinessType,
                            options: _businessTypes,
                            labelBuilder: (v) => _businessTypeLabels[v]!,
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
                              validator: (v) => v == null ? 'Provinsi wajib dipilih' : null,
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
                              validator: (v) => v == null ? 'Kota wajib dipilih' : null,
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
                            decoration: const InputDecoration(
                              labelText: 'Lokasi produksi (opsional)',
                              prefixIcon: Icon(Icons.factory_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _employeeCountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah karyawan',
                              prefixIcon: Icon(Icons.groups_outlined),
                            ),
                            validator: (v) {
                              final n = int.tryParse(v?.trim() ?? '');
                              return (n == null || n < 1) ? 'Minimal 1 karyawan' : null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _monthlyRevenueController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Estimasi omzet bulanan (opsional)',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Lanjut'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}