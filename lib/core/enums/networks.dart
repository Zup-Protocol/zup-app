import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/gen/assets.gen.dart';

enum Networks {
  all,
  sepolia,
  scrollSepolia;

  bool get isAll => this == Networks.all;

  String get label => switch (this) {
        all => "All Networks",
        sepolia => "Sepolia",
        scrollSepolia => "Scroll Sepolia",
      };

  Widget get icon => switch (this) {
        all => Assets.icons.all.svg(),
        sepolia => Assets.logos.ethereum.svg(),
        scrollSepolia => Assets.logos.scroll.svg(),
      };

  ChainInfo? get chainInfo => switch (this) {
        all => null,
        sepolia => ChainInfo(
            hexChainId: "0xaa36a7",
            chainName: label,
            blockExplorerUrls: const ["https://sepolia.etherscan.io"],
            nativeCurrency: NativeCurrencies.eth.currencyInfo,
            rpcUrls: [rpcUrl ?? ""],
          ),
        scrollSepolia => ChainInfo(
            hexChainId: "0x8274f",
            chainName: label,
            blockExplorerUrls: const ["https://sepolia.scrollscan.com"],
            nativeCurrency: NativeCurrencies.eth.currencyInfo,
            rpcUrls: [rpcUrl ?? ""],
          )
      };

  String? get wrappedNativeTokenAddress => switch (this) {
        all => null,
        sepolia => "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
        scrollSepolia => "0x5300000000000000000000000000000000000004"
      };

  TokenDto? get wrappedNative => switch (this) {
        all => null,
        sepolia => TokenDto(
            address: wrappedNativeTokenAddress ?? "0x",
            name: "Wrapped Ether",
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: "WETH",
            logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
          ),
        scrollSepolia => TokenDto(
            address: wrappedNativeTokenAddress ?? "0x",
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            name: "Wrapped Ether",
            symbol: "WETH",
            logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
          ),
      };

  String? get rpcUrl => switch (this) {
        all => null,
        sepolia => "https://ethereum-sepolia-rpc.publicnode.com",
        scrollSepolia => "https://scroll-sepolia-rpc.publicnode.com",
      };

  String? get zupRouterAddress => switch (this) {
        all => null,
        sepolia => "0xCd84aE98e975c4C1A82C0D9Debf992d3eeb7d6AD",
        scrollSepolia => "0x1f8A0f1FFB3047744279530Ea2635E5524D10436",
      };

  String? get feeControllerAddress => switch (this) {
        all => null,
        sepolia => "0xFBFEfD600fFC1Ae6EabD66Bb8C90F25a314Ff3Cf",
        scrollSepolia => "0x63f02Ae6B29AacFC7555E48ef129f4269B4Fe591",
      };

  TokenDto get nativeCurrency => switch (this) {
        all => throw UnsupportedError("All networks do not have a native currency"),
        sepolia => TokenDto(
            address: EthereumConstants.zeroAddress,
            name: NativeCurrencies.eth.currencyInfo.name,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: NativeCurrencies.eth.currencyInfo.symbol,
            logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
          ),
        scrollSepolia => TokenDto(
            address: EthereumConstants.zeroAddress,
            name: NativeCurrencies.eth.currencyInfo.name,
            decimals: NativeCurrencies.eth.currencyInfo.decimals,
            symbol: NativeCurrencies.eth.currencyInfo.symbol,
            logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
          ),
      };

  Future<void> openTx(String txHash) async {
    final url = "${chainInfo?.blockExplorerUrls?.first}/tx/$txHash";
    if (!await canLaunchUrl(Uri.parse(url))) return;

    await launchUrl(Uri.parse(url));
  }
}
