import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_storage_service.dart';
import '../../core/services/api_client.dart';
import '../../core/services/product_tour_service.dart';
import '../../core/services/product_tour_step.dart';
import '../../core/services/region_service.dart';
import '../../core/widgets/app_background.dart';
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

  static const _businessTypes = ['kuliner', 'fashion', 'kerajinan', 'jasa'];
  static const _businessTypeLabels = {
    'kuliner': 'Kuliner',
    'fashion': 'Fashion',
    'kerajinan': 'Kerajinan',
    'jasa': 'Jasa',
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
            description: 'Semakin lengkap dan jelas deskripsi usahamu, semakin akurat rekomendasi KBLI dari AI kami.',
            icon: Icons.edit_note_outlined,
            targetKey: _formFieldsKey,
          ),
        ],
      );
    });
  }

  Future<void> _loadProvinces() async {
    final provinces = await RegionService.instance.getProvinces();
    if (mounted) setState(() {
      _provinces = provinces;
      _loadingRegions = false;
    });
  }

  Future<void> _onProvinceChanged(RegionOption? province) async {
    setState(() {
      _selectedProvince = province;
      _selectedRegency = null;
      _selectedDistrict = null;
      _regencies = [];
      _districts = [];
    });
    if (province == null) return;
    final regencies = await RegionService.instance.getRegencies(province.id);
    if (mounted) setState(() => _regencies = regencies);
  }

  Future<void> _onRegencyChanged(RegionOption? regency) async {
    setState(() {
      _selectedRegency = regency;
      _selectedDistrict = null;
      _districts = [];
    });
    if (regency == null) return;
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBusinessType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori usaha wajib dipilih')),
      );
      return;
    }
    if (_selectedProvince == null || _selectedRegency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provinsi dan kota wajib dipilih')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.post('/api/users/business-profile', {
        'businessName': _businessNameController.text.trim(),
        'businessType': _selectedBusinessType,
        'description': _descriptionController.text.trim(),
        'province': _selectedProvince!.name,
        'city': _selectedRegency!.name,
        'district': _selectedDistrict?.name,
        'productionLocation': _productionLocationController.text.trim(),
        'employeeCount': int.tryParse(_employeeCountController.text.trim()) ?? 1,
        'monthlyRevenueEstimate': _monthlyRevenueController.text.trim().isEmpty
            ? null
            : int.tryParse(_monthlyRevenueController.text.trim()),
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal simpan profil usaha, coba lagi ya')),
        );
        return;
      }

      await AuthStorageService.instance.setProfileComplete(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PinSetupScreen.routeName);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
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
                      DropdownButtonFormField<String>(
                        value: _selectedBusinessType,
                        decoration: const InputDecoration(
                          labelText: 'Kategori usaha',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _businessTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_businessTypeLabels[type]!),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedBusinessType = value),
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Deskripsi usaha wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      if (_loadingRegions)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        DropdownButtonFormField<RegionOption>(
                          value: _selectedProvince,
                          decoration: const InputDecoration(
                            labelText: 'Provinsi',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          items: _provinces
                              .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                              .toList(),
                          onChanged: _onProvinceChanged,
                          validator: (v) => v == null ? 'Provinsi wajib dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<RegionOption>(
                          value: _selectedRegency,
                          decoration: const InputDecoration(
                            labelText: 'Kota / Kabupaten',
                            prefixIcon: Icon(Icons.location_city_outlined),
                          ),
                          items: _regencies
                              .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                              .toList(),
                          onChanged: _selectedProvince == null ? null : _onRegencyChanged,
                          validator: (v) => v == null ? 'Kota wajib dipilih' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<RegionOption>(
                          value: _selectedDistrict,
                          decoration: const InputDecoration(
                            labelText: 'Kecamatan (opsional)',
                            prefixIcon: Icon(Icons.pin_drop_outlined),
                          ),
                          items: _districts
                              .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                              .toList(),
                          onChanged: _selectedRegency == null
                              ? null
                              : (v) => setState(() => _selectedDistrict = v),
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
    );
  }
}