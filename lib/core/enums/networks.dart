import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/gen/assets.gen.dart';

enum Networks {
  mainnet,
  sepolia;

  static List<Networks> get testnets => Networks.values.where((network) => network.isTestnet).toList();
  static List<Networks> get mainnets => Networks.values.where((network) => !network.isTestnet).toList();

  bool get isTestnet => switch (this) {
        mainnet => false,
        sepolia => true,
      };

  String get label => switch (this) {
        sepolia => "Sepolia",
        mainnet => "Ethereum",
      };

  Widget get icon => switch (this) {
        sepolia => Assets.logos.ethereum.svg(),
        mainnet => Assets.logos.ethereum.svg(),
      };

  ChainInfo get chainInfo => switch (this) {
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
      };

  String get wrappedNativeTokenAddress => switch (this) {
        sepolia => "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
        mainnet => "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
      };

  TokenDto get wrappedNative => switch (this) {
        sepolia => TokenDto(
            address: wrappedNativeTokenAddress,
            name: "Wrapped Ether",
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: "WETH",
            logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
          ),
        mainnet => TokenDto(
            address: wrappedNativeTokenAddress,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            name: "Wrapped Ether",
            symbol: "WETH",
            logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
          ),
      };

  String get rpcUrl => switch (this) {
        sepolia => "https://ethereum-sepolia-rpc.publicnode.com",
        mainnet => "https://ethereum-rpc.publicnode.com",
      };

  TokenDto get nativeCurrencyTokenDto => switch (this) {
        sepolia => TokenDto(
            address: EthereumConstants.zeroAddress,
            name: NativeCurrencies.eth.currencyInfo.name,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: NativeCurrencies.eth.currencyInfo.symbol,
            logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
          ),
        mainnet => TokenDto(
            address: EthereumConstants.zeroAddress,
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
