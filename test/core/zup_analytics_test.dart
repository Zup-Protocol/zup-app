import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/zup_analytics.dart';

import '../mocks.dart';

void main() {
  late ZupAnalytics sut;
  late FirebaseAnalytics firebaseAnalytics;

  setUp(() {
    firebaseAnalytics = FirebaseAnalyticsMock();
    sut = ZupAnalytics(firebaseAnalytics);

    when(() => firebaseAnalytics.logEvent(name: any(named: "name"), parameters: any(named: "parameters")))
        .thenAnswer((_) async {});
  });

  test("when calling `logDeposit` it should log the event with the correct name and params", () async {
    final depositedYield = YieldDto.fixture();

    const amount0 = 1.0;
    const amount1 = 2.0;
    const walletAddress = "0x123";

    await sut.logDeposit(
      depositedYield: depositedYield,
      amount0: amount0,
      amount1: amount1,
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
        },
      ),
    ).called(1);
  });

  test("when calling `logSearch` it should log the event with the correct name and params", () async {
    const token0 = "token0";
    const token1 = "token1";
    const network = "network";

    await sut.logSearch(token0: token0, token1: token1, network: network);

    verify(() => firebaseAnalytics.logEvent(name: "user_searched_yields", parameters: {
          "token0_address": "hex:$token0",
          "token1_address": "hex:$token1",
          "network": network,
        })).called(1);
  });

  test("When calling to log any event and it throws, it should not stop the app", () async {
    when(() => firebaseAnalytics.logEvent(name: any(named: "name"), parameters: any(named: "parameters")))
        .thenThrow(Exception());

    await sut.logDeposit(
      depositedYield: YieldDto.fixture(),
      amount0: 1.0,
      amount1: 1.0,
      walletAddress: "0x123",
    );
  });
}
