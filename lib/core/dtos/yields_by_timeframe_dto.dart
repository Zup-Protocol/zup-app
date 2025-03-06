import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';

part 'yields_by_timeframe_dto.freezed.dart';
part 'yields_by_timeframe_dto.g.dart';

@freezed
class YieldsByTimeframeDto with _$YieldsByTimeframeDto {
  @JsonSerializable(explicitToJson: true)
  const factory YieldsByTimeframeDto({
    @JsonKey(name: "bestYield24hs") required List<YieldDto> best24hYields,
    @JsonKey(name: "bestYield7d") required List<YieldDto> best7dYields,
    @JsonKey(name: "bestYield30d") required List<YieldDto> best30dYields,
    @JsonKey(name: "bestYield90d") required List<YieldDto> best90dYields,
  }) = _YieldsByTimeframeDto;

  factory YieldsByTimeframeDto.fromJson(Map<String, dynamic> json) => _$YieldsByTimeframeDtoFromJson(json);

  factory YieldsByTimeframeDto.empty() => const YieldsByTimeframeDto(
        best24hYields: [],
        best7dYields: [],
        best30dYields: [],
        best90dYields: [],
      );

  factory YieldsByTimeframeDto.fixture() => YieldsByTimeframeDto(
        best24hYields: [
          YieldDto.fixture(),
        ],
        best7dYields: [
          YieldDto.fixture(),
        ],
        best30dYields: [
          YieldDto.fixture(),
        ],
        best90dYields: [
          YieldDto.fixture(),
        ],
      );
}
