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

  test("When calling 'fromValue' it should get a network from a string value", () {
    expect(AppNetworks.fromValue("sepolia"), AppNetworks.sepolia);
    expect(AppNetworks.fromValue("mainnet"), AppNetworks.mainnet);
    expect(AppNetworks.fromValue("scroll"), AppNetworks.scroll);
  });

  test("Label extension should match for all networks", () {
    expect(AppNetworks.sepolia.label, "Sepolia", reason: "Sepolia Label should match");
    expect(AppNetworks.mainnet.label, "Ethereum", reason: "Ethereum Label should match");
    expect(AppNetworks.scroll.label, "Scroll", reason: "Scroll Label should match");
  });

  test("`testnets` method should return all testnets in the enum, excluding the 'all networks'", () {
    expect(AppNetworks.testnets, [AppNetworks.sepolia]);
  });

  test("`mainnets` method should return all mainnets in the enum, including the 'all networks'", () {
    expect(AppNetworks.mainnets, [AppNetworks.allNetworks, AppNetworks.mainnet, AppNetworks.scroll]);
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
  });

  test("wrapped native token should match for all networks", () {
    expect(
      AppNetworks.sepolia.wrappedNative,
      TokenDto(
        addresses: {
          AppNetworks.sepolia.chainId: "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
        },
        name: "Wrapped Ether",
        decimals: 18,
        symbol: "WETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
      ),
      reason: "Sepolia default token should match",
    );

    expect(
      AppNetworks.mainnet.wrappedNative,
      TokenDto(
        addresses: {
          AppNetworks.mainnet.chainId: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        },
        name: "Wrapped Ether",
        decimals: 18,
        symbol: "WETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
      ),
      reason: "Ethereum default token should match",
    );

    expect(
      AppNetworks.scroll.wrappedNative,
      TokenDto(
        addresses: {
          AppNetworks.scroll.chainId: "0x5300000000000000000000000000000000000004",
        },
        name: "Wrapped Ether",
        decimals: 18,
        symbol: "WETH",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x5300000000000000000000000000000000000004/logo.png",
      ),
      reason: "Scroll default token should match",
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

  test("'nativeCurrency' should return the correct currency for sepolia network", () {
    expect(
      AppNetworks.sepolia.nativeCurrencyTokenDto,
      TokenDto(
        addresses: {},
        name: NativeCurrencies.eth.currencyInfo.name,
        decimals: NativeCurrencies.eth.currencyInfo.decimals,
        symbol: NativeCurrencies.eth.currencyInfo.symbol,
        logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
      ),
      reason: "Sepolia native currency should match",
    );
  });

  test("'nativeCurrency' should return the correct currency for ethereum network", () {
    expect(
      AppNetworks.mainnet.nativeCurrencyTokenDto,
      TokenDto(
        addresses: {},
        name: NativeCurrencies.eth.currencyInfo.name,
        decimals: NativeCurrencies.eth.currencyInfo.decimals,
        symbol: NativeCurrencies.eth.currencyInfo.symbol,
        logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
      ),
      reason: "Ethereum native currency should match",
    );
  });

  test("'nativeCurrency' should return the correct currency for scroll network", () {
    expect(
      AppNetworks.scroll.nativeCurrencyTokenDto,
      TokenDto(
        addresses: {},
        name: NativeCurrencies.eth.currencyInfo.name,
        decimals: NativeCurrencies.eth.currencyInfo.decimals,
        symbol: NativeCurrencies.eth.currencyInfo.symbol,
        logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
      ),
      reason: "Scroll native currency should match",
    );
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
}
