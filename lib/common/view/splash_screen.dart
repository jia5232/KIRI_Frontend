import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/const/data.dart';
import 'package:kiri/common/dio/secure_storage.dart';
import 'package:kiri/common/provider/dio_provider.dart';
import 'package:kiri/common/view/root_tab.dart';

import '../../member/view/login_screen.dart';
import '../const/colors.dart';
import '../layout/default_layout.dart';

class SplashScreen extends StatelessWidget {
  static String get routeName => 'splash';

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: PRIMARY_COLOR,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/imgs/taxi.png',
              width: MediaQuery.of(context).size.width / 2,
            ),
            const SizedBox(
              height: 16.0,
            ),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
