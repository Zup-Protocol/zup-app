import 'package:freezed_annotation/freezed_annotation.dart';

enum PoolType {
  @JsonValue("V2")
  v2,
  @JsonValue("V3")
  v3,
  @JsonValue("V4")
  v4;

  bool get isV3 => this == PoolType.v3;
  bool get isV4 => this == PoolType.v4;
  bool get isV2 => this == PoolType.v2;

  String get label => switch (this) {
        PoolType.v3 => "V3",
        PoolType.v4 => "V4",
        PoolType.v2 => "V2",
      };
}
