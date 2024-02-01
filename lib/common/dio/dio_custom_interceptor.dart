import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kiri/common/const/data.dart';

class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Dio dio;

  CustomInterceptor(
    this.storage,
    this.dio,
  );

  // 1) 요청을 보낼 때
  // 요청이 보내질때마다 요청 Header에 accessToken: true라는 값이 있다면 실제 토큰을 스토리지에서 가져와서 담아서 보내준다.
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('[REQ] [${options.method}] [${options.uri}]');

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken'); //헤더 삭제

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      options.headers.addAll({
        'Authorization': 'Bearer $token', //실제 토큰으로 대체
      });
    }

    if (options.headers['refreshToken'] == 'true') {
      options.headers.remove('refreshToken'); //헤더 삭제

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      options.headers.addAll({
        'Authorization': 'Bearer $token', //실제 토큰으로 대체
      });
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을 때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '[RES] [${response.requestOptions.method}] [${response.requestOptions.uri}]');
    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을 때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 에러가 났을 때 -> 토큰을 재발급받는 시도를 하고, 토큰이 재발급되면 다시 새로운 토큰으로 요청을 한다.
    print('[ERR] [${err.requestOptions.method}] [${err.requestOptions.uri}]');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken이 아예 없으면 에러를 던진다.
    // 에러를 던질때는 handler.reject를 사용한다.
    if (refreshToken == null) {
      return handler.reject(err);
    }

    final isStatus401 = err.response?.statusCode == 401;

    // 토큰을 새로 발급받으려다가 에러가 난거라면 refreshToken 자체에 문제가 있다!
    final isPathRefresh = err.requestOptions.path == '/token';

    // 토큰 에러가 맞고 새로 발급받으려다가 에러가 난건 아니다. -> 토큰을 새로 발급받으면 된다.
    if (isStatus401 && !isPathRefresh) {
      // final dio = Dio(); //여기가 문제인가...? (postScreen 문제 고치는중)
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
        final refreshTokenArray = resp.headers['refreshToken'];
        final accessTokenArray = resp.headers['accessToken'];

        final newRefreshToken = refreshTokenArray != null
            ? refreshTokenArray[0].substring("Bearer ".length)
            : null;
        final newAccessToken = accessTokenArray != null
            ? accessTokenArray[0].substring("Bearer ".length)
            : null;

        if (newRefreshToken == null || newAccessToken == null) {
          print("token null!!!");
        }

        await storage.write(key: REFRESH_TOKEN_KEY, value: newRefreshToken);
        await storage.write(key: ACCESS_TOKEN_KEY, value: newAccessToken);

        // 원래 시도하던 요청에 대한 재요청을 위해 request header의 옵션을 변경
        final options = err.requestOptions;

        options.headers.addAll({
          'Authorization': 'Bearer $newAccessToken',
        });

        // 요청 재전송 : dio.fetch(options) -> 에러를 발생시킨 요청과 관련된 옵션들을 모두 받아서 토큰만 변경한 후에 다시 요청을 보낸다.
        final response = await dio.fetch(options);

        // 요청 재전송이 성공적으로 끝났으면
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.reject(e);
      }
    }

    return super.onError(err, handler);
  }
}
