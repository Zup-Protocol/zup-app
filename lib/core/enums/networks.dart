import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/gen/assets.gen.dart';

enum AppNetworks {
  allNetworks,
  mainnet,
  scroll,
  sepolia;

  static List<AppNetworks> get testnets => AppNetworks.values
      .where(
        (network) => !network.isAllNetworks && network.isTestnet,
      )
      .toList();

  static List<AppNetworks> get mainnets => AppNetworks.values
      .where(
        (network) => network.isAllNetworks || !network.isTestnet,
      )
      .toList();

  static AppNetworks? fromValue(String value) =>
      AppNetworks.values.firstWhereOrNull((network) => network.name == value);

  static AppNetworks? fromChainId(int chainId) => AppNetworks.values.firstWhereOrNull(
        (network) {
          if (network.isAllNetworks) return false;

          return int.parse(network.chainInfo.hexChainId) == chainId;
        },
      );

  int get chainId => int.parse(chainInfo.hexChainId);

  bool get isAllNetworks => this == allNetworks;

  bool get isTestnet => switch (this) {
        mainnet => false,
        scroll => false,
        sepolia => true,
        allNetworks => false,
      };

  String get label => switch (this) {
        sepolia => "Sepolia",
        mainnet => "Ethereum",
        scroll => "Scroll",
        allNetworks => "All Networks",
      };

  Widget get icon => switch (this) {
        sepolia => Assets.logos.ethereum.svg(),
        mainnet => Assets.logos.ethereum.svg(),
        scroll => Assets.logos.scroll.svg(),
        allNetworks => Assets.icons.all.svg(),
      };

  ChainInfo get chainInfo => switch (this) {
        allNetworks => throw UnimplementedError("allNetworks is not a valid network"),
        sepolia => ChainInfo(
            hexChainId: "0xaa36a7",
            chainName: label,
            blockExplorerUrls: const ["https://sepolia.etherscan.io"],
            nativeCurrency: NativeCurrencies.eth.currencyInfo,
            rpcUrls: [rpcUrl],
          ),
        mainnet => ChainInfo(
            hexChainId: "0x1",
            chainName: label,
            blockExplorerUrls: const ["https://etherscan.io"],
            nativeCurrency: NativeCurrencies.eth.currencyInfo,
            rpcUrls: [rpcUrl],
          ),
        scroll => ChainInfo(
            hexChainId: "0x82750",
            chainName: label,
            blockExplorerUrls: const ["https://scrollscan.com"],
            nativeCurrency: NativeCurrencies.eth.currencyInfo,
            rpcUrls: [rpcUrl],
          ),
      };

  String get wrappedNativeTokenAddress => switch (this) {
        allNetworks => throw UnimplementedError("allNetworks is not a valid network"),
        sepolia => "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
        mainnet => "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        scroll => "0x5300000000000000000000000000000000000004",
      };

  TokenDto get wrappedNative => switch (this) {
        allNetworks => throw UnimplementedError("allNetworks is not a valid network"),
        sepolia => TokenDto(
            addresses: {chainId: wrappedNativeTokenAddress},
            name: "Wrapped Ether",
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: "WETH",
            logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
          ),
        mainnet => TokenDto(
            addresses: {chainId: wrappedNativeTokenAddress},
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            name: "Wrapped Ether",
            symbol: "WETH",
            logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
          ),
        scroll => TokenDto(
            addresses: {chainId: wrappedNativeTokenAddress},
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            name: "Wrapped Ether",
            symbol: "WETH",
            logoUrl:
                "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x5300000000000000000000000000000000000004/logo.png",
          ),
      };

  String get rpcUrl => switch (this) {
        allNetworks => throw UnimplementedError("allNetworks is not a valid network"),
        sepolia => "https://ethereum-sepolia-rpc.publicnode.com",
        mainnet => "https://ethereum-rpc.publicnode.com",
        scroll => "https://scroll-rpc.publicnode.com",
      };

  TokenDto get nativeCurrencyTokenDto => switch (this) {
        allNetworks => throw UnimplementedError("allNetworks is not a valid network"),
        sepolia => TokenDto(
            name: NativeCurrencies.eth.currencyInfo.name,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: NativeCurrencies.eth.currencyInfo.symbol,
            logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
          ),
        mainnet => TokenDto(
            name: NativeCurrencies.eth.currencyInfo.name,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: NativeCurrencies.eth.currencyInfo.symbol,
            logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
          ),
        scroll => TokenDto(
            name: NativeCurrencies.eth.currencyInfo.name,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: NativeCurrencies.eth.currencyInfo.symbol,
            logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
          ),
      };

  Future<void> openTx(String txHash) async {
    final url = "${chainInfo.blockExplorerUrls?.first}/tx/$txHash";
    if (!await canLaunchUrl(Uri.parse(url))) return;

    await launchUrl(Uri.parse(url));
  }
}
