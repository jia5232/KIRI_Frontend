import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/component/custom_text_form_field.dart';
import 'package:kiri/common/component/notice_popup_dialog.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/common/provider/dio_provider.dart';

import '../../common/const/data.dart';

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
  bool isEmailAuthenticated = false;
  bool isEmailSend = false;

  bool isPasswordNull = true;
  bool isPasswordDifferent = false;

  bool isNicknameNull = true;
  bool isNicknameDuplicated = true;

  //학교명 검색 기능
  String searchKeyword = "";
  List<String> searchedUniversities = [];
  bool isSearching = false;
  GlobalKey emailFieldKey = GlobalKey();
  double calculatedTopOffset = 0;

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

  void _toggleSuggestionBoxVisibility() {
    final RenderBox? renderBox =
        emailFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero);

    setState(() {
      calculatedTopOffset = offset?.dy ?? 0 + renderBox!.size.height ?? 0;
      isSearching = !isSearching;
    });
  }

  Future<List<String>?> searchUniversities(searchKeyword) async {
    final dio = ref.watch(dioProvider);

    try {
      final response = await dio.get('http://$ip/universities/search',
          queryParameters: {'searchKeyword': searchKeyword});
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map<String>((univ) => univ as String).toList();
      } else {
        getNoticeDialog(context, '대학교 로드 실패');
      }
    } catch (e) {
      print(e);
      getNoticeDialog(context, '대학교 로드 실패');
    }
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _renderTop(),
                    _renderSchoolField(),
                    _renderEmailField(),
                    _renderNicknameField(),
                    _renderPasswordField(),
                    _renderIsAcceptCheckbox(),
                    _renderRegisterButton(),
                  ],
                ),
                Positioned(
                  top: calculatedTopOffset,
                  left: 0,
                  right: 0,
                  child: Visibility(
                    visible: searchedUniversities.isNotEmpty,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchedUniversities.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(searchedUniversities[index]),
                            onTap: () {
                              setState(() {
                                univName = searchedUniversities[index];
                                searchedUniversities.clear();
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderTop() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
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
    );
  }

  Widget _renderSchoolField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('학교 : '),
              SizedBox(width: 4.0),
              Text(
                univName,
              ),
            ],
          ),
          SizedBox(height: 4.0),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3 * 2,
                child: CustomTextFormField(
                  key: emailFieldKey,
                  hintText: '대학교 이름을 검색해주세요.',
                  onChanged: (String value) {
                    setState(() {
                      searchKeyword = value;
                      if (searchKeyword.isEmpty) {
                        searchedUniversities.clear();
                      } else {
                        _toggleSuggestionBoxVisibility();
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                onPressed: () async {
                        if (searchKeyword.isNotEmpty) {
                          setState(() {
                            isSearching = true;
                          });

                          final universities =
                              await searchUniversities(searchKeyword);

                          if (universities != null) {
                            setState(() {
                              searchedUniversities = universities;
                              isSearching = false;
                            });
                          } else {
                            setState(() {
                              isSearching = false;
                            });
                          }
                        }
                      },
                child: Text('검색'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderEmailField() {
    final dio = ref.watch(dioProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이메일'),
          SizedBox(height: 4.0),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 3 * 2,
                child: CustomTextFormField(
                  isInputEnabled: !isEmailSend,
                  hintText: '대학교 이메일을 입력해주세요.',
                  onChanged: (String value) {
                    email = value;
                    setState(() {
                      isEmailNull = email == "" ? true : false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                onPressed: (isEmailNull || isEmailAuthenticated || isEmailSend)
                    ? null
                    : () async {
                        try {
                          final resp = await dio.post(
                            'http://$ip/email',
                            data: {'email': email},
                            options: Options(
                              headers: {'Content-Type': 'application/json'},
                            ),
                          );
                          if (resp.statusCode == 200) {
                            setState(() {
                              isEmailSend = true;
                            });

                            if (resp.data.containsKey('authNumber')) {
                              authNumber = resp.data['authNumber'];
                            } else {
                              getNoticeDialog(context, '알 수 없는 오류가 발생했습니다.');
                            }

                            showDialog(
                              context: context,
                              builder: (context) {
                                return NoticePopupDialog(
                                  message: "인증번호가 전송되었습니다.",
                                  buttonText: "닫기",
                                  onPressed: () {
                                    Navigator.pop(context); // 두 번째 팝업 닫기
                                  },
                                );
                              },
                            );
                          }
                        } on DioException catch (e) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return NoticePopupDialog(
                                message: e.response?.data["message"] ?? "에러 발생",
                                buttonText: "닫기",
                                onPressed: () {
                                  Navigator.pop(context); // 두 번째 팝업 닫기
                                },
                              );
                            },
                          );
                        }
                      },
                child: Text('전송'),
              ),
            ],
          ),
          if (isEmailNull)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '이메일은 빈칸일 수 없습니다.',
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          SizedBox(height: 16.0),
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
                              authNumber == inputAuthNumber ? true : false;
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
        ],
      ),
    );
  }

  Widget _renderNicknameField() {
    final dio = ref.watch(dioProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        try {
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
                        } catch (e) {
                          getNoticeDialog(context, '알 수 없는 오류가 발생했습니다.');
                        }
                      },
                child: Text('확인'),
              ),
            ],
          ),
          if (isNicknameNull) //이메일 검증
            const Text(
              '닉네임은 빈칸일 수 없습니다.',
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderPasswordField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('비밀번호'),
          SizedBox(height: 4.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CustomTextFormField(
              isInputEnabled: true,
              obscureText: true,
              hintText: '비밀번호를 입력해주세요.',
              onChanged: (String value) {
                password = value;
                setState(() {
                  isPasswordDifferent = password == password2 ? false : true;
                  isPasswordNull =
                      (password == '' && password2 == '') ? true : false;
                });
              },
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CustomTextFormField(
              isInputEnabled: true,
              obscureText: true,
              hintText: '비밀번호를 한번 더 입력해주세요.',
              onChanged: (String value) {
                password2 = value;
                setState(() {
                  isPasswordDifferent = password == password2 ? false : true;
                  isPasswordNull =
                      (password == '' && password2 == '') ? true : false;
                });
              },
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
        ],
      ),
    );
  }

  Widget _renderIsAcceptCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Row(
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
    );
  }

  Widget _renderRegisterButton() {
    final dio = ref.watch(dioProvider);

    return ElevatedButton(
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
            isAccept) {
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
            if (resp.statusCode == 200) {
              showDialog(
                context: context,
                builder: (context) {
                  return NoticePopupDialog(
                    message: "회원가입이 완료되었습니다.",
                    buttonText: "닫기",
                    onPressed: () {
                      //Dialog를 닫고 로그인페이지로 나가야 하므로 두번 pop.
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
          } on DioException catch (e) {
            showDialog(
              context: context,
              builder: (context) {
                return NoticePopupDialog(
                  message: e.response?.data["message"] ?? "에러 발생",
                  buttonText: "닫기",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          } catch (e) {
            getNoticeDialog(context, "회원가입에 실패했습니다.");
          }
        } else {
          getNoticeDialog(context, "회원가입에 필요한 정보를 모두 입력해주세요.");
        }
      },
      child: Text('회원가입하기'),
    );
  }
}
