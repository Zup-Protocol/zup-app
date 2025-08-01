import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';

part 'token_list_dto.freezed.dart';
part 'token_list_dto.g.dart';

@freezed
sealed class TokenListDto with _$TokenListDto {
  @JsonSerializable(explicitToJson: true)
  const factory TokenListDto({
    @Default(<TokenGroupDto>[]) List<TokenGroupDto> tokenGroups,
    @Default(<TokenDto>[]) List<TokenDto> popularTokens,
  }) = _TokenListDto;

  factory TokenListDto.fromJson(Map<String, dynamic> json) => _$TokenListDtoFromJson(json);

  factory TokenListDto.fixture() => TokenListDto(
        popularTokens: [
          TokenDto.fixture(),
        ],
        tokenGroups: [
          TokenGroupDto.fixture(),
        ],
      );
}
