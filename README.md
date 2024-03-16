# KIRI_Frontend
대학생을 위한 택시 쉐어 플랫폼 "끼리"의 프론트엔드 리포지토리입니다.

## 프로젝트 소개
등하교시 버스나 지하철의 높은 인구 밀도로 
불편을 겪는 대학생들이 택시를 공유하여 </br>1/n 가격으로 저렴하게 이용할 수 있도록 도와주는 모바일 앱 서비스입니다.

## 프로젝트 개발 기간
* 2024.01 ~ 2024.03 (약 7주)

## 개발 인원
* Jia Kwon (개인 프로젝트)

## 프론트엔드 개발 환경
- Dart 3.1.0
- Flutter 3.13.0

## dart packages
- flutter_localizations
- dio: ^5.4.0
- flutter_secure_storage: ^9.0.0
- json_annotation: ^4.8.1
- retrofit: '>=4.0.0 <5.0.0'
- logger: any  #for logging purpose
- flutter_riverpod: ^2.4.10
- font_awesome_flutter: ^10.6.0
- go_router: ^7.0.1
- flutter_email_sender: ^6.0.2
- package_info_plus: ^4.2.0
- web_socket_channel: ^2.4.0
- stomp_dart_client: ^1.0.3

## 인증 로직 시퀀스 다이어그램
* 로그인
<img src="https://github.com/jia5232/KIRI_Backend/assets/83686088/3114dbc9-2cbb-440b-9440-683d96ab1a4a" width="400">
</br>
</br>
* 토큰 재발급
</br>
<img src="https://github.com/jia5232/KIRI_Backend/assets/83686088/f36a8236-b5ac-48f2-9a77-f881817e4fcb" width="400">

## 주요 기능 소개
<img width="202" alt="로그인 페이지" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/02f98abc-bd8d-4b42-8a13-d9648d1050e2">
<img width="202" alt="회원가입 페이지" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/30ce3129-b956-4b73-a71c-eeb3be0a5480">
</br>
* 대학교 이메일을 통해 인증 후 회원가입 및 로그인을 진행하여 서비스를 이용할 수 있습니다.
</br>
* Flutter의 secure storage와 riverpod을 활용해 인증 상태 관리를 구현했습니다.
</br>
</br>
</br>

<img width="202" alt="메인페이지" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/a27a5754-11da-4ee3-9dfb-dc6fcd7f1e5f">
<img width="202" alt="글 작성, 수정 폼" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/4d9aa643-cffd-4204-a89b-94f00b294733">
<img width="200" alt="글 상세" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/ba0e0d91-6275-4231-aa2a-0ac87c52dd29">
</br>
* 출발지 혹은 도착지를 설정하고 출발 시간, 소요 금액, 탑승 인원 등을 기재해 새로운 모임을 개설하거나, 기존에 이미 개설된 모임에 참여할 수 있습니다.
</br>
</br>
* 회원의 대학교에 따라 메인 페이지에 보이는 서비스명이 달라집니다. 
</br>(ex, 국민끼리, 성신끼리, 고려끼리)
</br>
</br>
</br>

<img width="202" alt="채팅방 상세" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/b591c0bb-1ee8-479a-b140-8023b0af9df0">
<img width="202" alt="채팅방 리스트" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/12f20e8b-b09b-4803-9e51-f0ac12ac2998">
</br>
* 모임에 참여하면 채팅을 통해 약속장소를 정하고, 정산을 진행하여 택시를 저렴하게 이용할 수 있습니다.
</br>
* stomp_dart_client 패키지를 활용하여 채팅 기능을 구현했습니다.
</br>
</br>
</br>

<img width="202" alt="마이페이지" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/8110f76c-98c2-4de8-bc55-a791eb6f49c9">
<img width="202" alt="마이페이지 내가쓴글" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/c2914306-3505-4f9a-a007-fcc0df0bd651">
</br>
* 마이페이지에서 회원 정보, 내가 작성한 글, 앱 정보, 문의하기, 로그아웃 등의 기능을 이용할 수 있습니다.
</br>
</br>
</br>

<img width="202" alt="글 작성 예외 1" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/d67f93c2-e66a-4bb5-bdac-ada23111285b">
<img width="202" alt="글 작성 예외 2" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/21d70651-37a6-4b36-a785-37cbc7e80037">
<img width="202" alt="인원초과 예외 처리" src="https://github.com/jia5232/KIRI_Backend/assets/83686088/fcb9ed26-8e79-4366-89cb-f6ec712ee7a3">
</br>
* 서비스 로직상 발생 가능한 예외 상황들을 처리하고 사용자에게 적절한 알림을 보내도록 구현했습니다.
</br>
* dio package가 제공하는 dio exception을 활용하여 예외 처리를 구현하였습니다.
