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

// States
abstract class MemberState extends Equatable {
  const MemberState();
  @override
  List<Object> get props => [];
}

class MemberInitial extends MemberState {}

class MemberLoading extends MemberState {}

class MemberLoaded extends MemberState {
  final List<Member> members;
  const MemberLoaded(this.members);
  @override
  List<Object> get props => [members];
}

class MemberFailure extends MemberState {
  final String message;
  const MemberFailure(this.message);
  @override
  List<Object> get props => [message];
}

class MemberSyncSuccess extends MemberState {}

// Bloc
class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final MemberRepository repository;

  MemberBloc(this.repository) : super(MemberInitial()) {
    on<FetchMembers>((event, emit) async {
      emit(MemberLoading());
      final result = event.isSynced 
          ? await repository.getSyncedMembers() 
          : await repository.getDraftMembers();
      
      result.fold(
        (failure) => emit(MemberFailure(failure.message)),
        (members) => emit(MemberLoaded(members)),
      );
    });

    on<SaveMember>((event, emit) async {
      emit(MemberLoading());
      final result = await repository.saveMemberLocally(event.member);
      result.fold(
        (failure) => emit(MemberFailure(failure.message)),
        (_) {
          emit(MemberInitial()); // Trigger reload
          add(const FetchMembers(isSynced: false));
        },
      );
    });

    on<SyncMember>((event, emit) async {
      emit(MemberLoading());
      final result = await repository.syncMember(event.member);
      result.fold(
        (failure) => emit(MemberFailure(failure.message)),
        (_) {
          emit(MemberSyncSuccess());
          add(const FetchMembers(isSynced: false));
        },
      );
    });

    on<SyncAllMembers>((event, emit) async {
      emit(MemberLoading());
      final draftsResult = await repository.getDraftMembers();
      
      await draftsResult.fold(
        (failure) async => emit(MemberFailure(failure.message)),
        (drafts) async {
          if (drafts.isEmpty) {
            emit(const MemberFailure('No drafts to sync'));
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
            emit(MemberSyncSuccess());
            add(const FetchMembers(isSynced: false));
          } else {
            emit(MemberFailure(lastError ?? 'Some members failed to sync'));
          }
        },
      );
    });
  }
}
