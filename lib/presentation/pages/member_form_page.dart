import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:technical_test_superindo/core/theme/app_colors.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';
import 'package:technical_test_superindo/presentation/bloc/member_bloc.dart';
import 'package:technical_test_superindo/presentation/pages/ktp_camera_page.dart';
import 'package:technical_test_superindo/core/service_locator.dart' as di;
import 'package:technical_test_superindo/presentation/bloc/location_bloc.dart';
import 'package:technical_test_superindo/domain/entities/location.dart';

class MemberFormPage extends StatefulWidget {
  final Member? member;
  const MemberFormPage({super.key, this.member});

  @override
  State<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends State<MemberFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final LocationBloc _ktpLocationBloc;
  late final LocationBloc _domisiliLocationBloc;

  @override
  void initState() {
    super.initState();
    _ktpLocationBloc = di.sl<LocationBloc>()..add(GetProvinces());
    _domisiliLocationBloc = di.sl<LocationBloc>()..add(GetProvinces());

    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _nikController.text = widget.member!.nik;
      _phoneController.text = widget.member!.phone;
      _birthPlaceController.text = widget.member!.birthPlace;
      _birthDateController.text = widget.member!.birthDate;
      _selectedGender = widget.member!.gender;
      _selectedStatus = widget.member!.status;
      _occupationController.text = widget.member!.occupation;
      _addressController.text = widget.member!.address;
      _provinsiController.text = widget.member!.provinsi;
      _kotaController.text = widget.member!.kotaKabupaten;
      _kecamatanController.text = widget.member!.kecamatan;
      _kelurahanController.text = widget.member!.kelurahan;
      _kodePosController.text = widget.member!.kodePos;
      
      _addressDomisiliController.text = widget.member!.alamatDomisili;
      _provinsiDomisiliController.text = widget.member!.provinsiDomisili;
      _kotaDomisiliController.text = widget.member!.kotaKabupatenDomisili;
      _kecamatanDomisiliController.text = widget.member!.kecamatanDomisili;
      _kelurahanDomisiliController.text = widget.member!.kelurahanDomisili;
      _kodePosDomisiliController.text = widget.member!.kodePosDomisili;
      
      _ktpPath = widget.member!.ktpPath;
      _ktpSecondaryPath = widget.member!.ktpSecondaryPath;
      _isDomisiliSameAsKtp = widget.member!.address == widget.member!.alamatDomisili && 
                            widget.member!.provinsi == widget.member!.provinsiDomisili;
    }
  }

  @override
  void dispose() {
    _ktpLocationBloc.close();
    _domisiliLocationBloc.close();
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _provinsiController.dispose();
    _kotaController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _kodePosController.dispose();
    _addressDomisiliController.dispose();
    _provinsiDomisiliController.dispose();
    _kotaDomisiliController.dispose();
    _kecamatanDomisiliController.dispose();
    _kelurahanDomisiliController.dispose();
    _kodePosDomisiliController.dispose();
    super.dispose();
  }

  // Controllers
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kotaController = TextEditingController();
  final _kecamatanController = TextEditingController();
  final _kelurahanController = TextEditingController();
  final _kodePosController = TextEditingController();

  final _addressDomisiliController = TextEditingController();
  final _provinsiDomisiliController = TextEditingController();
  final _kotaDomisiliController = TextEditingController();
  final _kecamatanDomisiliController = TextEditingController();
  final _kelurahanDomisiliController = TextEditingController();
  final _kodePosDomisiliController = TextEditingController();

  String _selectedStatus = 'Belum Menikah';
  String _selectedGender = 'Laki-laki';
  bool _isDomisiliSameAsKtp = true;

  String? _ktpPath;
  String? _ktpSecondaryPath;

  Future<void> _pickImage(bool isPrimary) async {
    final String? imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const KtpCameraPage()),
    );

    if (imagePath != null) {
      final compressedFile = await _compressImage(File(imagePath));
      setState(() {
        if (isPrimary) {
          _ktpPath = compressedFile.path;
        } else {
          _ktpSecondaryPath = compressedFile.path;
        }
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );

    return File(result!.path);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nama Lengkap, Nomor Handphone, NIK, Foto KTP, dan Foto Diri wajib diisi sebelum disimpan / di-upload',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionTitle('Data Utama'),
            _buildTextField(
              'Nomor Handphone *',
              _phoneController,
              isRequired: true,
              hint: 'Contoh: 08123456789',
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (!RegExp(r'^(0|62|\+62)8[1-9][0-9]{6,12}$').hasMatch(v)) {
                    return 'Format nomor HP tidak valid';
                  }
                }
                return null;
              },
            ),
            _buildTextField(
              'NIK *',
              _nikController,
              isRequired: true,
              hint: '16 digit NIK KTP',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (v.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
                    return 'NIK hanya boleh angka';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Foto KTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Ambil 2 foto KTP untuk hasil yang lebih baik. Pastikan KTP terlihat jelas dan tidak blur.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildImagePicker(isPrimary: true),
                const SizedBox(width: 12),
                _buildImagePicker(isPrimary: false),
              ],
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Lainnya'),
            _buildTextField(
              'Nama Lengkap *',
              _nameController,
              isRequired: true,
              hint: 'Masukkan nama sesuai KTP',
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (RegExp(r'[0-9]').hasMatch(v)) {
                    return 'Nama tidak boleh mengandung angka';
                  }
                }
                return null;
              },
            ),
            _buildTextField('Tempat Lahir', _birthPlaceController,
                hint: 'Masukkan tempat lahir sesuai KTP'),
            _buildDateField(),
            _buildDropdown(
              'Jenis Kelamin',
              ['Laki-laki', 'Perempuan'],
              _selectedGender,
              (v) => setState(() => _selectedGender = v!),
            ),
            _buildDropdown(
              'Status',
              ['Belum Menikah', 'Menikah', 'Cerai'],
              _selectedStatus,
              (v) => setState(() => _selectedStatus = v!),
            ),
            _buildTextField('Pekerjaan', _occupationController,
                hint: 'Pilih jenis pekerjaan'),

            const SizedBox(height: 24),
            _buildSectionTitle('Informasi Alamat KTP'),
            _buildTextField('Alamat Lengkap', _addressController,
                hint: 'Masukkan alamat lengkap'),
            _buildLocationDropdowns(_ktpLocationBloc, false),
            _buildTextField(
              'Kode Pos',
              _kodePosController,
              hint: '5 digit kode pos',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v != null && v.isNotEmpty && v.length != 5) {
                  return 'Kode pos harus 5 digit';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                    value: _isDomisiliSameAsKtp,
                    onChanged: (v) => setState(() => _isDomisiliSameAsKtp = v!)),
                const Expanded(
                  child: Text(
                    'Alamat domisili sama dengan alamat pada KTP',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),

            if (!_isDomisiliSameAsKtp) ...[
              _buildSectionTitle('Alamat Domisili'),
              _buildTextField('Alamat Lengkap', _addressDomisiliController,
                  hint: 'Masukkan alamat domisili'),
              _buildLocationDropdowns(_domisiliLocationBloc, true),
              _buildTextField(
                'Kode Pos',
                _kodePosDomisiliController,
                hint: '5 digit kode pos domisili',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length != 5) {
                    return 'Kode pos harus 5 digit';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),
            BlocConsumer<MemberBloc, MemberState>(
              listener: (context, state) {
                if (state.isSyncSuccess) {
                  Navigator.pop(context);
                } else if (state.errorMessage != null && !state.isLoading) {
                  // Error is handled by global listener usually, 
                  // but we might want to stay on the page.
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: state.isLoading ? null : () => _save(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: state.isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Upload Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: state.isLoading ? null : () => _save(true),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Simpan sebagai Draft',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    String? hint,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label, isRequired: isRequired),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (v) {
              if (isRequired && (v == null || v.isEmpty)) {
                return 'Wajib diisi';
              }
              if (validator != null) {
                return validator(v);
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label.replaceAll(' *', ''),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF555555)),
        ),
        if (isRequired || label.contains('*'))
          const Text(' *', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tanggal Lahir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _birthDateController,
            readOnly: true,
            onTap: _selectDate,
            decoration: InputDecoration(
              hintText: 'DD/MM/YYYY',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdowns(LocationBloc bloc, bool isDomisili) {
    return BlocBuilder<LocationBloc, LocationState>(
      bloc: bloc,
      builder: (context, state) {
        return Column(
          children: [
            _buildLocationDropdown(
              'Provinsi',
              state.provinces,
              isDomisili ? _provinsiDomisiliController : _provinsiController,
              (v) {
                if (v != null) bloc.add(GetRegencies(v));
              },
            ),
            _buildLocationDropdown(
              'Kota/Kabupaten',
              state.regencies,
              isDomisili ? _kotaDomisiliController : _kotaController,
              (v) {
                if (v != null) bloc.add(GetDistricts(v));
              },
            ),
            _buildLocationDropdown(
              'Kecamatan',
              state.districts,
              isDomisili ? _kecamatanDomisiliController : _kecamatanController,
              (v) {
                if (v != null) bloc.add(GetVillages(v));
              },
            ),
            _buildLocationDropdown(
              'Kelurahan',
              state.villages,
              isDomisili ? _kelurahanDomisiliController : _kelurahanController,
              (v) {},
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationDropdown(
    String label,
    List<Location> items,
    TextEditingController controller,
    Function(String?) onChanged,
  ) {
    String? selectedValue;
    if (items.any((e) => e.name == controller.text)) {
      selectedValue = controller.text;
    } else {
      controller.text = '';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(items.hashCode),
            initialValue: selectedValue,
            items:
                items.map((e) => DropdownMenuItem(value: e.name, child: Text(e.name))).toList(),
            onChanged: (val) {
              if (val != null) {
                controller.text = val;
                final selectedLocation = items.firstWhere((e) => e.name == val);
                onChanged(selectedLocation.id);
              }
            },
            validator: (v) => (v == null || v.isEmpty) ? 'Wajib dipilih' : null,
            decoration: const InputDecoration(hintText: 'Pilih'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker({required bool isPrimary}) {
    final path = isPrimary ? _ktpPath : _ktpSecondaryPath;
    return Expanded(
      child: InkWell(
        onTap: () => _pickImage(isPrimary),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFDCD6F7),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            image: path != null
                ? (path.startsWith('http') 
                    ? DecorationImage(image: NetworkImage(path), fit: BoxFit.cover)
                    : DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover))
                : null,
          ),
          child: path == null
              ? Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    size: 32,
                  ),
                )
              : Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  void _save(bool isDraft) {
    // Only validate if not a draft
    if (!isDraft) {
      if (!_formKey.currentState!.validate()) return;
      
      if (_ktpPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto KTP Utama wajib diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final member = Member(
      id: widget.member?.id,
      name: _nameController.text,
      nik: _nikController.text,
      phone: _phoneController.text,
      birthPlace: _birthPlaceController.text,
      birthDate: _birthDateController.text,
      gender: _selectedGender,
      status: _selectedStatus,
      occupation: _occupationController.text,
      address: _addressController.text,
      provinsi: _provinsiController.text,
      kotaKabupaten: _kotaController.text,
      kecamatan: _kecamatanController.text,
      kelurahan: _kelurahanController.text,
      kodePos: _kodePosController.text,
      alamatDomisili:
          _isDomisiliSameAsKtp ? _addressController.text : _addressDomisiliController.text,
      provinsiDomisili:
          _isDomisiliSameAsKtp ? _provinsiController.text : _provinsiDomisiliController.text,
      kotaKabupatenDomisili:
          _isDomisiliSameAsKtp ? _kotaController.text : _kotaDomisiliController.text,
      kecamatanDomisili:
          _isDomisiliSameAsKtp ? _kecamatanController.text : _kecamatanDomisiliController.text,
      kelurahanDomisili:
          _isDomisiliSameAsKtp ? _kelurahanController.text : _kelurahanDomisiliController.text,
      kodePosDomisili:
          _isDomisiliSameAsKtp ? _kodePosController.text : _kodePosDomisiliController.text,
      ktpPath: _ktpPath,
      ktpSecondaryPath: _ktpSecondaryPath,
      isSynced: false,
    );

    if (isDraft) {
      context.read<MemberBloc>().add(SaveMember(member));
    } else {
      context.read<MemberBloc>().add(SyncMember(member));
    }

    if (isDraft) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Draft tersimpan!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
