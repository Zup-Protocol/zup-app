import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'token_dto.freezed.dart';
part 'token_dto.g.dart';

@freezed
class TokenDto with _$TokenDto {
  @JsonSerializable(explicitToJson: true)
  const factory TokenDto({
    @JsonKey(name: "id") String? internalId,
    @Default("") String symbol,
    @Default("") String name,
    @Default("") String logoUrl,
    @Default({}) Map<int, String?> addresses,
    @Default(0) int decimals,
  }) = _TokenDto;

  factory TokenDto.fromJson(Map<String, dynamic> json) => _$TokenDtoFromJson(json);

  factory TokenDto.empty() => const TokenDto();

  factory TokenDto.fixture() => TokenDto(
        symbol: 'WETH',
        name: 'Wrapped Ether',
        addresses: Map.fromEntries(
          AppNetworks.values.where((network) => !network.isAllNetworks).map(
            (network) {
              return MapEntry(network.chainId, "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
            },
          ),
        ),
        logoUrl:
            'https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png',
      );
}
