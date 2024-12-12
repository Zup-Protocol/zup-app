import 'package:zup_app/core/dtos/yields_dto.dart';

class YieldRepository {
  Future<YieldsDto> getYields({required String token0Address, required String token1Address}) async {
    await Future.delayed(const Duration(seconds: 16));

    return YieldsDto.fixture();
  }
}
