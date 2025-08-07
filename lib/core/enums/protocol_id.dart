import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol_id.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProtocolId {
  @JsonValue("pancake-v4-cl")
  pancakeSwapInfinityCL,
  @JsonValue("aerodrome-v3")
  aerodromeSlipstream,
  unknown;

  bool get isPancakeSwapInfinityCL => this == ProtocolId.pancakeSwapInfinityCL;
  bool get isAerodromeSlipstream => this == ProtocolId.aerodromeSlipstream;

  String get toRawJsonValue => _$ProtocolIdEnumMap[this]!;
}
