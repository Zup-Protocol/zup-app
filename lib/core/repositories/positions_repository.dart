import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';

class PositionsRepository {
  Future<List<PositionDto>> fetchUserPositions() async {
    await Future.delayed(const Duration(seconds: 2));
    return [
      PositionDto.fixture().copyWith(
        network: Networks.ethereum,
        protocol: ProtocolDto.fixture().copyWith(
          name: "PancakeSwap",
          logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/exchange.pancakeswap.finance.png",
        ),
        token0: TokenDto.fixture().copyWith(
          symbol: "WETH",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
        ),
        token1: TokenDto.fixture().copyWith(
          symbol: "USDC",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
        ),
        status: PositionStatus.inRange,
      ),
      PositionDto.fixture().copyWith(
        network: Networks.base,
        protocol: ProtocolDto.fixture().copyWith(
          name: "Velodrome",
          logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/aerodrome.finance.png",
        ),
        token0: TokenDto.fixture().copyWith(
          symbol: "AERO",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/base/assets/0x940181a94A35A4569E4529A3CDfB74e38FD98631/logo.png",
        ),
        token1: TokenDto.fixture().copyWith(
          symbol: "WETH",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/base/assets/0x4200000000000000000000000000000000000006/logo.png",
        ),
        status: PositionStatus.outOfRange,
      ),
      //   PositionDto.fixture().copyWith(
      //     network: Networks.arbitrum,
      //     protocol: ProtocolDto.fixture().copyWith(
      //       name: "Uniswap",
      //       logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
      //     ),
      //     token0: TokenDto.fixture().copyWith(
      //       symbol: "UNI",
      //       logoUrl:
      //           "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/assets/0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0/logo.png",
      //     ),
      //     token1: TokenDto.fixture().copyWith(
      //       symbol: "WBTC",
      //       logoUrl:
      //           "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/assets/0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f/logo.png",
      //     ),
      //     status: PositionStatus.closed,
      //   ),
      //   PositionDto.fixture().copyWith(
      //     protocol: ProtocolDto.fixture().copyWith(
      //       name: "SushiSwap",
      //       logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.sushi.com.png",
      //     ),
      //     token0: TokenDto.empty().copyWith(symbol: "cbBTC"),
      //     token1: TokenDto.fixture().copyWith(
      //       symbol: "cREAL",
      //       logoUrl:
      //           "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/celo/assets/0xe8537a3d056DA446677B9E9d6c5dB704EaAb4787/logo.png",
      //     ),
      //     status: PositionStatus.unknown,
      //   ),
    ];
  }
}
