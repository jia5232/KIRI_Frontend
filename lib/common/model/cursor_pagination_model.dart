import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

@JsonSerializable(
  genericArgumentFactories: true, // 제너릭 사용 옵션
)
class CursorPaginationModel<T> { // <T>제너릭 -> CursorPaginationModel을 더 유연하게 사용할 수 있게 해준다.
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPaginationModel({
    required this.meta,
    required this.data,
  });

  // T Function(Object? json) fromJsonT -> json을 T타입으로 받을 수 있게 해준다
  // fromJsonT에는 T로 지정해준 타입의 fromJson함수가 들어간다.
  factory CursorPaginationModel.fromJson(Map<String, dynamic> json, T Function(Object? json) fromJsonT)
  => _$CursorPaginationModelFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta(
    this.count,
    this.hasMore,
  );

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}
