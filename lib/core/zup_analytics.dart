import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';

class ZupAnalytics {
  ZupAnalytics(this.firebaseAnalytics, this.tokensRepository);

  final FirebaseAnalytics firebaseAnalytics;
  final TokensRepository tokensRepository;

  Future<void> _log(String name, Map<String, dynamic>? parameters) async {
    try {
      await firebaseAnalytics.logEvent(
        name: name,
        parameters: {
          ...?parameters,
        },
      );

      debugPrint("ZupAnalytics: Event $name logged with parameters $parameters");
    } catch (e, stacktraces) {
      debugPrint(
        "ZupAnalytics: An error ocurred logging event $name, with parameters $parameters, error: $e, stacktrace: $stacktraces",
      );
    }
  }

  Future<void> logDeposit({
    required YieldDto depositedYield,
    required num amount0Formatted,
    required num amount1Formatted,
    required String walletAddress,
  }) async {
    try {
      final tokensPrice = await Future.wait([
        tokensRepository.getTokenPrice(
          depositedYield.token0.addresses[depositedYield.network.chainId]!,
          depositedYield.network,
        ),
        tokensRepository.getTokenPrice(
          depositedYield.token1.addresses[depositedYield.network.chainId]!,
          depositedYield.network,
        )
      ]);

      final amount0UsdDeposited = amount0Formatted * tokensPrice[0].usdPrice;
      final amount1UsdDeposited = amount1Formatted * tokensPrice[1].usdPrice;
      final usdAmountDeposited = amount0UsdDeposited + amount1UsdDeposited;

      await _log(
        "user_deposited",
        {
          "token0_address": "hex:${depositedYield.token0.addresses[depositedYield.network.chainId]!}",
          "token1_address": "hex:${depositedYield.token1.addresses[depositedYield.network.chainId]!}",
          "amount0": amount0Formatted,
          "amount1": amount1Formatted,
          "amount_usd": usdAmountDeposited,
          "network": depositedYield.network.label,
          "wallet_address": "hex:$walletAddress",
          "pool_address": "hex:${depositedYield.poolAddress}",
          "protocol_name": depositedYield.protocol.name,
        },
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> logSearch({
    required String? token0,
    required String? token1,
    required String? group0,
    required String? group1,
    required String network,
  }) async {
    await _log(
      "user_searched_yields",
      {
        "token0": "id:$token0",
        "token1": "id:$token1",
        "group0": "id:$group0",
        "group1": "id:$group1",
        "network": network,
      },
    );
  }
}
