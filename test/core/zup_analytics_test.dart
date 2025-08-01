import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/token_price_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/zup_analytics.dart';

import '../mocks.dart';

void main() {
  late ZupAnalytics sut;
  late FirebaseAnalytics firebaseAnalytics;
  late TokensRepository tokensRepository;

  setUp(() {
    registerFallbackValue(AppNetworks.sepolia);

    firebaseAnalytics = FirebaseAnalyticsMock();
    tokensRepository = TokensRepositoryMock();
    sut = ZupAnalytics(firebaseAnalytics, tokensRepository);

    when(
      () => firebaseAnalytics.logEvent(
        name: any(named: "name"),
        parameters: any(named: "parameters"),
      ),
    ).thenAnswer((_) async {});
  });

  test("when calling `logDeposit` it should log the event with the correct name and params", () async {
    final depositedYield = YieldDto.fixture();

    const amount0 = 1.0;
    const amount1 = 2.0;
    const walletAddress = "0x123";
    final token0Price = TokenPriceDto.fixture().copyWith(usdPrice: 2100);
    final token1Price = TokenPriceDto.fixture().copyWith(usdPrice: 21);

    when(
      () => tokensRepository.getTokenPrice(depositedYield.token0.addresses[depositedYield.network.chainId]!, any()),
    ).thenAnswer((_) async => token0Price);
    when(
      () => tokensRepository.getTokenPrice(depositedYield.token1.addresses[depositedYield.network.chainId]!, any()),
    ).thenAnswer((_) async => token1Price);

    await sut.logDeposit(
      depositedYield: depositedYield,
      amount0Formatted: amount0,
      amount1Formatted: amount1,
      walletAddress: walletAddress,
    );

    verify(
      () => firebaseAnalytics.logEvent(
        name: "user_deposited",
        parameters: {
          "token0_address": "hex:${depositedYield.token0.addresses[depositedYield.network.chainId]!}",
          "token1_address": "hex:${depositedYield.token1.addresses[depositedYield.network.chainId]!}",
          "amount0": amount0,
          "amount1": amount1,
          "network": depositedYield.network.label,
          "wallet_address": "hex:$walletAddress",
          "pool_address": "hex:${depositedYield.poolAddress}",
          "protocol_name": depositedYield.protocol.name,
          "amount_usd": (amount0 * token0Price.usdPrice) + (amount1 * token1Price.usdPrice),
        },
      ),
    ).called(1);
  });

  test("when calling `logSearch` it should log the event with the correct name and params", () async {
    const token0 = "token0";
    const token1 = "token1";
    const group0 = "group0";
    const group1 = "group1";
    const network = "network";

    await sut.logSearch(token0: token0, token1: token1, network: network, group0: group0, group1: group1);

    verify(
      () => firebaseAnalytics.logEvent(
        name: "user_searched_yields",
        parameters: {
          "token0": "id:$token0",
          "token1": "id:$token1",
          "group0": "id:$group0",
          "group1": "id:$group1",
          "network": network,
        },
      ),
    ).called(1);
  });

  test("When calling to log any event and it throws, it should not stop the app", () async {
    when(
      () => firebaseAnalytics.logEvent(
        name: any(named: "name"),
        parameters: any(named: "parameters"),
      ),
    ).thenThrow(Exception());

    await sut.logDeposit(
      depositedYield: YieldDto.fixture(),
      amount0Formatted: 1.0,
      amount1Formatted: 1.0,
      walletAddress: "0x123",
    );
  });
}
