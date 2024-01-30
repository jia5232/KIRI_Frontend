// 캐싱을 위한 provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/post/model/post_model.dart';
import 'package:kiri/post/provider/post_repository_provider.dart';
import 'package:kiri/post/provider/post_screen_provider.dart';
import 'package:kiri/post/repository/post_repository.dart';

// postStateNotifierProvider의 존재로 인해 post_screen에 Future builder가 필요하지 않게 된다.
final postStateNotifierProvider =
    StateNotifierProvider<PostStateNotifier, List<PostModel>>(
  (ref) {
    final repository = ref.watch(postRepositoryProvider);
    final isFromSchool = ref.watch(fromSchoolProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);
    const initialLastPostId = 0;

    final notifier = PostStateNotifier(
        repository: repository,
        lastPostId: initialLastPostId,
        isFromSchool: isFromSchool,
        searchKeyword: searchKeyword);
    return notifier;
  },
);

class PostStateNotifier extends StateNotifier<List<PostModel>> {
  final PostRepository repository;
  int lastPostId;
  bool isFromSchool;
  String? searchKeyword;

  PostStateNotifier({
    required this.repository,
    required this.lastPostId,
    required this.isFromSchool,
    required this.searchKeyword,
  }) : super([]) {
    paginate(lastPostId, isFromSchool, searchKeyword);
  }

  paginate(int lastPostId, bool isFromSchool, String? searchKeyword) async {
    final resp = await repository.paginate(lastPostId, isFromSchool, searchKeyword);
    this.lastPostId = lastPostId;
    state = resp.data;
  }
}
