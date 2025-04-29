import 'package:dio/dio.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class YieldRepository {
  YieldRepository(this._zupAPIDio);

  final Dio _zupAPIDio;

  Future<YieldsDto> getYields({
    required String token0Address,
    required String token1Address,
    required Networks network,
    required num minTvlUsd,
  }) async {
    final response = await _zupAPIDio.get("/pools", queryParameters: {
      "token0": token0Address != EthereumConstants.zeroAddress ? token0Address : network.wrappedNative.address,
      "token1": token1Address != EthereumConstants.zeroAddress ? token1Address : network.wrappedNative.address,
      "network": network.name,
      "minTvlUsd": minTvlUsd
    });

    return YieldsDto.fromJson(response.data["bestYields"]);
  }
}
