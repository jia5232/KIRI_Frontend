import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/chat/model/chat_room_model.dart';
import 'package:kiri/chat/repository/chat_room_repository.dart';
import 'package:kiri/common/model/cursor_pagination_model.dart';

final chatRoomStateNotifierProvider =
    StateNotifierProvider<ChatRoomStateNotifier, CursorPaginationModelBase>(
        (ref) {
  final repository = ref.watch(chatRoomRepositoryProvider);
  final initialLastPostId = 0;

  final notifier = ChatRoomStateNotifier(
    repository: repository,
    lastPostId: initialLastPostId,
  );
  return notifier;
});

class ChatRoomStateNotifier extends StateNotifier<CursorPaginationModelBase> {
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  final ChatRoomRepository repository;
  int lastPostId;

  ChatRoomStateNotifier({
    required this.repository,
    required this.lastPostId,
  }) : super(CursorPaginationModelLoading()) {
    paginate();
  }

  bool get isMounted => _mounted;

  Future<void> paginate({
    bool fetchMore = false,
  }) async {
    if (!_mounted) return;

    try {
      if (fetchMore &&
          state is CursorPaginationModel &&
          !(state as CursorPaginationModel).meta.hasMore) {
        return; // 추가 데이터가 없으면 더 이상 진행하지 않음
      }

      final CursorPaginationModelBase prevState = state;
      if (!fetchMore) {
        state = CursorPaginationModelLoading();
      }

      final resp = await repository.paginate(lastPostId);

      if (!_mounted) return;

      if (fetchMore && prevState is CursorPaginationModel) {
        final List<ChatRoomModel> newData = List.from(prevState.data)
          ..addAll(resp.data);
        state = resp.copyWith(data: newData);
      } else {
        state = resp;
      }
    } catch (e, stackTrace) {
      // print('Error: $e');
      // print('Stack Trace: $stackTrace');
      state = CursorPaginationModelError(message: e.toString());
      if (!_mounted) return;
      state = CursorPaginationModelError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}
