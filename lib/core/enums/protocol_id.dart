import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol_id.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProtocolId {
  @JsonValue("pancake-v4-cl")
  pancakeSwapInfinityCL,
  unknown;

  bool get isPancakeSwapInfinityCL => this == ProtocolId.pancakeSwapInfinityCL;

  String get toRawJsonValue => _$ProtocolIdEnumMap[this]!;
}
