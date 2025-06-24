import 'package:flutter_test/flutter_test.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

void main() {
  test("When calling `isToken0Native` and the token0 address in the yield network is zero, it should return true", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(
              chainId: network.chainId,
              token0: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}))
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
              token1: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}))
          .isToken1Native,
      true,
    );
  });

  test("When calling `isToken0Native` and the token0 address in the yield network is not, it should return false", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(chainId: network.chainId, token0: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}))
          .isToken0Native,
      false,
    );
  });

  test("When calling `isToken1Native` and the token1 address in the yield network is not, it should return false", () {
    const network = AppNetworks.sepolia;
    expect(
      YieldDto.fixture()
          .copyWith(chainId: network.chainId, token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}))
          .isToken1Native,
      false,
    );
  });
}
