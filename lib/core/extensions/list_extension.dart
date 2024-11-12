import 'package:zup_app/core/dtos/yield_dto.dart';

extension YieldDTOListExtension on List<YieldDto> {
  YieldDto get bestYield {
    final yieldListClone = List.from(this);

    yieldListClone.sort((a, b) => b.yearlyYield.compareTo(a.yearlyYield));
    return yieldListClone.first;
  }
}
