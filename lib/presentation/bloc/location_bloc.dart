import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:technical_test_superindo/domain/entities/location.dart';
import 'package:technical_test_superindo/domain/repositories/location_repository.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
  @override
  List<Object> get props => [];
}

class GetProvinces extends LocationEvent {}

class GetRegencies extends LocationEvent {
  final String provinceId;
  const GetRegencies(this.provinceId);
  @override
  List<Object> get props => [provinceId];
}

class GetDistricts extends LocationEvent {
  final String regencyId;
  const GetDistricts(this.regencyId);
  @override
  List<Object> get props => [regencyId];
}

class GetVillages extends LocationEvent {
  final String districtId;
  const GetVillages(this.districtId);
  @override
  List<Object> get props => [districtId];
}

enum LocationStatus { initial, loading, success, failure }

class LocationState extends Equatable {
  final LocationStatus status;
  final List<Location> provinces;
  final List<Location> regencies;
  final List<Location> districts;
  final List<Location> villages;
  final String? message;

  const LocationState({
    this.status = LocationStatus.initial,
    this.provinces = const [],
    this.regencies = const [],
    this.districts = const [],
    this.villages = const [],
    this.message,
  });

  LocationState copyWith({
    LocationStatus? status,
    List<Location>? provinces,
    List<Location>? regencies,
    List<Location>? districts,
    List<Location>? villages,
    String? message,
  }) {
    return LocationState(
      status: status ?? this.status,
      provinces: provinces ?? this.provinces,
      regencies: regencies ?? this.regencies,
      districts: districts ?? this.districts,
      villages: villages ?? this.villages,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, provinces, regencies, districts, villages, message];
}

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc(this.repository) : super(const LocationState()) {
    on<GetProvinces>((event, emit) async {
      emit(state.copyWith(status: LocationStatus.loading));
      final result = await repository.getProvinces();
      result.fold(
        (failure) => emit(state.copyWith(status: LocationStatus.failure, message: failure.message)),
        (data) => emit(state.copyWith(status: LocationStatus.success, provinces: data, regencies: [], districts: [], villages: [])),
      );
    });

    on<GetRegencies>((event, emit) async {
      emit(state.copyWith(status: LocationStatus.loading));
      final result = await repository.getRegencies(event.provinceId);
      result.fold(
        (failure) => emit(state.copyWith(status: LocationStatus.failure, message: failure.message)),
        (data) => emit(state.copyWith(status: LocationStatus.success, regencies: data, districts: [], villages: [])),
      );
    });

    on<GetDistricts>((event, emit) async {
      emit(state.copyWith(status: LocationStatus.loading));
      final result = await repository.getDistricts(event.regencyId);
      result.fold(
        (failure) => emit(state.copyWith(status: LocationStatus.failure, message: failure.message)),
        (data) => emit(state.copyWith(status: LocationStatus.success, districts: data, villages: [])),
      );
    });

    on<GetVillages>((event, emit) async {
      emit(state.copyWith(status: LocationStatus.loading));
      final result = await repository.getVillages(event.districtId);
      result.fold(
        (failure) => emit(state.copyWith(status: LocationStatus.failure, message: failure.message)),
        (data) => emit(state.copyWith(status: LocationStatus.success, villages: data)),
      );
    });
  }
}
