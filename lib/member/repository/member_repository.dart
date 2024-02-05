import 'package:dio/dio.dart' hide Headers;
import 'package:kiri/member/model/member_model.dart';
import 'package:retrofit/http.dart';

part 'member_repository.g.dart';

//http://localhost:8080/member
@RestApi()
abstract class MemberRepository{
  factory MemberRepository(Dio dio, {String baseUrl}) = _MemberRepository;

  @GET('')
  @Headers({
    'accessToken': 'true',
  })
  Future<MemberModel> getMe();
}