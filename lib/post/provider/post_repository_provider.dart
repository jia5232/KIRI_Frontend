import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/provider/dio_provider.dart';
import 'package:kiri/post/repository/post_repository.dart';

import '../../common/const/data.dart';

// postRepository를 관리하는 provider

final postRepositoryProvider = Provider<PostRepository>(
  (ref){
    final dio = ref.watch(dioProvider);
    final repository = PostRepository(dio, baseUrl: "http://$ip/posts");
    return repository;
  },
);
