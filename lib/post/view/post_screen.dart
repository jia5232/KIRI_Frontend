import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/dio/dio.dart';
import 'package:kiri/common/layout/default_layout.dart';
import 'package:kiri/post/component/post_popup_dialog.dart';
import 'package:kiri/post/model/post_model.dart';
import 'package:kiri/post/repository/post_repository.dart';
import 'package:kiri/post/view/post_form_screen.dart';

import '../../common/const/data.dart';
import '../component/post_card.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final ScrollController controller = ScrollController();
  bool fromSchool = true; //학교에서 출발
  bool toSchool = false; //학교로 도착
  late List<bool> isSelected;
  String? searchKeyword = '';

  Future<List<PostModel>> paginatePost(
      int lastPostId, bool isFromSchool, String? searchKeyWord) async {
    final dio = Dio();

    dio.interceptors.add(
        CustomInterceptor(storage),
    );

    final repository = PostRepository(dio, baseUrl: "http://$ip/posts");
    final resp = await repository.paginate(lastPostId, isFromSchool, searchKeyword);

    //resp -> CursorPaginationModel을 받아오므로, 그 중에 data를 리턴해줘야함.
    return resp.data;
  }

  Future<PostModel> getPostDetail(int id) async {
    final dio = Dio();

    dio.interceptors.add(
      CustomInterceptor(storage),
    );

    final repository = PostRepository(dio, baseUrl: "http://$ip/posts");
    return repository.getPostDetail(id: id);
  }

  @override
  void initState() {
    super.initState();
    isSelected = [fromSchool, toSchool];
  }

  // void scrollListener(){
  //
  // }

  void toggleSelect(value) {
    if (value == 0) {
      fromSchool = true;
      toSchool = false;
    } else {
      fromSchool = false;
      toSchool = true;
    }
    setState(() {
      isSelected = [fromSchool, toSchool];
      //pagenate 요청 다시 불러오기
      paginatePost(20, fromSchool, searchKeyword);
    });
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
  Widget build(BuildContext context) {
    double borderWidth = 1;

    return DefaultLayout(
      child: SingleChildScrollView(
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
                isSelected: isSelected,
                onPressed: toggleSelect,
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
                            setState(() {
                              paginatePost(20, fromSchool, searchKeyword);
                            });
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
                        searchKeyword = value;
                      },
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 500,
                      child: FutureBuilder<List<PostModel>>(
                        future: paginatePost(10, fromSchool, searchKeyword),
                        builder: (context, AsyncSnapshot<List<PostModel>> snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              child: Text('no data'),
                            );
                          }

                          return ListView.separated(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) {
                              final pItem = snapshot.data![index];

                              return GestureDetector(
                                child: PostCard.fromModel(postModel: pItem),
                                onTap: () async {
                                  //getPostDetail에서 api요청해서 가져오고, PostModel로 변환한다. (retrofit)
                                  final detailedPostModel =
                                      await getPostDetail(pItem.id);

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

class _Top extends StatefulWidget {
  const _Top({super.key});

  @override
  State<_Top> createState() => _TopState();
}

class _TopState extends State<_Top> {
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
