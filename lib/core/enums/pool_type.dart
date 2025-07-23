import 'package:freezed_annotation/freezed_annotation.dart';

enum PoolType {
  @JsonValue("V3")
  v3,
  @JsonValue("V4")
  v4,
  unknown;

  bool get isV3 => this == PoolType.v3;
  bool get isV4 => this == PoolType.v4;

  String get label => switch (this) {
        PoolType.v3 => "V3",
        PoolType.v4 => "V4",
        PoolType.unknown => "Unknown",
      };
}
