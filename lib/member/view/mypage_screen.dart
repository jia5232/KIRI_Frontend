import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/member/model/member_model.dart';
import 'package:kiri/member/provider/member_state_notifier_provider.dart';

import '../../common/const/colors.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(memberStateNotifierProvider);

    String nickname = "";
    String univName = "";
    String email = "";

    if (memberState is MemberModel) {
      nickname = memberState.nickname;
      univName = memberState.univName;
      email = memberState.email;
    }

    return DefaultLayout(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              _Top(),
              SizedBox(height: 10.0),
              _Title(nickname: nickname),
              SizedBox(height: 20.0),
              _buildAccountInfo(ref, context),
              SizedBox(height: 40.0),
              _buildNoticeInfo(ref, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          width: MediaQuery.of(context).size.width,
          child: Text("계정 정보"),
        ),
        _MenuButton(
          title: "내 정보",
          onPressed: () {
            print("내 정보 Pressed");
          },
          border: Border(
            top: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
          ),
        ),
        _MenuButton(
          title: "내가 작성한 글",
          onPressed: () {
            print("내가 작성한 글 Pressed");
          },
        ),
      ],
    );
  }

  Widget _buildNoticeInfo(WidgetRef ref, BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          width: MediaQuery.of(context).size.width,
          child: Text("이용 안내"),
        ),
        _MenuButton(
          title: "앱 버전",
          onPressed: () {
            print("앱 버전 Pressed");
          },
          border: Border(
            top: BorderSide(color: Colors.grey.shade400),
            bottom: BorderSide(color: Colors.grey.shade400),
            left: BorderSide(color: Colors.transparent),
            right: BorderSide(color: Colors.transparent),
          ),
        ),
        _MenuButton(
          title: "Q&A",
          onPressed: () {
            print("Q&A Pressed");
          },
        ),
        _MenuButton(
          title: "문의하기",
          onPressed: () {
            print("문의하기 Pressed");
          },
        ),
        _MenuButton(
          title: "로그아웃",
          onPressed: () {
            print("로그아웃 Pressed");
          },
        ),
      ],
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '국민끼리',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String nickname;

  const _Title({
    required this.nickname,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '반가워요 $nickname님,',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Text(
            '오늘도 끼리와 좋은 하루 되세요!',
            style: TextStyle(
              fontSize: 16,
              color: BODY_TEXT_COLOR,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Border? border;

  const _MenuButton({
    required this.title,
    required this.onPressed,
    this.border,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          border: border == null
              ? Border(
                  top: BorderSide(color: Colors.transparent),
                  bottom: BorderSide(color: Colors.grey.shade400),
                  left: BorderSide(color: Colors.transparent),
                  right: BorderSide(color: Colors.transparent),
                )
              : border,
        ),
        width: MediaQuery.of(context).size.width,
        height: 60.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 8.0,
              ),
              SizedBox(width: 10.0),
              Text(
                title,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
