import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiri/common/const/colors.dart';
import 'package:kiri/common/layout/default_layout.dart';

class PostFormScreen extends StatefulWidget {
  //

  const PostFormScreen({super.key});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  // toggle button을 위한 정보
  bool fromSchool = true; //학교에서 출발
  bool toSchool = false; //학교로 도착
  late List<bool> isSelected;

  // time picker를 위한 정보
  DateTime selectedDateTime = DateTime.now();

  bool isFromSchool = true;
  String? station = '보문역';
  DateTime departTime = DateTime.now();
  int cost = 0;
  int maxMember = 0;
  int nowMember = 1; //고정

  @override
  void initState() {
    super.initState();
    isSelected = [fromSchool, toSchool];
  }

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
    });
  }

  void _showCupertinoDateTimePicker(BuildContext context) {
    final DateTime now = DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime:
                selectedDateTime.isBefore(now) ? now : selectedDateTime,
            minimumDate: now, // 최소 시간을 현재 시간으로 설정
            maximumDate: now.add(Duration(days: 1)), // 최대 하루 뒤까지 선택 가능하도록 설정
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                selectedDateTime = newDateTime;
                departTime = newDateTime;
              });
            },
            use24hFormat: true, // 24시간 형식을 사용합니다.
            minuteInterval: 1,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameTextStyle = TextStyle(
      fontSize: 18.0,
    );

    //TextFormField border style!!
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.black,
        width: 1.0,
      ),
    );

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Column(
              children: [
                _Top(),
                SizedBox(height: 20),
                _Notification(),
                SizedBox(height: 20),
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
                  borderRadius: BorderRadius.circular(10.0),
                  borderWidth: 1,
                  selectedBorderColor: Colors.black,
                  fillColor: Colors.transparent,
                  renderBorder: true,
                  constraints: BoxConstraints.expand(
                    width: MediaQuery.of(context).size.width / 2 - 34,
                    height: 40,
                  ),
                  textStyle: TextStyle(fontSize: 18.0),
                  selectedColor: Colors.black,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '도착 / 출발역',
                            style: nameTextStyle,
                          ),
                          SizedBox(width: 40),
                          SizedBox(
                            width: 180.0,
                            child: TextButton(
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey[200]),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // Adjust the border radius here
                                  ),
                                ),
                              ),
                              onPressed: () {},
                              child: Text("선택하기"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '예상 출발시간',
                            style: nameTextStyle,
                          ),
                          SizedBox(width: 34),
                          Container(
                            decoration: BoxDecoration(
                              border: BorderDirectional(
                                top: BorderSide(color: Colors.black),
                                start: BorderSide(color: Colors.black),
                                bottom: BorderSide(color: Colors.black),
                                end:
                                    BorderSide(color: Colors.black, width: 0.0),
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                              ),
                            ),
                            width: 120,
                            height: 36,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 0, 0),
                              child: Text(
                                '${selectedDateTime.month.toString().padLeft(2, '0')}월 ${selectedDateTime.day.toString().padLeft(2, '0')}일 '
                                '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: TextButton(
                              onPressed: () {
                                _showCupertinoDateTimePicker(context);
                              },
                              child: Text('선택'),
                              style: ButtonStyle(
                                side: MaterialStateProperty.all(
                                  BorderSide(
                                    color: Colors.black,
                                    width: 1.0,
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.grey[200]),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '예상 출발시간 5분 전까지는 한 장소에 인원을 모으는 것이 좋습니다.',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '예상 소요금액',
                            style: nameTextStyle,
                          ),
                          SizedBox(width: 34),
                          SizedBox(
                            width: 180,
                            height: 38,
                            child: TextFormField(
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                cost = value.isNotEmpty ? int.parse(value!) : 0;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    '원',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                border: baseBorder,
                                enabledBorder: baseBorder,
                                focusedBorder: baseBorder.copyWith(
                                  borderSide: baseBorder.borderSide.copyWith(
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '예상 소요금액은 차량 이용에 필요한 총 비용입니다. (1/N가격 아님)',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '최대 탑승인원',
                            style: nameTextStyle,
                          ),
                          SizedBox(width: 34),
                          SizedBox(
                            width: 180,
                            height: 38,
                            child: TextFormField(
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                maxMember =
                                    value.isNotEmpty ? int.parse(value!) : 0;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(12.0),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text(
                                    '명',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                border: baseBorder,
                                enabledBorder: baseBorder,
                                focusedBorder: baseBorder.copyWith(
                                  borderSide: baseBorder.borderSide.copyWith(
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '중형택시 기준 최대 탑승 인원은 운전자 제외 4명입니다. (3명 권장)',
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 46,
                        child: TextButton(
                          onPressed: () {
                            //posts/create으로 요청 보낼때 header에 accessToken 같이 보내야 됨
                            isFromSchool = fromSchool;
                            String? depart = fromSchool
                                ? "국민대학교"
                                : station; //추후 사용자의 대학교명으로 변경 필요
                            String? arrive = fromSchool ? station : "국민대학교";
                            final formatDepartTime =
                                departTime.toIso8601String();
                            //departTime, cost, maxMember, nowMembwe 이미 설정됨!!
                            print('isFromSchool: $isFromSchool');
                            print('depart: $depart');
                            print('arrive: $arrive');
                            print('formatDepartTime: $formatDepartTime');
                            print('cost: $cost');
                            print('maxMember: $maxMember');
                            print('nowMember: $nowMember');
                          },
                          child: Text(
                            '등록하기',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(
                              BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.grey[200]),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the border radius here
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _Top extends StatefulWidget {
  const _Top({super.key});

  @override
  State<_Top> createState() => _TopState();
}

class _TopState extends State<_Top> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          IconButton(
            icon: Icon(
              Icons.close,
              size: 30.0,
            ),
            color: Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _Notification extends StatelessWidget {
  const _Notification({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14.0,
    );

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius:
            BorderRadius.all(Radius.circular(12.0)), //Dialog 내부 컨테이너의 border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '방장 안내사항',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. 도착지/출발지 및 관련 정보를 정확히 기재해주세요.',
                style: textStyle,
              ),
              SizedBox(height: 8.0),
              Text(
                '2. 약속 시간 5분 전까지는 모두 정해진 장소로 모여주세요.',
                style: textStyle,
              ),
              SizedBox(height: 8.0),
              Text(
                '3. 택시 호출 및 정산은 만나서 진행해주세요.',
                style: textStyle,
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                '4. 학교 웹메일 인증하에 운영되므로 부적절한 사건 발생시 민형사상 처벌을 받을 수 있음에 유의바랍니다.',
                style: textStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
