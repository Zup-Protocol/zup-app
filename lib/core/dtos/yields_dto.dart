import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'yields_dto.freezed.dart';
part 'yields_dto.g.dart';

@freezed
class YieldsDto with _$YieldsDto {
  const YieldsDto._();

  @JsonSerializable(explicitToJson: true)
  const factory YieldsDto({
    @Default(<YieldDto>[]) @JsonKey(name: '24h_yields') List<YieldDto> last24Yields,
    @Default(<YieldDto>[]) @JsonKey(name: '30d_yields') List<YieldDto> last30dYields,
    @Default(<YieldDto>[]) @JsonKey(name: '90d_yields') List<YieldDto> last90dYields,
  }) = _YieldsDto;

  bool get isEmpty => last24Yields.isEmpty && last30dYields.isEmpty && last90dYields.isEmpty;

  factory YieldsDto.fromJson(Map<String, dynamic> json) => _$YieldsDtoFromJson(json);

  factory YieldsDto.empty() => const YieldsDto(
        last24Yields: [],
        last30dYields: [],
        last90dYields: [],
      );

  factory YieldsDto.fixture() => YieldsDto(
        last24Yields: [
          YieldDto.fixture().copyWith(
            token0: TokenDto.fixture().copyWith(
              symbol: "WETH",
              decimals: 18,
              address: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/assets/0x82aF49447D8a07e3bd95BD0d56f35241523fBab1/logo.png",
            ),
            token1: TokenDto.fixture().copyWith(
              symbol: "USDC",
              decimals: 6,
              address: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/assets/0xaf88d065e77c8cC2239327C5EDb3A432268e5831/logo.png",
            ),
            yearlyYield: 1432,
            network: Networks.arbitrum,
            tickSpacing: 10,
            poolAddress: "0xC6962004f452bE9203591991D15f6b388e09E8D0",
          ),
          YieldDto.fixture().copyWith(yearlyYield: 432.2),
          YieldDto.fixture().copyWith(yearlyYield: 11.4),
          YieldDto.fixture().copyWith(yearlyYield: 64.2),
          YieldDto.fixture().copyWith(yearlyYield: 754.12),
        ],
        last30dYields: [
          YieldDto.fixture().copyWith(
            token0: TokenDto.fixture().copyWith(
              symbol: "USDC",
              address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
              decimals: 6,
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
            ),
            token1: TokenDto.fixture().copyWith(
              symbol: "WETH",
              decimals: 18,
              address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
            ),
            yearlyYield: 9842,
            tickSpacing: 60,
            poolAddress: "0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8",
            network: Networks.ethereum,
            protocol: ProtocolDto.fixture().copyWith(
              name: "PancakeSwap",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/exchange.pancakeswap.finance.png",
            ),
          ),
          YieldDto.fixture().copyWith(yearlyYield: 432.2),
          YieldDto.fixture().copyWith(yearlyYield: 11.4),
          YieldDto.fixture().copyWith(yearlyYield: 64.2),
          YieldDto.fixture().copyWith(yearlyYield: 754.12),
        ],
        last90dYields: [
          YieldDto.fixture().copyWith(
            token0: TokenDto.fixture().copyWith(
              symbol: "WETH",
              decimals: 18,
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/base/assets/0x4200000000000000000000000000000000000006/logo.png",
            ),
            token1: TokenDto.fixture().copyWith(
              symbol: "USDC",
              decimals: 6,
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/base/assets/0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913/logo.png",
            ),
            yearlyYield: 11,
            tickSpacing: 60,
            network: Networks.base,
            poolAddress: "0xd0b53D9277642d899DF5C87A3966A349A798F224",
            protocol: ProtocolDto.fixture().copyWith(
              name: "Aerodrome",
              logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/aerodrome.finance.png",
            ),
          ),
          YieldDto.fixture().copyWith(yearlyYield: 4),
          YieldDto.fixture().copyWith(yearlyYield: 1.2),
          YieldDto.fixture().copyWith(yearlyYield: 0.042),
        ],
      );
}
