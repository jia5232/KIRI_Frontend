import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/member/provider/member_state_notifier_provider.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key}); //보문

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: TextButton(
        onPressed: (){
          ref.read(memberStateNotifierProvider.notifier).logout();
        },
        child: Text('로그아웃'),
      ),
    );
  }
}
