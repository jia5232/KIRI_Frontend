import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/common/model/cursor_pagination_model.dart';
import 'package:kiri/common/provider/dio_provider.dart';
import 'package:kiri/post/component/post_popup_dialog.dart';
import 'package:kiri/post/model/post_model.dart';
import 'package:kiri/post/provider/post_repository_provider.dart';
import 'package:kiri/post/provider/post_screen_provider.dart';
import 'package:kiri/post/repository/post_repository.dart';
import 'package:kiri/post/view/post_form_screen.dart';

import '../../common/const/data.dart';
import '../component/post_card.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({super.key});

  Future<CursorPaginationModel<PostModel>> paginatePost(WidgetRef ref,
      int lastPostId, bool isFromSchool, String? searchKeyword) async {
    final resp = ref
        .watch(postRepositoryProvider)
        .paginate(lastPostId, isFromSchool, searchKeyword);

    //resp -> CursorPaginationModel을 받아온다.
    return resp;
  }

  Future<PostModel> getPostDetail(WidgetRef ref, int id) async {
    return ref.watch(postRepositoryProvider).getPostDetail(
          id: id,
        );
  }

  // void scrollListener(){
  //
  // }

  void toggleSelect(
      WidgetRef ref, int value, bool fromSchool, String? searchKeyword) {
    if (value == 0) {
      ref.read(fromSchoolProvider.notifier).state = true;
    } else {
      ref.read(fromSchoolProvider.notifier).state = false;
    }
    //pagenate 요청 다시 불러오기!!!!!
    paginatePost(ref, 20, fromSchool, searchKeyword);
  }

  void updateSearchKeyword(WidgetRef ref, String? newKeyword) {
    ref.read(searchKeywordProvider.notifier).state = newKeyword;
  }

  void showPopup(context, id, isFromSchool, depart, arrive, departTime,
      maxMember, nowMember, cost, isAuthor) {
    showDialog(
        context: context,
        builder: (context) {
          return PostPopupDialog(
            id: id,
            isFromSchool: isFromSchool,
            depart: depart,
            arrive: arrive,
            departTime: departTime,
            maxMember: maxMember,
            nowMember: nowMember,
            cost: cost,
            isAuthor: isAuthor,
            joinOnPressed: () {
              print('join button clicked!');
            },
            deleteOnPressed: () {
              print('delete button clicked!');
            },
          );
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController controller = ScrollController();
    bool fromSchool = ref.watch(fromSchoolProvider); //학교에서 출발
    String? searchKeyword = ref.watch(searchKeywordProvider);

    double borderWidth = 1;

    return DefaultLayout(
      child: SingleChildScrollView(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          child: Column(
            children: [
              _Top(),
              ToggleButtons(
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
                onPressed: (value) =>
                    toggleSelect(ref, value, fromSchool, searchKeyword),
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Column(
                  children: [
                    TextFormField(
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
                            paginatePost(ref, 20, fromSchool, searchKeyword);
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
                        updateSearchKeyword(ref, value);
                      },
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 500,
                      child: FutureBuilder<CursorPaginationModel<PostModel>>(
                        future: paginatePost(ref, 10, fromSchool, searchKeyword),
                        builder: (context, AsyncSnapshot<CursorPaginationModel<PostModel>>snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: PRIMARY_COLOR,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: snapshot.data!.data.length,
                            itemBuilder: (_, index) {
                              final pItem = snapshot.data!.data[index];

                              return GestureDetector(
                                child: PostCard.fromModel(postModel: pItem),
                                onTap: () async {
                                  //getPostDetail에서 api요청해서 가져오고, PostModel로 변환한다. (retrofit)
                                  final detailedPostModel =
                                      await getPostDetail(ref, pItem.id);

                                  showPopup(
                                    context,
                                    detailedPostModel.id,
                                    detailedPostModel.isFromSchool,
                                    detailedPostModel.depart,
                                    detailedPostModel.arrive,
                                    detailedPostModel.departTime,
                                    detailedPostModel.maxMember,
                                    detailedPostModel.nowMember,
                                    detailedPostModel.cost,
                                    detailedPostModel.isAuthor,
                                  );
                                },
                              );
                            },
                            separatorBuilder: (_, index) {
                              return SizedBox(height: 16.0);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '국민끼리',
            style: TextStyle(
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
            label: Text(
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
    );
  }
}
