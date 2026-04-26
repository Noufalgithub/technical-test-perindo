import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:technical_test_superindo/domain/entities/member.dart';
import 'package:technical_test_superindo/domain/repositories/member_repository.dart';

// Events
abstract class MemberEvent extends Equatable {
  const MemberEvent();
  @override
  List<Object> get props => [];
}

class FetchMembers extends MemberEvent {
  final bool isSynced;
  const FetchMembers({this.isSynced = false});
  @override
  List<Object> get props => [isSynced];
}

class SaveMember extends MemberEvent {
  final Member member;
  const SaveMember(this.member);
  @override
  List<Object> get props => [member];
}

class SyncMember extends MemberEvent {
  final Member member;
  const SyncMember(this.member);
  @override
  List<Object> get props => [member];
}

class SyncAllMembers extends MemberEvent {}

class DeleteAllMembers extends MemberEvent {}

// States
class MemberState extends Equatable {
  final bool isLoading;
  final List<Member> draftMembers;
  final List<Member> syncedMembers;
  final String? errorMessage;
  final bool isSyncSuccess;

  const MemberState({
    this.isLoading = false,
    this.draftMembers = const [],
    this.syncedMembers = const [],
    this.errorMessage,
    this.isSyncSuccess = false,
  });

  // Helper to get current view list
  List<Member> get members => draftMembers; // For backward compatibility or default

  MemberState copyWith({
    bool? isLoading,
    List<Member>? draftMembers,
    List<Member>? syncedMembers,
    String? errorMessage,
    bool? isSyncSuccess,
  }) {
    return MemberState(
      isLoading: isLoading ?? this.isLoading,
      draftMembers: draftMembers ?? this.draftMembers,
      syncedMembers: syncedMembers ?? this.syncedMembers,
      errorMessage: errorMessage,
      isSyncSuccess: isSyncSuccess ?? false,
    );
  }

  @override
  List<Object?> get props => [isLoading, draftMembers, syncedMembers, errorMessage, isSyncSuccess];
}

// Bloc
class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final MemberRepository repository;

  MemberBloc(this.repository) : super(const MemberState()) {
    on<FetchMembers>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final result = event.isSynced 
          ? await repository.getSyncedMembers() 
          : await repository.getDraftMembers();
      
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (members) {
          if (event.isSynced) {
            emit(state.copyWith(isLoading: false, syncedMembers: members));
          } else {
            emit(state.copyWith(isLoading: false, draftMembers: members));
          }
        },
      );
    });

    on<SaveMember>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final result = await repository.saveMemberLocally(event.member);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, isSyncSuccess: true));
          add(const FetchMembers(isSynced: false));
        },
      );
    });

    on<SyncMember>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final result = await repository.syncMember(event.member);
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, isSyncSuccess: true));
          add(const FetchMembers(isSynced: false));
        },
      );
    });

    on<SyncAllMembers>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final draftsResult = await repository.getDraftMembers();
      
      final drafts = draftsResult.getOrElse(() => []);
      
      if (drafts.isEmpty) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Tidak ada data draft untuk di-upload'));
        add(const FetchMembers(isSynced: false));
        return;
      }

      bool allSuccess = true;
      String? lastError;

      for (var member in drafts) {
        final syncResult = await repository.syncMember(member);
        syncResult.fold(
          (failure) {
            allSuccess = false;
            lastError = failure.message;
          },
          (_) => null,
        );
      }

      if (allSuccess) {
        emit(state.copyWith(isLoading: false, isSyncSuccess: true));
        add(const FetchMembers(isSynced: false));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: lastError ?? 'Beberapa data gagal di-upload'));
        add(const FetchMembers(isSynced: false));
      }
    });
    on<DeleteAllMembers>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final result = await repository.deleteAllMembers();
      result.fold(
        (failure) => emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
        (_) {
          emit(state.copyWith(isLoading: false, draftMembers: []));
        },
      );
    });
  }
}
