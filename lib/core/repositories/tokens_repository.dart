import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class TokensRepository {
  TokensRepository(this._zupAPIDio);

  final Dio _zupAPIDio;
  bool isSearchingTokens = false;
  CancelToken? _searchTokenLastCancelToken;

  Future<TokenListDto> getTokenList(Networks network, {String? userAddress}) async {
    final request = await _zupAPIDio.get(
      "/tokens",
      queryParameters: {
        "network": network.name,
        if (userAddress != null) "userAddress": userAddress,
      },
    );

    return TokenListDto.fromJson(request.data);
  }

  Future<List<TokenDto>> searchToken(String query, Networks network) async {
    if (_searchTokenLastCancelToken != null) {
      _searchTokenLastCancelToken!.cancel();
    }

    _searchTokenLastCancelToken = CancelToken();

    final response = await _zupAPIDio.get("/tokens/search", cancelToken: _searchTokenLastCancelToken, queryParameters: {
      "network": network.name,
      "query": query,
    });

    _searchTokenLastCancelToken = null;
    return (response.data as List<dynamic>).map((token) => TokenDto.fromJson(token)).toList();
  }
}
