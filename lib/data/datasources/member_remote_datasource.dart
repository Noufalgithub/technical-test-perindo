import 'package:dio/dio.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';

abstract class MemberRemoteDataSource {
  Future<void> uploadMember(Member member);
  Future<List<Member>> getSyncedMembers();
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final Dio dio;

  MemberRemoteDataSourceImpl(this.dio);

  @override
  Future<void> uploadMember(Member member) async {
    final formData = FormData.fromMap({
      'name': member.name,
      'nik': member.nik,
      'phone': member.phone,
      'birth_place': member.birthPlace,
      'birth_date': member.birthDate,
      'gender': member.gender,
      'status': member.status,
      'occupation': member.occupation,
      'address': member.address,
      'provinsi': member.provinsi,
      'kota_kabupaten': member.kotaKabupaten,
      'kecamatan': member.kecamatan,
      'kelurahan': member.kelurahan,
      'kode_pos': member.kodePos,
      'alamat_domisili': member.alamatDomisili,
      'provinsi_domisili': member.provinsiDomisili,
      'kota_kabupaten_domisili': member.kotaKabupatenDomisili,
      'kecamatan_domisili': member.kecamatanDomisili,
      'kelurahan_domisili': member.kelurahanDomisili,
      'kode_pos_domisili': member.kodePosDomisili,
    });

    if (member.ktpPath != null) {
      formData.files.add(MapEntry(
        'ktp_file',
        await MultipartFile.fromFile(member.ktpPath!, filename: 'ktp_primary.jpg'),
      ));
    }

    if (member.ktpSecondaryPath != null) {
      formData.files.add(MapEntry(
        'ktp_file_secondary',
        await MultipartFile.fromFile(member.ktpSecondaryPath!, filename: 'ktp_secondary.jpg'),
      ));
    }

    await dio.post('/member', data: formData);
  }

  @override
  Future<List<Member>> getSyncedMembers() async {
    final response = await dio.get('/member');
    if (response.data == null) return [];
    if (response.data is! List) return [];
    final List<dynamic> data = response.data;
    return data.map((json) => Member.fromMap(json)).toList();
  }
}
