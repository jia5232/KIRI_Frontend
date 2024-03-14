import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/member/model/member_model.dart';
import 'package:kiri/member/provider/member_state_notifier_provider.dart';
import 'package:kiri/member/view/signup_screen.dart';
import '../../common/component/custom_text_form_field.dart';
import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/colors.dart';
import '../../common/layout/default_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String email = '';
  String password = '';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memberStateNotifierProvider);

    // 로그인 오류가 났을 경우엔 팝업으로 알림보내기
    if (state is MemberModelError) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        getNoticeDialog(context, state.message);
      });
    }

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
                const SizedBox(height: 16.0),
                Image.asset(
                  'asset/imgs/taxiAndFriends.png',
                  width: MediaQuery.of(context).size.width / 2,
                ),
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
                Container(
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: state is MemberModelLoading //로딩중이면 로그인 버튼 못누르도록
                        ? null
                        : () async {
                            await ref
                                .read(memberStateNotifierProvider.notifier)
                                .login(email: email, password: password);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                    ),
                    child: Text(
                      '로그인',
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                  height: 40.0,
                  child: TextButton(
                    onPressed: state is MemberModelLoading //로딩중이면 회원가입 버튼 못누르도록
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SignupScreen(),
                              ),
                            );
                          },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(PRIMARY_COLOR),
                      side: MaterialStateProperty.all(
                        BorderSide(
                          color: PRIMARY_COLOR,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text('회원가입'),
                  ),
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
