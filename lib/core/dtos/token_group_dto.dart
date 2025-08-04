import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/app_environment.dart';

part 'token_group_dto.freezed.dart';
part 'token_group_dto.g.dart';

@freezed
sealed class TokenGroupDto with _$TokenGroupDto {
  const TokenGroupDto._();

  @JsonSerializable(explicitToJson: true)
  const factory TokenGroupDto({
    @Default("") String id,
    @Default("") String name,
    @Default(<TokenDto>[]) List<TokenDto> tokens,
  }) = _TokenGroupDto;

  String get logoUrl => "${AppEnvironment.current.apiUrl}/static/group-icons/$id.png";

  factory TokenGroupDto.fromJson(Map<String, dynamic> json) => _$TokenGroupDtoFromJson(json);

  factory TokenGroupDto.fixture() =>
      TokenGroupDto(id: "usd-stablecoins-group", name: "USD Stablecoins", tokens: [TokenDto.fixture()]);
}
