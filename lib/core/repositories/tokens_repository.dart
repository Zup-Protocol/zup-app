import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/dtos/token_price_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class TokensRepository {
  TokensRepository(this._zupAPIDio);

  final Dio _zupAPIDio;
  bool isSearchingTokens = false;
  CancelToken? _searchTokenLastCancelToken;

  Future<TokenListDto> getTokenList(AppNetworks network) async {
    final request = await _zupAPIDio.get(
      "/tokens/list",
      queryParameters: {if (!network.isAllNetworks) "chainId": int.parse(network.chainInfo.hexChainId)},
    );

    return TokenListDto.fromJson(request.data);
  }

  Future<List<TokenDto>> searchToken(String query, AppNetworks network) async {
    if (_searchTokenLastCancelToken != null) {
      _searchTokenLastCancelToken!.cancel();
    }

    _searchTokenLastCancelToken = CancelToken();

    final response = await _zupAPIDio.get(
      "/tokens/search",
      cancelToken: _searchTokenLastCancelToken,
      queryParameters: {if (!network.isAllNetworks) "chainId": network.chainId, "query": query},
    );

    _searchTokenLastCancelToken = null;
    return (response.data as List<dynamic>).map((token) => TokenDto.fromJson(token)).toList();
  }

  Future<TokenPriceDto> getTokenPrice(String address, AppNetworks network) async {
    final response = await _zupAPIDio.get(
      "/tokens/price",
      queryParameters: {"address": address, "chainId": network.chainId},
    );

    return TokenPriceDto.fromJson(response.data);
  }
}
