import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_dto.freezed.dart';
part 'token_dto.g.dart';

@freezed
class TokenDto with _$TokenDto {
  @JsonSerializable(explicitToJson: true)
  const factory TokenDto({
    @Default("") String symbol,
    @Default("") String name,
    @Default("") String address,
    @Default("") @JsonKey(name: 'logo_url') String logoUrl,
    @Default(0) int decimals,
  }) = _TokenDto;

  factory TokenDto.fromJson(Map<String, dynamic> json) => _$TokenDtoFromJson(json);

  factory TokenDto.empty() => const TokenDto();

  factory TokenDto.fixture() => const TokenDto(
        symbol: 'WETH',
        name: 'Wrapped Ether',
        address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
        logoUrl:
            'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png',
      );
}
