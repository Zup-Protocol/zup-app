import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_by_timeframe_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'yields_dto.freezed.dart';
part 'yields_dto.g.dart';

@freezed
class YieldsDto with _$YieldsDto {
  const YieldsDto._();

  @JsonSerializable(explicitToJson: true)
  const factory YieldsDto({
    @JsonKey(name: "bestYieldsByFrame") required YieldsByTimeframeDto timeframedYields,
  }) = _YieldsDto;

  bool get isEmpty =>
      timeframedYields.best24hYields.isEmpty &&
      timeframedYields.best7dYields.isEmpty &&
      timeframedYields.best30dYields.isEmpty &&
      timeframedYields.best90dYields.isEmpty;

  factory YieldsDto.fromJson(Map<String, dynamic> json) => _$YieldsDtoFromJson(json);

  factory YieldsDto.empty() => YieldsDto(timeframedYields: YieldsByTimeframeDto.empty());

  factory YieldsDto.fixture() => const YieldsDto(
        timeframedYields: YieldsByTimeframeDto(
          best24hYields: [
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
              poolAddress: "0x4040CE732c1A538A4Ac3157FDC35179D73ea76cd",
              tickSpacing: 10,
              yearlyYield: 1732.42,
              feeTier: 500,
              protocol: ProtocolDto(
                name: "PancakeSwap",
                logo:
                    "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/exchange.pancakeswap.finance.png",
              ),
            ),
          ],
          best7dYields: [
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
              tickSpacing: 1,
              feeTier: 100,
              yearlyYield: 143.76,
              protocol: ProtocolDto(
                name: "Uniswap",
                logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
              ),
            )
          ],
          best30dYields: [
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
              tickSpacing: 1,
              feeTier: 100,
              yearlyYield: 143.76,
              protocol: ProtocolDto(
                name: "Uniswap",
                logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
              ),
            )
          ],
          best90dYields: [
            YieldDto(
              feeTier: 100,
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
                logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
              ),
              tickSpacing: 1,
              yearlyYield: 21.4,
            )
          ],
        ),
      );
}
