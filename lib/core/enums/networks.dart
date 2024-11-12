import 'package:flutter/material.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/gen/assets.gen.dart';

enum Networks { all, ethereum, base, arbitrum }

extension NetworksExtension on Networks {
  bool get isAll => this == Networks.all;

  String get label => ["All Networks", "Ethereum", "Base", "Arbitrum One"][index];

  Widget get icon => [
        Assets.icons.all.svg(),
        Assets.logos.ethereum.svg(),
        Assets.logos.base.svg(),
        Assets.logos.arbitrum.svg()
      ][index];

  ChainInfo? get chainInfo => [
        null,
        ChainInfo(
          hexChainId: "0x1",
          chainName: label,
          blockExplorerUrls: const ["https://etherscan.io"],
          nativeCurrency: NativeCurrencies.eth.currencyInfo,
          rpcUrls: [rpcUrl ?? ""],
        ),
        ChainInfo(
          hexChainId: "0x2105",
          chainName: label,
          blockExplorerUrls: const ["https://basescan.org/"],
          nativeCurrency: NativeCurrencies.eth.currencyInfo,
          rpcUrls: [rpcUrl ?? ""],
        ),
        ChainInfo(
          hexChainId: "0xa4b1",
          chainName: label,
          blockExplorerUrls: const ["https://arbiscan.io"],
          nativeCurrency: NativeCurrencies.eth.currencyInfo,
          rpcUrls: [rpcUrl ?? ""],
        ),
      ][index];

  String? get wrappedNativeTokenAddress => [
        null,
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        "0x4200000000000000000000000000000000000006",
        "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
      ][index];

  TokenDto? get defaultToken => [
        null,
        TokenDto(
          address: wrappedNativeTokenAddress ?? "0x",
          name: "Wrapped Ether",
          symbol: "WETH",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/$wrappedNativeTokenAddress/logo.png",
        ),
        TokenDto(
          address: wrappedNativeTokenAddress ?? "0x",
          name: "Wrapped Ether",
          symbol: "WETH",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/base/assets/$wrappedNativeTokenAddress/logo.png",
        ),
        TokenDto(
          address: wrappedNativeTokenAddress ?? "0x",
          name: "Wrapped Ether",
          symbol: "WETH",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/assets/$wrappedNativeTokenAddress/logo.png",
        ),
      ][index];

  String? get rpcUrl => [
        null,
        "https://eth.llamarpc.com",
        "https://mainnet.base.org",
        "https://arb1.arbitrum.io/rpc",
      ][index];
}
