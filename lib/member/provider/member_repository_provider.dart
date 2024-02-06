import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/provider/dio_provider.dart';
import 'package:kiri/member/repository/member_repository.dart';

import '../../common/const/data.dart';

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) {
    final dio = ref.watch(dioProvider);
    
    return MemberRepository(dio, baseUrl: 'http://$ip/member');
  },
);
