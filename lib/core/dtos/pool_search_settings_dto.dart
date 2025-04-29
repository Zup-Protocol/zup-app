import 'package:freezed_annotation/freezed_annotation.dart';

part 'pool_search_settings_dto.freezed.dart';
part 'pool_search_settings_dto.g.dart';

@freezed
class PoolSearchSettingsDto with _$PoolSearchSettingsDto {
  static const num defaultMinLiquidityUSD = 1000;

  @JsonSerializable(explicitToJson: true)
  factory PoolSearchSettingsDto({
    @Default(PoolSearchSettingsDto.defaultMinLiquidityUSD) @JsonKey(name: 'min_liquidity_usd') num minLiquidityUSD,
  }) = _PoolSearchSettingsDto;

  const PoolSearchSettingsDto._();

  bool get isDefault {
    return this == PoolSearchSettingsDto();
  }

  factory PoolSearchSettingsDto.fromJson(Map<String, dynamic> json) => _$PoolSearchSettingsDtoFromJson(json);

  factory PoolSearchSettingsDto.fixture() => PoolSearchSettingsDto(
        minLiquidityUSD: 1200,
      );
}
