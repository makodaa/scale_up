import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:scale_up/data/sources/firebase/firestore_helper.dart";
import "package:scale_up/presentation/bloc/UserData/user_data_event.dart";
import "package:scale_up/presentation/bloc/UserData/user_data_state.dart";

export "user_data_event.dart";
export "user_data_state.dart";

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {
  UserDataBloc({required FirestoreHelper firestoreHelper})
    : _firestoreHelper = firestoreHelper,
      super(UserDataState(user: null, status: UserDataStatus.none, finishedChapters: {})) {
    on<LoggedInUserDataEvent>(_onLoggedIn);
    on<LoggedOutUserDataEvent>(_onLoggedOut);
    on<ChapterCompletedUserDataEvent>(_onChapterCompleted);
  }

  final FirestoreHelper _firestoreHelper;

  Future<void> _onLoggedIn(LoggedInUserDataEvent event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));

    var finishedChapters = await _firestoreHelper.getCompletedChapters(user: event.user);

    emit(
      state.copyWith(
        status: UserDataStatus.loaded,
        user: event.user,
        finishedChapters: finishedChapters,
      ),
    );
  }

  Future<void> _onLoggedOut(LoggedOutUserDataEvent event, Emitter<UserDataState> emit) async {
    emit(state.copyWith(status: UserDataStatus.loading));
    await Future.delayed(Duration.zero);
    emit(state.copyWith(status: UserDataStatus.loaded, user: null, finishedChapters: {}));
  }

  FutureOr<void> _onChapterCompleted(
    ChapterCompletedUserDataEvent event,
    Emitter<UserDataState> emit,
  ) {
    if (state case UserDataState(:var user?)) {
      var ChapterCompletedUserDataEvent(:lessonId, :chapterIndex) = event;
      var key = "$lessonId:$chapterIndex";

      var finishedChapters = state.finishedChapters..add(key);
      emit(state.copyWith(finishedChapters: finishedChapters));

      unawaited(_firestoreHelper.registerChapterAsCompletedAsync(user, lessonId, chapterIndex));
    }
  }
}
