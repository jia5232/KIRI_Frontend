import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kiri/common/const/data.dart';
import 'package:kiri/common/view/root_tab.dart';
import 'package:kiri/user/view/signup_screen.dart';

import '../../user/view/login_screen.dart';
import '../const/colors.dart';
import '../layout/default_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    // deleteToken();
    checkToken();
  }

  void deleteToken() async {
    await storage.deleteAll();
  }

  void checkToken() async {
    // 토큰 확인 필요
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    print('refreshToken: $refreshToken');
    print('accessToken: $accessToken');

    try {
      final resp = await dio.post( //토큰 재발행이 제대로 안되는상황!!!!!
        'http://$ip/token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      final refreshTokenArray = resp.headers['refreshToken'];
      final accessTokenArray = resp.headers['accessToken'];

      final newRefreshToken = refreshTokenArray != null
          ? refreshTokenArray[0].substring("Bearer ".length)
          : null;
      final newAccessToken = accessTokenArray != null
          ? accessTokenArray[0].substring("Bearer ".length)
          : null;

      print("newRefreshToken: $newRefreshToken");
      print("newAccessToken: $newAccessToken");

      if (newRefreshToken == null || newAccessToken == null) {
        print("token null!!!");
      }

      await storage.write(
          key: REFRESH_TOKEN_KEY, value: newRefreshToken);
      await storage.write(
          key: ACCESS_TOKEN_KEY, value: newAccessToken);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RootTab(),
        ),
      );
    } catch (e) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      );
    }
  }

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
