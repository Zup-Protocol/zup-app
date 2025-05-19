import 'package:dio/dio.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class YieldRepository {
  YieldRepository(this._zupAPIDio);

  final Dio _zupAPIDio;

  Future<YieldsDto> getSingleNetworkYield({
    required String token0Address,
    required String token1Address,
    required AppNetworks network,
    num? minTvlUsd,
  }) async {
    final response = await _zupAPIDio.get("/pools/search/${network.chainId}", queryParameters: {
      "token0Address": token0Address != EthereumConstants.zeroAddress
          ? token0Address
          : network.wrappedNative.addresses[network.chainId]!,
      "token1Address": token1Address != EthereumConstants.zeroAddress
          ? token1Address
          : network.wrappedNative.addresses[network.chainId]!,
      if (minTvlUsd != null) "minTvlUsd": minTvlUsd
    });

    return YieldsDto.fromJson(response.data);
  }

  Future<YieldsDto> getAllNetworksYield(
      {required String token0InternalId,
      required String token1InternalId,
      num? minTvlUsd,
      bool testnetMode = false}) async {
    final response = await _zupAPIDio.get("/pools/search/all", queryParameters: {
      "token0Id": token0InternalId,
      "token1Id": token1InternalId,
      "testnetMode": testnetMode,
      if (minTvlUsd != null) "minTvlUsd": minTvlUsd,
    });

    return YieldsDto.fromJson(response.data);
  }
}
