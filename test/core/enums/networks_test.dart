import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/core/dtos/chain_info.dart';
import 'package:web3kit/core/enums/native_currencies.dart';
import 'package:zup_app/core/enums/networks.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  UrlLauncherPlatform urlLauncherPlatform;

  setUp(() {
    urlLauncherPlatform = UrlLauncherPlatformCustomMock();
    UrlLauncherPlatform.instance = urlLauncherPlatform;
  });

  test("When calling 'fromValue' it should get a network from a string value", () {
    expect(AppNetworks.fromValue("sepolia"), AppNetworks.sepolia, reason: "Sepolia should match");
    expect(AppNetworks.fromValue("mainnet"), AppNetworks.mainnet, reason: "Mainnet should match");
    expect(AppNetworks.fromValue("scroll"), AppNetworks.scroll, reason: "Scroll should match");
    expect(AppNetworks.fromValue("allNetworks"), AppNetworks.allNetworks, reason: "All networks should match");
    // expect(AppNetworks.fromValue("base"), AppNetworks.base, reason: "Base should match");
    expect(AppNetworks.fromValue("unichain"), AppNetworks.unichain, reason: "Unichain should match");
    // expect(AppNetworks.fromValue("bnb"), AppNetworks.bnb, reason: "BNB should match");
  });

  test("Label extension should match for all networks", () {
    expect(AppNetworks.sepolia.label, "Sepolia", reason: "Sepolia Label should match");
    expect(AppNetworks.mainnet.label, "Ethereum", reason: "Ethereum Label should match");
    expect(AppNetworks.scroll.label, "Scroll", reason: "Scroll Label should match");
    expect(AppNetworks.allNetworks.label, "All Networks", reason: "All Networks Label should match");
    // expect(AppNetworks.base.label, "Base", reason: "Base Label should match");
    expect(AppNetworks.unichain.label, "Unichain", reason: "Unichain Label should match");
    // expect(AppNetworks.bnb.label, "BNB Chain", reason: "BNB Chain Label should match");
  });

  test("`testnets` method should return all testnets in the enum, excluding the 'all networks'", () {
    expect(AppNetworks.testnets, [AppNetworks.sepolia]);
  });

  test("`mainnets` method should return all mainnets in the enum, including the 'all networks'", () {
    expect(
      AppNetworks.mainnets,
      containsAll([
        AppNetworks.allNetworks,
        AppNetworks.mainnet,
        AppNetworks.scroll,
        // AppNetworks.base,
        AppNetworks.unichain,
        // AppNetworks.bnb
      ]),
    );
  });

  test("`isTestnet` method should return true for sepolia", () {
    expect(AppNetworks.sepolia.isTestnet, true);
  });

  test("`isTestnet` method should return false for mainnet", () {
    expect(AppNetworks.mainnet.isTestnet, false);
  });

  test("`isTestnet` method should return false for Scroll", () {
    expect(AppNetworks.scroll.isTestnet, false);
  });

  test("`isTestnet` method should return false for base", () {
    // expect(AppNetworks.base.isTestnet, false);
  });

  test("`isTestnet` method should return false for unichain", () {
    expect(AppNetworks.unichain.isTestnet, false);
  });

  test("`isTestnet` method should return false for bnb", () {
    // expect(AppNetworks.bnb.isTestnet, false);
  });

  test("Chain info extension should match for all networks", () {
    expect(
      AppNetworks.sepolia.chainInfo,
      ChainInfo(
        hexChainId: "0xaa36a7",
        chainName: "Sepolia",
        blockExplorerUrls: const ["https://sepolia.etherscan.io"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://ethereum-sepolia-rpc.publicnode.com"],
      ),
      reason: "Sepolia ChainInfo should match",
    );

    expect(
      AppNetworks.mainnet.chainInfo,
      ChainInfo(
        hexChainId: "0x1",
        chainName: "Ethereum",
        blockExplorerUrls: const ["https://etherscan.io"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://ethereum-rpc.publicnode.com"],
      ),
    );

    expect(
      AppNetworks.scroll.chainInfo,
      ChainInfo(
        hexChainId: "0x82750",
        chainName: "Scroll",
        blockExplorerUrls: const ["https://scrollscan.com"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://scroll-rpc.publicnode.com"],
      ),
      reason: "Scroll ChainInfo should match",
    );

    // expect(
    //   AppNetworks.base.chainInfo,
    //   ChainInfo(
    //     hexChainId: "0x2105",
    //     chainName: "Base",
    //     blockExplorerUrls: const ["https://basescan.org"],
    //     nativeCurrency: NativeCurrencies.eth.currencyInfo,
    //     rpcUrls: const ["https://base-rpc.publicnode.com"],
    //   ),
    //   reason: "Base ChainInfo should match",
    // );

    expect(
      AppNetworks.unichain.chainInfo,
      ChainInfo(
        hexChainId: "0x82",
        chainName: "Unichain",
        blockExplorerUrls: const ["https://uniscan.xyz"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://unichain-rpc.publicnode.com"],
      ),
      reason: "Unichain ChainInfo should match",
    );

    // expect(
    //   AppNetworks.bnb.chainInfo,
    //   ChainInfo(
    //     hexChainId: "0x38",
    //     chainName: "BNB Chain",
    //     blockExplorerUrls: const ["https://bscscan.com"],
    //     nativeCurrency: NativeCurrencies.bnb.currencyInfo,
    //     rpcUrls: const ["https://bsc-rpc.publicnode.com"],
    //   ),
    //   reason: "BNB Chain ChainInfo should match",
    // );
  });

  test("wrapped native token address should match for all networks", () {
    expect(
      AppNetworks.sepolia.wrappedNativeTokenAddress,
      "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
      reason: "Sepolia wrapped native token address should match",
    );

    expect(
      AppNetworks.mainnet.wrappedNativeTokenAddress,
      "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
      reason: "Ethereum wrapped native token address should match",
    );

    expect(
      AppNetworks.scroll.wrappedNativeTokenAddress,
      "0x5300000000000000000000000000000000000004",
      reason: "Scroll wrapped native token address should match",
    );

    // expect(
    //   AppNetworks.base.wrappedNativeTokenAddress,
    //   "0x4200000000000000000000000000000000000006",
    //   reason: "Base wrapped native token address should match",
    // );

    expect(
      AppNetworks.unichain.wrappedNativeTokenAddress,
      "0x4200000000000000000000000000000000000006",
      reason: "Unichain wrapped native token address should match",
    );
  });

  test("RpcUrl extension should return the correct rpc url", () {
    expect(
      AppNetworks.sepolia.rpcUrl,
      "https://ethereum-sepolia-rpc.publicnode.com",
      reason: "Sepolia rpc url should match",
    );

    expect(
      AppNetworks.mainnet.rpcUrl,
      "https://ethereum-rpc.publicnode.com",
      reason: "Ethereum rpc url should match",
    );

    expect(
      AppNetworks.scroll.rpcUrl,
      "https://scroll-rpc.publicnode.com",
      reason: "Scroll rpc url should match",
    );

    // expect(
    //   AppNetworks.base.rpcUrl,
    //   "https://base-rpc.publicnode.com",
    //   reason: "Base rpc url should match",
    // );

    expect(
      AppNetworks.unichain.rpcUrl,
      "https://unichain-rpc.publicnode.com",
      reason: "Unichain rpc url should match",
    );

    // expect(
    //   AppNetworks.bnb.rpcUrl,
    //   "https://bsc-rpc.publicnode.com",
    //   reason: "BNB rpc url should match",
    // );
  });

  test("openTx should open the correct url for each network", () async {
    const txHash = "0x1271892718912u198haisghsg7223617";

    for (final network in AppNetworks.values) {
      if (network.isAllNetworks) continue;

      await network.openTx(txHash);

      expect(
        UrlLauncherPlatformCustomMock.lastLaunchedUrl,
        "${network.chainInfo.blockExplorerUrls?.first}/tx/$txHash",
        reason: "${network.name} should open the correct url",
      );
    }
  });

  test("'fromChainId' should return the correct network from the chain id", () {
    for (final network in AppNetworks.values) {
      if (network.isAllNetworks) continue;

      expect(
        AppNetworks.fromChainId(network.chainId),
        network,
        reason: "Network from chain id should match ${network.name}",
      );
    }
  });

  test("'isAllNetworks' should return true if the network is all networks", () {
    expect(AppNetworks.allNetworks.isAllNetworks, true);
  });

  test("'isAllNetworks' should return false if the network is not all networks", () {
    expect(AppNetworks.scroll.isAllNetworks, false);
    expect(AppNetworks.unichain.isAllNetworks, false);
  });

  test("'chainId' should return the correct chain id for each network", () {
    for (final network in AppNetworks.values) {
      if (network.isAllNetworks) continue;

      expect(network.chainId, int.parse(network.chainInfo.hexChainId), reason: "Chain id should match ${network.name}");
    }
  });

  zGoldenTest("Sepolia network icon should match", goldenFileName: "sepolia_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      AppNetworks.sepolia.icon,
      device: GoldenDevice.square,
    ));
  });

  zGoldenTest("Ethereum network icon should match", goldenFileName: "ethereum_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      AppNetworks.mainnet.icon,
      device: GoldenDevice.square,
    ));
  });

  // zGoldenTest("Base network icon should match", goldenFileName: "base_network_icon", (tester) async {
  //   await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
  //     AppNetworks.base.icon,
  //     device: GoldenDevice.square,
  //   ));
  // });

  zGoldenTest("Scroll network icon should match", goldenFileName: "scroll_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      AppNetworks.scroll.icon,
      device: GoldenDevice.square,
    ));
  });

  zGoldenTest("Unichain network icon should match", goldenFileName: "unichain_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      AppNetworks.unichain.icon,
      device: GoldenDevice.square,
    ));
  });

  // zGoldenTest("BNB network icon should match", goldenFileName: "bnb_network_icon", (tester) async {
  //   await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
  //     AppNetworks.bnb.icon,
  //     device: GoldenDevice.square,
  //   ));
  // });
}
