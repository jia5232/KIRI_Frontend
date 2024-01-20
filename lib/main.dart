import 'package:flutter/material.dart';
import 'package:kiri/common/view/root_tab.dart';

void main() {
  runApp(_App());
}

class _App extends StatelessWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'NotoSans',
        ),
      debugShowCheckedModeBanner: false,
      home: RootTab(),
      );
  }
}
