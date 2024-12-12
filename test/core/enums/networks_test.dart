import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/core/dtos/chain_info.dart';
import 'package:web3kit/core/enums/native_currencies.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  UrlLauncherPlatform urlLauncherPlatform;

  setUp(() {
    urlLauncherPlatform = UrlLauncherPlatformCustomMock();
    UrlLauncherPlatform.instance = urlLauncherPlatform;
  });

  test("Label extension should match for all networks", () {
    expect(Networks.all.label, "All Networks", reason: "All networks's Label should match");
    expect(Networks.scrollSepolia.label, "Scroll Sepolia", reason: "Scroll Sepolia Label should match");
    expect(Networks.sepolia.label, "Sepolia", reason: "Sepolia Label should match");
  });

  test("Chain info extension should match for all networks", () {
    expect(
      Networks.all.chainInfo,
      null,
      reason: "All networks's ChainInfo should be null",
    );

    expect(
      Networks.sepolia.chainInfo,
      ChainInfo(
        hexChainId: "0xaa36a7",
        chainName: "Sepolia",
        blockExplorerUrls: const ["https://sepolia.etherscan.io"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://1rpc.io/sepolia"],
      ),
      reason: "Sepolia ChainInfo should match",
    );

    expect(
      Networks.scrollSepolia.chainInfo,
      ChainInfo(
        hexChainId: "0x8274f",
        chainName: "Scroll Sepolia",
        blockExplorerUrls: const ["https://sepolia.scrollscan.com"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://scroll-sepolia-rpc.publicnode.com"],
      ),
    );
  });

  test("wrapped native token address should match for all networks", () {
    expect(
      Networks.all.wrappedNativeTokenAddress,
      null,
      reason: "All networks's wrapped native token address should be null",
    );

    expect(
      Networks.sepolia.wrappedNativeTokenAddress,
      "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
      reason: "Sepolia wrapped native token address should match",
    );

    expect(
      Networks.scrollSepolia.wrappedNativeTokenAddress,
      "0x5300000000000000000000000000000000000004",
      reason: "Scroll sepolia wrapped native token address should match",
    );
  });

  test("wrapped native token should match for all networks", () {
    expect(
      Networks.all.wrappedNative,
      null,
      reason: "All networks's default token should be null",
    );

    expect(
      Networks.sepolia.wrappedNative,
      const TokenDto(
        address: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
        name: "Wrapped Ether",
        decimals: 18,
        symbol: "WETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
      ),
      reason: "Sepolia default token should match",
    );

    expect(
      Networks.scrollSepolia.wrappedNative,
      const TokenDto(
        address: "0x5300000000000000000000000000000000000004",
        name: "Wrapped Ether",
        decimals: 18,
        symbol: "WETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
      ),
      reason: "Scroll Sepolia default token should match",
    );
  });

  test("When calling `isAll` it should return true if the network is All", () {
    expect(Networks.all.isAll, true);
  });

  test("When calling `isAll` it should return false if the network is not All", () {
    expect(Networks.sepolia.isAll, false);
  });

  test("RpcUrl extension should return the correct rpc url", () {
    expect(Networks.all.rpcUrl, null, reason: "All networks's rpc url should be null");

    expect(
      Networks.sepolia.rpcUrl,
      "https://1rpc.io/sepolia",
      reason: "Sepolia rpc url should match",
    );

    expect(
      Networks.scrollSepolia.rpcUrl,
      "https://scroll-sepolia-rpc.publicnode.com",
      reason: "Scroll Sepolia rpc url should match",
    );
  });

  test("ZupRouterAddress extension should return the correct zup router address", () async {
    expect(Networks.all.zupRouterAddress, null, reason: "All networks's zup router address should be null");

    expect(
      Networks.sepolia.zupRouterAddress,
      "0xCd84aE98e975c4C1A82C0D9Debf992d3eeb7d6AD",
      reason: "Sepolia zup router address should match",
    );

    expect(
      Networks.scrollSepolia.zupRouterAddress,
      "0x1f8A0f1FFB3047744279530Ea2635E5524D10436",
      reason: "Scroll Sepolia zup router address should match",
    );
  });

  test("FeeControllerAddress extension should return the correct fee controller address", () async {
    expect(Networks.all.feeControllerAddress, null, reason: "All networks's fee controller address should be null");

    expect(
      Networks.sepolia.feeControllerAddress,
      "0xFBFEfD600fFC1Ae6EabD66Bb8C90F25a314Ff3Cf",
      reason: "Sepolia fee controller address should match",
    );

    expect(
      Networks.scrollSepolia.feeControllerAddress,
      "0x63f02Ae6B29AacFC7555E48ef129f4269B4Fe591",
      reason: "Scroll Sepolia fee controller address should match",
    );
  });

  test("openTx should open the correct url for each network", () async {
    const txHash = "0x1271892718912u198haisghsg7223617";

    for (final network in Networks.values) {
      if (network.isAll) continue;

      await network.openTx(txHash);

      expect(
        UrlLauncherPlatformCustomMock.lastLaunchedUrl,
        "${network.chainInfo?.blockExplorerUrls?.first}/tx/$txHash",
        reason: "${network.name} should open the correct url",
      );
    }
  });

  zGoldenTest("All networks icon should match", goldenFileName: "all_networks_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      Networks.all.icon,
      device: GoldenDevice.square,
    ));
  });

  zGoldenTest("Sepolia network icon should match", goldenFileName: "sepolia_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      Networks.sepolia.icon,
      device: GoldenDevice.square,
    ));
  });

  zGoldenTest("Scroll Sepolia network icon should match", goldenFileName: "scroll_sepolia_network_icon",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      Networks.scrollSepolia.icon,
      device: GoldenDevice.square,
    ));
  });
}
