import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/provider/dio_provider.dart';
import 'package:kiri/member/repository/auth_repository.dart';

import '../../common/const/data.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return AuthRepository(
    baseUrl: 'http://$ip',
    dio: dio,
  );
});
