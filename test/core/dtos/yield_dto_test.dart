import 'package:flutter_test/flutter_test.dart';
import 'package:web3kit/core/ethereum_constants.dart';
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
}
