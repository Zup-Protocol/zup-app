import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol_id.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProtocolId {
  @JsonValue("pancakeswap-infinity-cl")
  pancakeSwapInfinityCL,
  @JsonValue("aerodrome-v3")
  aerodromeSlipstream,
  @JsonValue("velodrome-v3")
  velodromeSlipstream,
  @JsonValue("gliquid-v3")
  gliquidV3,
  unknown;

  bool get isPancakeSwapInfinityCL => this == ProtocolId.pancakeSwapInfinityCL;
  bool get isAerodromeOrVelodromeSlipstream =>
      (this == ProtocolId.aerodromeSlipstream || this == ProtocolId.velodromeSlipstream);
  bool get isGLiquidV3 => this == ProtocolId.gliquidV3;

  String get toRawJsonValue => _$ProtocolIdEnumMap[this]!;
}
