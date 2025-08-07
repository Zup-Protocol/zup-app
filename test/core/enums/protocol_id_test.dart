import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/protocol_id.dart';

void main() {
  test(
    "When calling `isPancakeSwapInfinityCL` and the protocol is indeed pancakeSwapInfinityCL, it should return true",
    () {
      expect(ProtocolId.pancakeSwapInfinityCL.isPancakeSwapInfinityCL, true);
    },
  );

  test(
    "when calling 'isAerodromeSlipstream' and the protocol is indeed aerodromeSlipstream, it should return true",
    () {
      expect(ProtocolId.aerodromeSlipstream.isAerodromeSlipstream, true);
    },
  );

  test("when calling 'isAerodromeSlipstream' and the protocol is not aerodromeSlipstream, it should return false", () {
    expect(ProtocolId.unknown.isAerodromeSlipstream, false);
  });

  test(
    "When calling `isPancakeSwapInfinityCL` and the protocol is not pancakeSwapInfinityCL, it should return false",
    () {
      expect(ProtocolId.unknown.isPancakeSwapInfinityCL, false);
    },
  );
}
