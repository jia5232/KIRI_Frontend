import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/member/provider/member_state_notifier_provider.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: (){
          ref.read(memberStateNotifierProvider.notifier).logout();
        },
        child: Text('로그아웃'),
      ),
    );
  }
}
