import 'package:zup_app/core/dtos/position_dto.dart';

class PositionsRepository {
  Future<List<PositionDto>> fetchUserPositions() async {
    await Future.delayed(const Duration(seconds: 2));
    return [];
  }
}
