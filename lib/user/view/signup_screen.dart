import 'package:flutter/material.dart';
import 'package:kiri/common/component/custom_text_form_field.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';

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
  String password = '';
  String password2 = '';
  bool isAccept = false;

  //이메일, 비밀번호 검증
  bool isEmailNull = true;
  bool isEmailDuplicated = false; //이메일 중복 작업해야 함.
  bool isPasswordNull = true;
  bool isPasswordDifferent = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      univName = univNames[0];
    });
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(height: 30.0),
                Center(
                  child: Text(
                    'SIGNUP',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Text('학교'),
                DropdownButton(
                  value: univNames[0],
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
                      width: 120,
                      height: 30,
                      child: CustomTextFormField(
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
                    SizedBox(width: 6.0),
                    Text(email_suffix[univName]!),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        fixedSize: Size(100.0, 20.0),
                      ),
                      onPressed: () {},
                      child: Text('중복확인'),
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
                  ),
                  onPressed: () {
                    if (!isEmailNull &&
                        !isEmailDuplicated &&
                        !isPasswordNull &&
                        !isPasswordDifferent &&
                        isAccept) {
                      // 회원가입 api 요청..
                      print("univName: $univName");
                      print("email: $email");
                      print("password: $password");
                      print("password2: $password");
                      print("isAccept: $isAccept");
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
