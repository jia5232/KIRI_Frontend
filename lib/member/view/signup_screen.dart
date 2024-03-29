import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/component/custom_text_form_field.dart';
import 'package:kiri/common/component/notice_popup_dialog.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/common/provider/dio_provider.dart';

import '../../common/const/data.dart';
import '../provider/university_suffix_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  static String get routeName => 'signup';

  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String emailPrefix = '';
  String univName = '';
  String email = '';

  String authNumber =
      'tmp129049492094nkdsjlkfjwl'; // 이후 서버에서 받아올 이메일 인증번호로 초기화됨
  String inputAuthNumber = ''; // 사용자가 입력할 이메일 인증번호
  String nickname = '';
  String password = '';
  String password2 = '';
  bool isAccept = false;

  //이메일, 비밀번호, 닉네임 검증
  bool isEmailNull = true;
  bool isEmailAuthenticated = false; // false로 두고 이메일 인증 작업해야 함.
  bool isPasswordNull = true;
  bool isPasswordDifferent = false;
  bool isNicknameNull = true;
  bool isNicknameDuplicated = true; //true로 두고 닉네임 중복 작업해야 함.

  @override
  void initState() {
    super.initState();
  }

  void getNoticeDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: message,
          buttonText: "닫기",
          onPressed: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void getSignupResultDialog(BuildContext context, String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: message,
          buttonText: "로그인 하러 가기",
          onPressed: () {
            //Dialog를 닫고 로그인페이지로 나가야 하므로 두번 pop.
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dio = ref.watch(dioProvider);
    final universitySuffixData = ref.watch(universitySuffixProvider);

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
                universitySuffixData.when(
                  data: (Map<String, String> emailSuffixes) {
                    List<String> univNames = emailSuffixes.keys.toList();
                    // 기본적으로 첫 번째 대학교를 선택
                    if (univName.isEmpty && univNames.isNotEmpty) {
                      univName = univNames.first;
                    }
                    return DropdownButton<String>(
                      value: univName,
                      items: univNames
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          univName = newValue!;
                        });
                      },
                    );
                  },
                  loading: () => CircularProgressIndicator(),
                  error: (_, __) => Text('데이터 로딩 실패'),
                ),
                SizedBox(height: 26.0),
                Text('이메일'),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    universitySuffixData.when(
                      data: (Map<String, String> emailSuffixes) {
                        // 선택된 대학교의 이메일 접미사를 가져온당
                        String currentSuffix = emailSuffixes[univName] ?? '';
                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 3 * 2,
                          child: CustomTextFormField(
                            isInputEnabled: !isEmailAuthenticated,
                            suffixText: currentSuffix, //동적으로 할당된다!
                            hintText: '이메일 입력',
                            onChanged: (String value) {
                              emailPrefix = value;
                              setState(() {
                                isEmailNull = emailPrefix.isEmpty; // 간소화된 조건문
                                email = "$emailPrefix$currentSuffix";
                              });
                            },
                          ),
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (_, __) => Text('데이터 로딩 실패'),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        // minimumSize:,
                      ),
                      onPressed: (isEmailNull || isEmailAuthenticated)
                          ? null
                          : () async {
                              try {
                                final resp = await dio.post(
                                  'http://$ip/email',
                                  data: {'email': email},
                                  options: Options(
                                    headers: {
                                      'Content-Type': 'application/json'
                                    },
                                  ),
                                );
                                if (resp.data.containsKey('exist')) {
                                  getNoticeDialog(
                                      context, resp.data['exist'].toString());
                                } else if (resp.data
                                    .containsKey('authNumber')) {
                                  authNumber = resp.data['authNumber'];
                                } else {
                                  getNoticeDialog(
                                      context, '알 수 없는 오류가 발생했습니다.');
                                }
                              } catch(e){
                                getNoticeDialog(
                                    context, '알 수 없는 오류가 발생했습니다.');
                              }
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
                        isInputEnabled: isEmailAuthenticated ? false : true,
                        hintText: '인증번호 입력',
                        onChanged: (String value) {
                          setState(() {
                            inputAuthNumber = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      onPressed: isEmailAuthenticated
                          ? null
                          : () {
                              setState(() {
                                isEmailAuthenticated =
                                    authNumber == inputAuthNumber
                                        ? true
                                        : false;
                              });

                              if (isEmailAuthenticated) {
                                getNoticeDialog(context, '인증번호가 일치합니다.');
                              } else {
                                getNoticeDialog(context, '인증번호가 일치하지 않습니다.');
                              }
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
                        isInputEnabled: isNicknameDuplicated ? true : false,
                        hintText: '닉네임 입력',
                        onChanged: (String value) {
                          nickname = value;
                          setState(() {
                            isNicknameNull = nickname == '' ? true : false;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                      ),
                      onPressed: (isNicknameNull || !isNicknameDuplicated)
                          ? null
                          : () async {
                              try{
                                // 닉네임 중복 확인 api
                                final resp = await dio.get(
                                  'http://$ip/nicknameExists',
                                  data: {'nickname': nickname},
                                  options: Options(
                                    headers: {'Content-Type': 'application/json'},
                                  ),
                                );
                                setState(() {
                                  isNicknameDuplicated = resp.data;
                                });

                                if (isNicknameDuplicated) {
                                  getNoticeDialog(context, '이미 사용중인 닉네임입니다.');
                                } else {
                                  getNoticeDialog(context, '사용 가능한 닉네임입니다');
                                }
                              } catch(e){
                                getNoticeDialog(
                                    context, '알 수 없는 오류가 발생했습니다.');
                              }
                            },
                      child: Text('확인'),
                    ),
                  ],
                ),
                if (isNicknameNull) //이메일 검증
                  Text(
                    '닉네임은 빈칸일 수 없습니다.',
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
                        isEmailAuthenticated &&
                        !isPasswordNull &&
                        !isPasswordDifferent &&
                        !isNicknameNull &&
                        !isNicknameDuplicated &&
                        isAccept) {
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
                          options: Options(
                            headers: {'Content-Type': 'application/json'},
                          ),
                        );
                        if (resp.statusCode == 200) {
                          //리다이렉트 로직 다시 짜기!
                          getSignupResultDialog(context, "회원가입이 완료되었습니다.");
                        }
                      } catch (e) {
                        getNoticeDialog(context, "회원가입에 실패했습니다.");
                      }
                    } else {
                      getNoticeDialog(context, "회원가입에 필요한 정보를 모두 입력해주세요.");
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
