import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiri/common/dio/secure_storage.dart';
import 'package:kiri/user/view/signup_screen.dart';

import '../../common/component/custom_text_form_field.dart';
import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../../common/layout/default_layout.dart';
import '../../common/view/root_tab.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return DefaultLayout(
      child: SingleChildScrollView(
        // SingleChildScrollView -> 화면 크기를 늘려주는것
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        // keyboardDismissBehavior = 스크롤을 움직이면 올라왔던 키보드가 바로 다시 내려가게 함..
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'KIRI',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: PRIMARY_COLOR,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _Title(),
                _SubTitle(),
                // Image.asset(
                //   'asset/imgs/taxi.png',
                //   width: MediaQuery.of(context).size.width / 3 * 2 ,
                // ),
                const SizedBox(height: 16.0),
                CustomTextFormField(
                  hintText: '이메일을 입력해주세요.',
                  onChanged: (String value) {
                    email = value;
                  },
                ),
                const SizedBox(height: 16.0),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요.',
                  onChanged: (String value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final resp = await dio.post(
                      'http://$ip/login',
                      data: {'email': email, 'password': password},
                      options: Options(
                        headers: {'Content-Type': 'application/json'},
                      ),
                    );

                    final refreshTokenArray = resp.headers['refreshToken'];
                    final accessTokenArray = resp.headers['accessToken'];

                    final refreshToken = refreshTokenArray != null
                        ? refreshTokenArray[0].substring("Bearer ".length)
                        : null;
                    final accessToken = accessTokenArray != null
                        ? accessTokenArray[0].substring("Bearer ".length)
                        : null;

                    if (refreshToken == null || accessToken == null) {
                      print("token null!!!");
                    }
                    
                    final storage = ref.read(secureStorageProvider);

                    await storage.write(
                        key: REFRESH_TOKEN_KEY, value: refreshToken);
                    await storage.write(
                        key: ACCESS_TOKEN_KEY, value: accessToken);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RootTab(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                  ),
                  child: Text(
                    '로그인',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: PRIMARY_COLOR,
                  ),
                  child: Text('회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '등하교 택시 쉐어 서비스, 끼리',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '학교 이메일과 비밀번호를 입력해서 로그인 해주세요!',
      style: TextStyle(
        fontSize: 16,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
