import 'package:freezed_annotation/freezed_annotation.dart';

enum ProtocolId {
  @JsonValue("pancake-v4-cl")
  pancakeSwapInfinityCL,
  unknown;

  bool get isPancakeSwapInfinityCL => this == ProtocolId.pancakeSwapInfinityCL;
}
