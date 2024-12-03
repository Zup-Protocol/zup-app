import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/token_dto.dart';

part 'token_list_dto.freezed.dart';
part 'token_list_dto.g.dart';

@freezed
class TokenListDto with _$TokenListDto {
  const TokenListDto._();

  @JsonSerializable(explicitToJson: true)
  const factory TokenListDto({
    @Default(<TokenDto>[]) @JsonKey(name: "most_used_tokens") List<TokenDto> mostUsedTokens,
    @Default(<TokenDto>[]) @JsonKey(name: "user_tokens") List<TokenDto> userTokens,
    @Default(<TokenDto>[]) @JsonKey(name: "popular_tokens") List<TokenDto> popularTokens,
  }) = _TokenListDto;

  factory TokenListDto.fromJson(Map<String, dynamic> json) => _$TokenListDtoFromJson(json);

  factory TokenListDto.empty() => const TokenListDto(
        mostUsedTokens: [],
        userTokens: [],
        popularTokens: [],
      );

  factory TokenListDto.fixture() => TokenListDto(
        mostUsedTokens: [
          TokenDto.fixture(),
          TokenDto.fixture(),
          TokenDto.fixture(),
          TokenDto.fixture(),
          TokenDto.fixture(),
          TokenDto.fixture(),
        ],
        userTokens: [
          TokenDto.fixture().copyWith(),
        ],
        popularTokens: [
          TokenDto.fixture(),
        ],
      );
}
