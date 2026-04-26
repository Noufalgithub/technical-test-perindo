import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:technical_test_superindo/core/utils/constants.dart';
import 'package:technical_test_superindo/core/api/auth_interceptor.dart';
import 'package:technical_test_superindo/data/datasources/auth_remote_datasource.dart';
import 'package:technical_test_superindo/data/datasources/member_local_datasource.dart';
import 'package:technical_test_superindo/data/datasources/member_remote_datasource.dart';
import 'package:technical_test_superindo/data/repositories/auth_repository_impl.dart';
import 'package:technical_test_superindo/data/repositories/member_repository_impl.dart';
import 'package:technical_test_superindo/domain/repositories/auth_repository.dart';
import 'package:technical_test_superindo/domain/repositories/member_repository.dart';
import 'package:technical_test_superindo/domain/repositories/location_repository.dart';
import 'package:technical_test_superindo/presentation/bloc/auth_bloc.dart';
import 'package:technical_test_superindo/presentation/bloc/member_bloc.dart';
import 'package:technical_test_superindo/presentation/bloc/profile_bloc.dart';
import 'package:technical_test_superindo/presentation/bloc/location_bloc.dart';
import 'package:technical_test_superindo/data/datasources/location_remote_datasource.dart';
import 'package:technical_test_superindo/data/repositories/location_repository_impl.dart';

final sl = GetIt.instance;
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> init() async {
  //! Navigator
  sl.registerLazySingleton(() => navigatorKey);

  //! External
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    dio.interceptors.add(AuthInterceptor(sl(), sl()));
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
    return dio;
  });
  
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Database
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'member_offline.db');
  final database = await openDatabase(
    path,
    version: 3,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE members (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          nik TEXT,
          phone TEXT,
          birth_place TEXT,
          birth_date TEXT,
          gender TEXT DEFAULT 'Laki-laki',
          status TEXT,
          occupation TEXT,
          address TEXT,
          provinsi TEXT,
          kota_kabupaten TEXT,
          kecamatan TEXT,
          kelurahan TEXT,
          kode_pos TEXT,
          alamat_domisili TEXT,
          provinsi_domisili TEXT,
          kota_kabupaten_domisili TEXT,
          kecamatan_domisili TEXT,
          kelurahan_domisili TEXT,
          kode_pos_domisili TEXT,
          ktp_path TEXT,
          ktp_secondary_path TEXT,
          user_id TEXT,
          is_synced INTEGER DEFAULT 0
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Migration: add gender column
        await db.execute(
          "ALTER TABLE members ADD COLUMN gender TEXT DEFAULT 'Laki-laki'",
        );
      }
      if (oldVersion < 3) {
        // Migration: add user_id column
        await db.execute(
          "ALTER TABLE members ADD COLUMN user_id TEXT",
        );
      }
    },
  );
  sl.registerLazySingleton(() => database);

  //! Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MemberLocalDataSource>(() => MemberLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<MemberRemoteDataSource>(() => MemberRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<LocationRemoteDataSource>(() => LocationRemoteDataSourceImpl(sl()));

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    remoteDataSource: sl(),
    secureStorage: sl(),
  ));
  sl.registerLazySingleton<MemberRepository>(() => MemberRepositoryImpl(
    localDataSource: sl(),
    remoteDataSource: sl(),
    secureStorage: sl(),
  ));
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(
    remoteDataSource: sl(),
  ));

  //! Bloc
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => MemberBloc(sl()));
  sl.registerFactory(() => ProfileBloc(sl()));
  sl.registerFactory(() => LocationBloc(sl()));
}
