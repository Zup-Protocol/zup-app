import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';

class TokensRepository {
  Future<TokenListDto> getTokenList() async {
    await Future.delayed(const Duration(seconds: 4));

    return TokenListDto.fixture().copyWith(userTokens: [
      TokenDto.fixture().copyWith(
        symbol: "ETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
        name: "Ether",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
      ),
      TokenDto.fixture().copyWith(
        symbol: "WETH",
        name: "Wrapped Ether",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "WBTC",
        name: "Wrapped Bitcoin",
        address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "USDT",
        name: "Tether",
        address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "USDC",
        name: "USDC",
        address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "DAI",
        name: "DAI",
        address: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x6B175474E89094C44Da98b954EedeAC495271d0F/logo.png",
      ),
    ], popularTokens: [
      TokenDto.fixture().copyWith(
        symbol: "ETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        name: "Ether",
      ),
      TokenDto.fixture().copyWith(
        symbol: "WETH",
        name: "Wrapped Ether",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "WBTC",
        name: "Wrapped Bitcoin",
        address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "USDT",
        name: "Tether",
        address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "USDC",
        name: "USDC",
        address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "DAI",
        name: "DAI",
        address: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x6B175474E89094C44Da98b954EedeAC495271d0F/logo.png",
      ),
    ], mostUsedTokens: [
      TokenDto.fixture().copyWith(
        symbol: "WETH",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "ETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        name: "Ether",
      ),
      TokenDto.fixture().copyWith(
        symbol: "WBTC",
        address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "USDT",
        address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "USDC",
        name: "USDC",
        address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "DAI",
        address: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x6B175474E89094C44Da98b954EedeAC495271d0F/logo.png",
      ),
    ]);
  }

  Future<List<TokenDto>> searchToken(String query) async {
    await Future.delayed(const Duration(seconds: 4));
    // throw DioException(
    //   requestOptions: RequestOptions(path: "searchToken"),
    //   response: Response(statusCode: 404, requestOptions: RequestOptions(path: "searchToken"), data: null),
    // );

    // throw "any error";

    /// TODO: Cancel previous requests if a new request is made
    return [
      TokenDto.fixture().copyWith(
        symbol: "WETH",
        name: "Wrapped Ether",
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
      ),
      TokenDto.fixture().copyWith(
        symbol: "WBTC",
        name: "Wrapped BTC",
        address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599/logo.png",
      )
    ];
  }
}
