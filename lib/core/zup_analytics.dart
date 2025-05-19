import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';

class ZupAnalytics {
  ZupAnalytics(this.firebaseAnalytics);

  final FirebaseAnalytics firebaseAnalytics;

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
    required num amount0,
    required num amount1,
    required String walletAddress,
  }) async {
    await _log(
      "user_deposited",
      {
        "token0_address": "hex:${depositedYield.token0.addresses[depositedYield.network.chainId]!}",
        "token1_address": "hex:${depositedYield.token1.addresses[depositedYield.network.chainId]!}",
        "amount0": amount0,
        "amount1": amount1,
        "network": depositedYield.network.label,
        "wallet_address": "hex:$walletAddress",
        "pool_address": "hex:${depositedYield.poolAddress}",
        "protocol_name": depositedYield.protocol.name,
      },
    );
  }

  Future<void> logSearch({
    required String token0,
    required String token1,
    required String network,
  }) async {
    await _log(
      "user_searched_yields",
      {
        "token0_address": "hex:$token0",
        "token1_address": "hex:$token1",
        "network": network,
      },
    );
  }
}
