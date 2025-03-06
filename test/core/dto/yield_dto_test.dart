import 'package:flutter_test/flutter_test.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

void main() {
  test("When calling `maybeNativeToken1` with `permitNative` false, it should return the yield token1", () {
    final sut = YieldDto.fixture();
    final token = sut.maybeNativeToken1(permitNative: false);

    expect(token, sut.token1);
  });

  test("When calling `maybeNativeToken0` with `permitNative` false, it should return the yield token0", () {
    final sut = YieldDto.fixture();
    final token = sut.maybeNativeToken0(permitNative: false);

    expect(token, sut.token0);
  });

  test("""When calling `maybeNativeToken1` with `permitNative` true,
      and a token 1 that is not the wrapped native address,
      it should return the yield token1""", () {
    final sut = YieldDto.fixture().copyWith(token1: const TokenDto(address: "0x123"));
    final token = sut.maybeNativeToken1(permitNative: true);

    expect(token, sut.token1);
  });

  test("""When calling `maybeNativeToken0` with `permitNative` true,
      and a token 0 that is not the wrapped native address,
      it should return the yield token0""", () {
    final sut = YieldDto.fixture().copyWith(token0: const TokenDto(address: "0x123"));
    final token = sut.maybeNativeToken0(permitNative: true);

    expect(token, sut.token0);
  });

  test("""When calling `maybeNativeToken1` with `permitNative` true,
      and a token 1 that is the wrapped native address,
      it should return the native token for the yield network""", () {
    const network = Networks.sepolia;
    final sut = YieldDto.fixture().copyWith(
      token1: TokenDto(address: network.wrappedNativeTokenAddress!),
      network: network,
    );

    final token = sut.maybeNativeToken1(permitNative: true);

    expect(
        token,
        TokenDto(
          address: EthereumConstants.zeroAddress,
          decimals: network.chainInfo!.nativeCurrency!.decimals,
          logoUrl: network.chainInfo!.nativeCurrency!.logoUrl,
          symbol: network.chainInfo!.nativeCurrency!.symbol,
          name: network.chainInfo!.nativeCurrency!.name,
        ));
  });

  test("""When calling `maybeNativeToken0` with `permitNative` true,
      and a token 0 that is the wrapped native address,
      it should return the native token for the yield network""", () {
    const network = Networks.sepolia;
    final sut = YieldDto.fixture().copyWith(
      token0: TokenDto(address: network.wrappedNativeTokenAddress!),
      network: network,
    );

    final token = sut.maybeNativeToken0(permitNative: true);

    expect(
        token,
        TokenDto(
          address: EthereumConstants.zeroAddress,
          decimals: network.chainInfo!.nativeCurrency!.decimals,
          logoUrl: network.chainInfo!.nativeCurrency!.logoUrl,
          symbol: network.chainInfo!.nativeCurrency!.symbol,
          name: network.chainInfo!.nativeCurrency!.name,
        ));
  });
}
