import 'package:flutter_test/flutter_test.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';

void main() {
  test("When calling `isToken0Native` and the token0 address in the yield network is zero, it should return true", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
          )
          .isToken0Native,
      true,
    );
  });

  test("When calling `isToken1Native` and the token1 address in the yield network is zero, it should return true", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
          )
          .isToken1Native,
      true,
    );
  });

  test("When calling `isToken0Native` and the token0 address in the yield network is not, it should return false", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}),
          )
          .isToken0Native,
      false,
    );
  });

  test("When calling `isToken1Native` and the token1 address in the yield network is not, it should return false", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
            chainId: network.chainId,
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}),
          )
          .isToken1Native,
      false,
    );
  });

  test("When calling 'yieldTimeframed' passing a 24h timeframe, it should get the 24h yield", () {
    const yield24h = 261782;
    final currentYield = YieldDto.fixture().copyWith(yield24h: yield24h);

    expect(currentYield.yieldTimeframed(YieldTimeFrame.day), yield24h);
  });

  test("When calling 'yieldTimeframed' passing a 7d timeframe, it should get the 90d yield", () {
    const yield7d = 819028190;
    final currentYield = YieldDto.fixture().copyWith(yield7d: yield7d);

    expect(currentYield.yieldTimeframed(YieldTimeFrame.week), yield7d);
  });

  test("When calling 'yieldTimeframed' passing a 30d timeframe, it should get the 90d yield", () {
    const yield30d = 8.9787678;
    final currentYield = YieldDto.fixture().copyWith(yield30d: yield30d);

    expect(currentYield.yieldTimeframed(YieldTimeFrame.month), yield30d);
  });

  test("When calling 'yieldTimeframed' passing a 90d timeframe, it should get the 90d yield", () {
    const yield90d = 12718728.222;
    final currentYield = YieldDto.fixture().copyWith(yield90d: yield90d);

    expect(currentYield.yieldTimeframed(YieldTimeFrame.threeMonth), yield90d);
  });

  test("When building the yield dto with default variables, the deployerAddress should be zero address by default", () {
    expect(
      YieldDto(
        token0: TokenDto.fixture(),
        token1: TokenDto.fixture(),
        poolAddress: "0x1",
        chainId: AppNetworks.sepolia.chainId,
        positionManagerAddress: "0x2",
        tickSpacing: 1,
        protocol: ProtocolDto.fixture(),
        initialFeeTier: 0,
        currentFeeTier: 0,
      ).deployerAddress,
      EthereumConstants.zeroAddress,
    );
  });

  test("When building the yield dto with default variables, the hooks should be zero address by default", () {
    expect(
      YieldDto(
        token0: TokenDto.fixture(),
        token1: TokenDto.fixture(),
        poolAddress: "0x1",
        chainId: AppNetworks.sepolia.chainId,
        positionManagerAddress: "0x2",
        tickSpacing: 1,
        protocol: ProtocolDto.fixture(),
        initialFeeTier: 0,
        currentFeeTier: 0,
      ).v4Hooks,
      EthereumConstants.zeroAddress,
    );
  });

  test(
    """When using 'timeframedYieldFormatted' passing day timeframe,
    and the 24h yield is not zero it should return me the formatted
    24h yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield24h: 2.3213);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.day), "2.3%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing week timeframe,
    and the 7d yield is not zero it should return me the formatted
    7d yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield7d: 121.335);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.week), "121.3%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing month timeframe,
    and the 30d yield is not zero it should return me the formatted
    30d yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield30d: 11.335);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.month), "11.3%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing a three month timeframe,
    and the 90d yield is not zero it should return me the formatted
    90d yield with percent sign""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield90d: 99.87);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.threeMonth), "99.9%");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing day timeframe,
    and the 24h yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield24h: 0);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.day), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing week timeframe,
    and the 7d yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield7d: 0);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.week), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing month timeframe,
    and the 30d yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield30d: 0);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.month), "-");
    },
  );

  test(
    """When using 'timeframedYieldFormatted' passing three months
    timeframe, and the 90d yield is zero it should return me just a hyphen""",
    () {
      final yieldDto = YieldDto.fixture().copyWith(yield90d: 0);
      expect(yieldDto.timeframedYieldFormatted(YieldTimeFrame.threeMonth), "-");
    },
  );
}
