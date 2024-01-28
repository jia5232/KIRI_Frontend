import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/http.dart';

import '../model/post_model.dart';

part 'post_repository.g.dart';

@RestApi()
abstract class PostRepository {
  //Repository 클래스는 무조건 abstract로 선언한다.
  //http://$ip/posts
  factory PostRepository(Dio dio, {String baseUrl}) = _PostRepository;

  // @GET('/')
  // paginate(
  //     @Query('lastPostId') int lastPostId,
  //     @Query('isFromSchool') bool isFromSchool,
  //     @Query('searchKeyword') String? searchKeyword,
  //     );

  @GET('/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<PostModel> getPostDetail({
    @Path() required int id,
  });
}
