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

  factory YieldsDto.fixture() => const YieldsDto(
        last24Yields: [
          YieldDto(
            token0: TokenDto(
              address: "0x02a3e7E0480B668bD46b42852C58363F93e3bA5C",
              decimals: 6,
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4/logo.png",
              name: "USDC",
              symbol: "USDC",
            ),
            token1: TokenDto(
              address: "0x5300000000000000000000000000000000000004",
              decimals: 18,
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x5300000000000000000000000000000000000004/logo.png",
              name: "Wrapped Ether",
              symbol: "WETH",
            ),
            network: Networks.scrollSepolia,
            poolAddress: "0x85AC4aA771827e806bd9b9CDdd379eB4dD0071C2",
            tickSpacing: 200,
            yearlyYield: 1732.42,
            protocol: ProtocolDto(
              name: "PancakeSwap",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/exchange.pancakeswap.finance.png",
            ),
          ),
        ],
        last30dYields: [
          YieldDto(
            token0: TokenDto(
              address: "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238",
              decimals: 6,
              name: "USDC",
              symbol: "USDC",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
            ),
            token1: TokenDto(
              decimals: 18,
              name: "Wrapped Ether",
              symbol: "WETH",
              address: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
            ),
            positionManagerAddress: "0x1238536071E1c677A632429e3655c799b22cDA52",
            network: Networks.sepolia,
            poolAddress: "0xFeEd501c2B21D315F04946F85fC6416B640240b5",
            tickSpacing: 1,
            feeTier: 100,
            yearlyYield: 143.76,
            yieldTimeFrame: YieldTimeFrame.month,
            protocol: ProtocolDto(
              name: "Uniswap",
              logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
            ),
          )
        ],
        last90dYields: [
          YieldDto(
            token0: TokenDto(
              address: "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238",
              decimals: 6,
              name: "USDC",
              symbol: "USDC",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
            ),
            token1: TokenDto(
              decimals: 18,
              name: "Wrapped Ether",
              symbol: "WETH",
              address: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
              logoUrl:
                  "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
            ),
            network: Networks.sepolia,
            poolAddress: "0xFeEd501c2B21D315F04946F85fC6416B640240b5",
            protocol: ProtocolDto(
              name: "Uniswap",
              logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
            ),
            tickSpacing: 1,
            yearlyYield: 21.4,
            yieldTimeFrame: YieldTimeFrame.threeMonth,
          )
        ],
      );
}
