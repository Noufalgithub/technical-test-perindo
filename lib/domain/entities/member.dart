import 'package:equatable/equatable.dart';

class Member extends Equatable {
  final int? id;
  final String name;
  final String nik;
  final String phone;
  final String birthPlace;
  final String birthDate;
  final String gender;
  final String status;
  final String occupation;
  final String address;
  final String provinsi;
  final String kotaKabupaten;
  final String kecamatan;
  final String kelurahan;
  final String kodePos;
  final String alamatDomisili;
  final String provinsiDomisili;
  final String kotaKabupatenDomisili;
  final String kecamatanDomisili;
  final String kelurahanDomisili;
  final String kodePosDomisili;
  final String? ktpPath;
  final String? ktpSecondaryPath;
  final String? ktpUrl;
  final String? ktpSecondaryUrl;
  final bool isSynced;

  const Member({
    this.id,
    required this.name,
    required this.nik,
    required this.phone,
    required this.birthPlace,
    required this.birthDate,
    this.gender = 'Laki-laki',
    required this.status,
    required this.occupation,
    required this.address,
    required this.provinsi,
    required this.kotaKabupaten,
    required this.kecamatan,
    required this.kelurahan,
    required this.kodePos,
    required this.alamatDomisili,
    required this.provinsiDomisili,
    required this.kotaKabupatenDomisili,
    required this.kecamatanDomisili,
    required this.kelurahanDomisili,
    required this.kodePosDomisili,
    this.ktpPath,
    this.ktpSecondaryPath,
    this.ktpUrl,
    this.ktpSecondaryUrl,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'nik': nik,
      'phone': phone,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'gender': gender,
      'status': status,
      'occupation': occupation,
      'address': address,
      'provinsi': provinsi,
      'kota_kabupaten': kotaKabupaten,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'kode_pos': kodePos,
      'alamat_domisili': alamatDomisili,
      'provinsi_domisili': provinsiDomisili,
      'kota_kabupaten_domisili': kotaKabupatenDomisili,
      'kecamatan_domisili': kecamatanDomisili,
      'kelurahan_domisili': kelurahanDomisili,
      'kode_pos_domisili': kodePosDomisili,
      'ktp_path': ktpPath,
      'ktp_secondary_path': ktpSecondaryPath,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      name: map['name']?.toString() ?? map['full_name']?.toString() ?? '',
      nik: map['nik']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      birthPlace: map['birth_place']?.toString() ?? '',
      birthDate: map['birth_date']?.toString() ?? '',
      gender: map['gender']?.toString() ?? 'Laki-laki',
      status: map['status']?.toString() ?? '',
      occupation: map['occupation']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      provinsi: map['provinsi']?.toString() ?? '',
      kotaKabupaten: map['kota_kabupaten']?.toString() ?? '',
      kecamatan: map['kecamatan']?.toString() ?? '',
      kelurahan: map['kelurahan']?.toString() ?? '',
      kodePos: map['kode_pos']?.toString() ?? '',
      alamatDomisili: map['alamat_domisili']?.toString() ?? '',
      provinsiDomisili: map['provinsi_domisili']?.toString() ?? '',
      kotaKabupatenDomisili: map['kota_kabupaten_domisili']?.toString() ?? '',
      kecamatanDomisili: map['kecamatan_domisili'] ?? '',
      kelurahanDomisili: map['kelurahan_domisili'] ?? '',
      kodePosDomisili: map['kode_pos_domisili'] ?? '',
      ktpPath: map['ktp_path']?.toString(),
      ktpSecondaryPath: map['ktp_secondary_path']?.toString(),
      ktpUrl: map['ktp_url']?.toString(),
      ktpSecondaryUrl: map['ktp_url_secondary']?.toString() ?? map['ktp_secondary_url']?.toString(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nik,
        phone,
        gender,
        isSynced,
      ];
}
