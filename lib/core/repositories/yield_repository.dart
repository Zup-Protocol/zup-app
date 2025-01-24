import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class YieldRepository {
  YieldRepository(this._zupAPIDio);

  final Dio _zupAPIDio;

  Future<YieldsDto> getYields({
    required String token0Address,
    required String token1Address,
    required Networks network,
  }) async {
    final response = await _zupAPIDio.get(
        // "/pools?token0=$token0Address&token1=$token1Address&network=${network.name}",
        "/pools?token0=0x1c7d4b196cb0c7b01d743fbc6116a902379c7238&token1=0xfff9976782d46cc05630d1f6ebab18b2324d6b14&network=sepolia",
        options: Options());

    return YieldsDto.fromJson(response.data["bestYields"]);
  }
}
