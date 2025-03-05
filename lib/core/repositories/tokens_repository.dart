import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class TokensRepository {
  TokensRepository(this._zupAPIDio);

  final Dio _zupAPIDio;

  Future<TokenListDto> getTokenList(Networks network) async {
    final request = await _zupAPIDio.get(
      "/tokens",
      queryParameters: {
        "network": network.name,
      },
    );

    return TokenListDto.fromJson(request.data);
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
