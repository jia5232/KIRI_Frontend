import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/common/model/cursor_pagination_model.dart';
import 'package:kiri/common/provider/dio_provider.dart';
import 'package:kiri/post/component/post_popup_dialog.dart';
import 'package:kiri/post/provider/post_repository_provider.dart';
import 'package:kiri/post/provider/post_screen_provider.dart';
import 'package:kiri/post/provider/post_state_notifier_provider.dart';
import 'package:kiri/post/provider/university_short_name_provider.dart';
import 'package:kiri/post/view/post_form_screen.dart';
import 'package:kiri/post/view/post_update_form_screen.dart';
import '../../chat/websocket/web_socket_service.dart';
import '../../common/component/notice_popup_dialog.dart';
import '../../common/const/data.dart';
import '../../member/model/member_model.dart';
import '../../member/provider/member_state_notifier_provider.dart';
import '../component/post_card.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final ScrollController controller = ScrollController();

  void toggleSelect(WidgetRef ref, int value) {
    ref.read(fromSchoolProvider.notifier).state = value == 0;
    ref.read(postStateNotifierProvider.notifier).paginate(forceRefetch: true);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scrollListener);
  }

  void scrollListener() {
    // 현재 위치가 최대 길이보다 조금 덜되는 위치까지 왔다면 새로운 데이터를 추가 요청.
    // 현재 컨트롤러 위치가(controller.offset) 컨트롤러의 최대 크기 - n 보다 크면 요청을 보낸다.
    if (controller.offset > controller.position.maxScrollExtent - 150) {
      ref.read(postStateNotifierProvider.notifier).paginate(
            fetchMore: true,
          );
    }
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

  void noticeBeforeDeleteDialog(BuildContext context, int postId) async {
    showDialog(
      context: context,
      builder: (context) {
        return NoticePopupDialog(
          message: "정말 삭제하시겠습니까?",
          buttonText: "삭제하기",
          onPressed: () async {
            final dio = ref.read(dioProvider);
            try {
              final resp = await dio.delete(
                "http://$ip/posts/$postId",
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    'accessToken': 'true',
                  },
                ),
              );
              if (resp.statusCode == 200) {
                Navigator.pop(context);
                Navigator.pop(context);
                ref.refresh(postStateNotifierProvider);
              }
            } on DioException catch (e) {
              Navigator.pop(context);
              Navigator.pop(context);
              getNoticeDialog(
                context,
                e.response?.data["message"] ?? "에러 발생",
              );
            }
          },
        );
      },
    );
  }

  Future<void> joinChatRoom(int postId) async {
    final dio = ref.read(dioProvider);
    try {
      final resp = await dio.post(
        "http://$ip/chatrooms/join/$postId",
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      if (resp.statusCode == 200) {
        context.goNamed('chat');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(postStateNotifierProvider);
    //postStateNotifierProvider가 postRepository에서 받아온 값을 그대로 돌려주므로 Future builder가 필요없어짐..

    return DefaultLayout(
      child: SafeArea(
        child: Column(
          children: [
            _buildTop(ref, context),
            _buildToggleButton(ref, context),
            _buildTextFormField(ref, context),
            SizedBox(height: 12),
            Expanded(
              child: _buildPostList(data, ref, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop(WidgetRef ref, BuildContext context) {
    final memberState = ref.watch(memberStateNotifierProvider);
    String univName = "";

    if (memberState is MemberModel) {
      univName = memberState.univName; // ex.'국민대학교'
    }

    final univShortNameFuture =
        ref.watch(universityShortNameProvider(univName));

    return univShortNameFuture.when(
      data: (univShortName) => Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$univShortName끼리',
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostFormScreen(),
                  ),
                );
              },
              icon: FaIcon(FontAwesomeIcons.solidPenToSquare),
              label: const Text(
                "내가 방장",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
      loading: () => CircularProgressIndicator(),
      error: (e, stack) => Text('Error: $e'),
    );
  }

  Widget _buildToggleButton(WidgetRef ref, BuildContext context) {
    double borderWidth = 1;

    return ToggleButtons(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('학교에서 출발'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('학교로 도착'),
        ),
      ],
      isSelected: [
        ref.watch(fromSchoolProvider),
        !ref.watch(fromSchoolProvider),
      ],
      onPressed: (value) => toggleSelect(ref, value),
      borderColor: Colors.grey[300],
      borderWidth: borderWidth,
      selectedBorderColor: Colors.black,
      fillColor: Colors.transparent,
      renderBorder: true,
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width / 2 -
            borderWidth * 2, // 화면의 너비를 2로 나누어 각 버튼의 너비를 지정
        height: 40, // 버튼의 높이를 40으로 지정
      ),
      textStyle: TextStyle(fontSize: 18.0),
      selectedColor: Colors.black,
    );
  }

  Widget _buildTextFormField(WidgetRef ref, BuildContext context) {
    bool fromSchool = ref.watch(fromSchoolProvider); //학교에서 출발

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          TextFormField(
            cursorColor: PRIMARY_COLOR,
            decoration: InputDecoration(
              hintText: fromSchool ? '도착지를 입력해주세요.' : '출발지를 입력해주세요.',
              hintStyle: TextStyle(
                color: PRIMARY_COLOR,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.search,
                  size: 30.0,
                ),
                color: PRIMARY_COLOR,
                onPressed: () {
                  ref
                      .read(postStateNotifierProvider.notifier)
                      .paginate(forceRefetch: true);
                },
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                    color: PRIMARY_COLOR,
                    width: 1.5), // Set your color for the border here
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(
                    color: PRIMARY_COLOR,
                    width: 2.5), // Set your color for the border here
              ),
            ),
            onChanged: (String value) {
              ref.read(searchKeywordProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(
      CursorPaginationModelBase data, WidgetRef ref, BuildContext context) {
    final data = ref.watch(postStateNotifierProvider);
    //postStateNotifierProvider가 postRepository에서 받아온 값을 그대로 돌려주므로 Future builder가 필요없어짐..

    if (data is CursorPaginationModelLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: PRIMARY_COLOR,
        ),
      );
    }

    if (data is CursorPaginationModelError) {
      return Center(
        child: Text("데이터를 불러올 수 없습니다."),
      );
    }

    final cp = data as CursorPaginationModel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        controller: controller,
        itemCount: cp.data.length + 1,
        itemBuilder: (_, index) {
          if (index == cp.data.length) {
            return Center(
              child: cp is CursorPaginationModelFetchingMore
                  ? CircularProgressIndicator(
                      color: PRIMARY_COLOR,
                    )
                  : Text(
                      'Copyright 2024. JiaKwon all rights reserved.\n',
                      style: TextStyle(
                        color: BODY_TEXT_COLOR,
                        fontSize: 12.0,
                      ),
                    ),
            );
          }

          final pItem = cp.data[index];

          return GestureDetector(
            child: PostCard.fromModel(postModel: pItem),
            onTap: () async {
              final detailedPostModel = await ref
                  .read(postRepositoryProvider)
                  .getPostDetail(id: pItem.id);
              //getPostDetail에서 api요청해서 가져오고, PostModel로 변환한다. (retrofit)
              // final detailedPostModel = await getPostDetail(ref, pItem.id);
              showDialog(
                context: context,
                builder: (context) {
                  return PostPopupDialog(
                    id: pItem.id,
                    isFromSchool: detailedPostModel.isFromSchool,
                    depart: detailedPostModel.depart,
                    arrive: detailedPostModel.arrive,
                    departTime: detailedPostModel.departTime,
                    maxMember: detailedPostModel.maxMember,
                    nowMember: detailedPostModel.nowMember,
                    cost: detailedPostModel.cost,
                    isAuthor: detailedPostModel.isAuthor,
                    joinOnPressed: () async {
                      //글 작성자면 그냥 이동하도록, 작성자가 아니라면 joinChatRoom()하고 이동하도록
                      final dio = ref.read(dioProvider);
                      try {
                        final resp = await dio.get(
                          'http://$ip/chatrooms/is-joined/${pItem.id}',
                          options: Options(
                            headers: {
                              'accessToken': 'true',
                            },
                          ),
                        );
                        final isMemberJoinedChatRoom = resp.data;
                        if (!isMemberJoinedChatRoom) {
                          //아직 join되지 않은 경우에만 join하도록 -> 인원 초과시 예외처리 추후 필요!
                          await joinChatRoom(pItem.id);

                          //chatRoomId 상태 변경
                          ref.read(chatRoomIdProvider.notifier).state =
                              detailedPostModel.chatRoomId;
                        } else {
                          //이미 join된 경우면 그냥 넘어가도록
                          //chatRoomId 상태 변경
                          ref.read(chatRoomIdProvider.notifier).state =
                              detailedPostModel.chatRoomId;
                          context.goNamed('chat');
                        }
                      } on DioException catch (e) {
                        getNoticeDialog(
                          context,
                          e.response?.data["message"] ?? "에러 발생",
                        );
                      }
                    },
                    deleteOnPressed: () {
                      noticeBeforeDeleteDialog(context, pItem.id);
                    },
                    updateOnPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostUpdateFormScreen(
                            postId: pItem.id,
                            isMypageUpdate: false,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        separatorBuilder: (_, index) {
          return SizedBox(height: 16.0);
        },
      ),
    );
  }
}
