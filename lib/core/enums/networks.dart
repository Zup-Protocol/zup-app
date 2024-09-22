import 'package:flutter/material.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/gen/assets.gen.dart';

enum Networks { all, ethereum, base, arbitrum }

extension NetworksExtension on Networks {
  String get name => ["All Networks", "Ethereum", "Base", "Arbitrum"][index];

  Widget get icon => [
        Assets.icons.all.svg(),
        Assets.logos.ethereum.svg(),
        Assets.logos.base.svg(),
        Assets.logos.arbitrum.svg()
      ][index];

  ChainInfo? get networkInfo => [
        null,
        ChainInfo(
          hexChainId: "0x1",
          chainName: name,
          blockExplorerUrls: const ["https://etherscan.io"],
          nativeCurrency: NativeCurrencies.eth.currencyInfo,
          rpcUrls: const ["https://eth.llamarpc.com"],
        ),
        ChainInfo(
          hexChainId: "0x2105",
          chainName: name,
          blockExplorerUrls: const ["https://basescan.org/"],
          nativeCurrency: NativeCurrencies.eth.currencyInfo,
          rpcUrls: const ["https://mainnet.base.org"],
        ),
        ChainInfo(
          hexChainId: "0xa4b1",
          chainName: name,
          blockExplorerUrls: const ["https://arbiscan.io"],
          nativeCurrency: NativeCurrencies.eth.currencyInfo,
          rpcUrls: const ["https://arb1.arbitrum.io/rpc"],
        ),
      ][index];
}
