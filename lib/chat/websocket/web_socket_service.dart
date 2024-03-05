import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiri/chat/model/message_request_model.dart';
import 'package:kiri/chat/provider/chat_history_provider.dart';
import 'package:kiri/common/const/data.dart';
import 'package:kiri/common/dio/secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../member/provider/member_state_notifier_provider.dart';
import '../model/message_response_model.dart';

final chatRoomIdProvider =
    StateProvider<int>((ref) => 1); //채팅방 ID를 관리하는 Provider

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final storage = ref.read(secureStorageProvider);
  return WebSocketService(
    storage: storage,
    ref: ref,
  );
});

class WebSocketService {
  StompClient? stompClient;
  final FlutterSecureStorage storage;
  final Ref ref;
  dynamic unsubscribeFn; //구독 해제 함수를 저장!!
  Set<String> receivedMessageIds = Set(); // 수신된 메시지 ID를 저장

  // 메시지 수신 시 실행할 콜백 함수
  void Function(MessageResponseModel message)? onMessageReceivedCallback;

  WebSocketService({
    this.stompClient,
    required this.storage,
    required this.ref,
    this.unsubscribeFn,
  });

  // 콜백 함수를 설정하는 메서드
  void setOnMessageReceivedCallback(void Function(MessageResponseModel message) callback) {
    onMessageReceivedCallback = callback;
  }

  void connect(int chatRoomId) async {
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
    print(accessToken);
    ref.read(chatRoomIdProvider.notifier).state = chatRoomId;
    print("connect!!");

    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://$ip/ws-stomp',
        onConnect: (frame) => onConnectCallback(frame),
        beforeConnect: () async {
          print('연결중...');
          await Future.delayed(Duration(seconds: 1));
        },
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        onWebSocketError: (dynamic error) {
          print(error.toString());
          if (error.toString().contains("토큰이 만료되었습니다.")) {
            refreshTokenAndReconnect();
          }
        },
      ),
    );
    stompClient?.activate();
  }

  void onConnectCallback(StompFrame frame) {
    print("Connected to WebSocket server");

    var chatRoomId = ref.read(chatRoomIdProvider.notifier).state;

    // 채팅방에 입장하자마자 구독 시작
    unsubscribeFn = stompClient?.subscribe(
      destination: '/sub/chatroom/$chatRoomId',
      callback: (frame) {
        // 채팅방으로부터 메시지 받음
        if (frame.body != null) {
          print("Received: ${frame.body}");
          final Map<String, dynamic> messageJson = jsonDecode(frame.body!);
          final MessageResponseModel message = MessageResponseModel.fromJson(messageJson);

          if (!receivedMessageIds.contains(message.id.toString())) {
            receivedMessageIds.add(message.id.toString()); // 메시지 ID 저장
            onMessageReceivedCallback?.call(message);
            ref.read(chatHistoryProvider.notifier).addNewMessage(message);
          } else {
            print("중복된 메시지 -> 상태관리 추가 x: ${message.id}");
          }
        }
      },
    );
  }

  void sendMessage(int chatRoomId, String content) {
    final messageRequestModel = MessageRequestModel(
      chatRoomId: chatRoomId,
      content: content,
    );

    final messageJson = jsonEncode(messageRequestModel.toJson());
    print(messageJson.toString());

    stompClient?.send(
      destination: '/pub/chat/message',
      body: messageJson,
    );
  }

  Future<void> refreshTokenAndReconnect() async {
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    print(refreshToken);

    Dio dio = Dio();

    try {
      final resp = await dio.post(
        'http://$ip/token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      // 새로 받아온 accessToken, refreshToken을 스토리지에 저장
      final refreshTokenArray = resp.data['refreshToken'];
      final accessTokenArray = resp.data['accessToken'];

      final newRefreshToken = refreshTokenArray != null
          ? refreshTokenArray!.substring("Bearer ".length)
          : null;
      final newAccessToken = accessTokenArray != null
          ? accessTokenArray!.substring("Bearer ".length)
          : null;

      print('받은 refreshToken: $newRefreshToken');
      print('받은 accessToken: $newAccessToken');

      if (newRefreshToken == null || newAccessToken == null) {
        print("token null!!!");
      }

      await storage.write(key: REFRESH_TOKEN_KEY, value: newRefreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: newAccessToken);
    } on DioException catch (e) {
      print(e.toString());
      print("refreshToken이 만료되었습니다!");
      ref.read(memberStateNotifierProvider.notifier).logout();
    }
    stompClient?.deactivate();

    var chatRoomId = ref.read(chatRoomIdProvider.notifier).state;
    connect(chatRoomId);
  }

  void disconnect() {
    // 구독 해제
    if(unsubscribeFn != null){
      unsubscribeFn(); // 구독해제 함수 호출
      unsubscribeFn = null;
    }
    stompClient?.deactivate();
  }
}
