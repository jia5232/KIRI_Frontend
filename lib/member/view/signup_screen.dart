import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kiri/common/component/custom_text_form_field.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/common/view/splash_screen.dart';
import 'package:kiri/member/view/login_screen.dart';

import '../../common/const/data.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final univNames = ['국민대학교', '세종대학교'];
  String univName = '';
  String email_prefix = '';
  final email_suffix = {'국민대학교': '@kookmin.ac.kr', '세종대학교': '@sejong.ac.kr'};
  String email = '';
  String key = ''; // 서버에서 받아올 이메일 인증번호
  String inputKey = ''; // 사용자가 입력할 이메일 인증번호
  String nickname = '';
  String password = '';
  String password2 = '';
  bool isAccept = false;

  //이메일, 비밀번호, 닉네임 검증
  bool isEmailNull = true;
  bool isEmailDuplicated = false; //true로 두고 이메일 중복 작업해야 함.
  bool isEmailAuthenticated = true; // false로 두고 이메일 인증 작업해야 함.
  bool isPasswordNull = true;
  bool isPasswordDifferent = false;
  bool isNicknameDuplicated = false; //true로 두고 닉네임 중복 작업해야 함.

  @override
  void initState() {
    super.initState();
    setState(() {
      univName = univNames[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.chevron_left,
                        color: PRIMARY_COLOR,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 2 - 85),
                    Text(
                      'KIRI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: PRIMARY_COLOR,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text('학교'),
                DropdownButton(
                  value: univName,
                  items: univNames
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      univName = value!;
                    });
                  },
                ),
                SizedBox(height: 26.0),
                Text('이메일'),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: CustomTextFormField(
                        suffixText: email_suffix[univName] == null
                            ? ''
                            : email_suffix[univName],
                        hintText: '이메일 입력',
                        onChanged: (String value) {
                          email_prefix = value;
                          setState(() {
                            isEmailNull = email_prefix == '' ? true : false;
                          });
                          if (email_suffix[univName] == null) {
                            return;
                          }
                          email = email_prefix + email_suffix[univName]!;
                        },
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        // minimumSize:,
                      ),
                      onPressed: () {
                        // 인증번호 전송 api
                        // 중복 이메일 -> 이미 가입된 이메일입니다.
                        // 신규 이메일 -> 서버에서 인증번호를 받아 저장해둔다.
                        // key = 서버에서 발급한 인증번호.
                      },
                      child: Text('인증'),
                    ),
                  ],
                ),
                if (isEmailNull) //이메일 검증
                  Text(
                    '이메일은 빈칸일 수 없습니다.',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: CustomTextFormField(
                        hintText: '인증번호 입력',
                        onChanged: (String value) {
                          inputKey = value;
                          setState(() {
                            isEmailAuthenticated =
                                key == inputKey ? true : false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      onPressed: () {
                        // 인증번호 확인 api
                      },
                      child: Text('확인'),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Text('닉네임'),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3 * 2,
                      child: CustomTextFormField(
                        hintText: '닉네임 입력',
                        onChanged: (String value) {
                          nickname = value;
                        },
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      onPressed: () {
                        // 닉네임 중복 확인 api
                      },
                      child: Text('확인'),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Text('비밀번호'),
                SizedBox(height: 4.0),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요.',
                  onChanged: (String value) {
                    password = value;
                    setState(() {
                      isPasswordDifferent =
                          password == password2 ? false : true;
                      isPasswordNull =
                          (password == '' && password2 == '') ? true : false;
                    });
                  },
                  obscureText: true,
                ),
                SizedBox(height: 8.0),
                CustomTextFormField(
                  hintText: '비밀번호를 한번 더 입력해주세요.',
                  onChanged: (String value) {
                    password2 = value;
                    setState(() {
                      isPasswordDifferent =
                          password == password2 ? false : true;
                      isPasswordNull =
                          (password == '' && password2 == '') ? true : false;
                    });
                  },
                  obscureText: true,
                ),
                if (isPasswordDifferent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '비밀번호가 일치하지 않습니다.',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                if (isPasswordNull)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '비밀번호는 빈칸일 수 없습니다.',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                SizedBox(height: 26.0),
                Row(
                  children: [
                    Text('개인정보 수집 및 이용 동의'),
                    Checkbox(
                      activeColor: PRIMARY_COLOR,
                      value: isAccept,
                      onChanged: (bool? value) {
                        setState(() {
                          isAccept = value ?? false;
                        });
                      },
                    ),
                    TextButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: PRIMARY_COLOR,
                          minimumSize: Size(80.0, 30.0),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text('개인정보 수집 및 이용동의 관련 내용'),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PRIMARY_COLOR,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Center(
                                      child: Text('닫기'),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('내용 확인')),
                  ],
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    minimumSize: Size(
                      MediaQuery.of(context).size.width,
                      50.0,
                    ),
                  ),
                  onPressed: () async {
                    if (!isEmailNull &&
                        !isEmailDuplicated &&
                        !isPasswordNull &&
                        !isPasswordDifferent &&
                        !isNicknameDuplicated &&
                        isAccept &&
                        isEmailAuthenticated) {
                      // 회원가입 api 요청..

                      try {
                        final resp = await dio.post(
                          'http://$ip/signup',
                          data: {
                            'email': email,
                            'password': password,
                            'nickname': nickname,
                            'univName': univName,
                            'isAccept': isAccept,
                            'isEmailAuthenticated': isEmailAuthenticated,
                          },
                        );

                        print(resp.data.toString());

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(),
                          ),
                        );
                      } catch (e) {
                        //서버에서 넘긴 에러를 모달로 띄워줘야 한다.
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => SignupScreen(),
                        //   ),
                        // );
                      }
                    }
                  },
                  child: Text('회원가입하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
