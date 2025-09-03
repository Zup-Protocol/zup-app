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
    "when calling 'isAerodromeOrVelodromeSlipstream' and the protocol is indeed aerodromeSlipstream, it should return true",
    () {
      expect(ProtocolId.aerodromeSlipstream.isAerodromeOrVelodromeSlipstream, true);
    },
  );

  test(
    "when calling 'isAerodromeOrVelodromeSlipstream' and the protocol is indeed velodromeSlipstream, it should return true",
    () {
      expect(ProtocolId.velodromeSlipstream.isAerodromeOrVelodromeSlipstream, true);
    },
  );

  test(
    "when calling 'isAerodromeOrVelodromeSlipstream' and the protocol is not aerodromeSlipstream or velodromeSlipstream, it should return false",
    () {
      expect(ProtocolId.unknown.isAerodromeOrVelodromeSlipstream, false);
    },
  );

  test(
    "When calling `isPancakeSwapInfinityCL` and the protocol is not pancakeSwapInfinityCL, it should return false",
    () {
      expect(ProtocolId.unknown.isPancakeSwapInfinityCL, false);
    },
  );

  test("when calling `isKittenswapV3` and the protocol is indeed kittenswapV3, it should return true", () {
    expect(ProtocolId.kittenswapV3.isKittenswapV3, true);
  });

  test("when calling `isKittenswapV3` and the protocol is not kittenswapV3, it should return false", () {
    expect(ProtocolId.unknown.isKittenswapV3, false);
  });

  test("When calling `isAlgebra1_2` and the protocol is kittenSwap, it should return true", () {
    expect(ProtocolId.kittenswapV3.isAlgebra1_2, true);
  });

  test("When calling `isAlgebra1_2` and the protocol is gliquid, it should return true", () {
    expect(ProtocolId.gliquidV3.isAlgebra1_2, true);
  });
  test("When calling `isAlgebra1_2` and the protocol is not gliquid or kittenSwap, it should return false", () {
    expect(ProtocolId.pancakeSwapInfinityCL.isAlgebra1_2, false);
  });
}
