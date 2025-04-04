import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/core/dtos/chain_info.dart';
import 'package:web3kit/core/enums/native_currencies.dart';
import 'package:web3kit/core/ethereum_constants.dart';
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
    expect(Networks.sepolia.label, "Sepolia", reason: "Sepolia Label should match");
    expect(Networks.mainnet.label, "Ethereum", reason: "Ethereum Label should match");
  });

  test("`testnets` method should return all testnets in the enum", () {
    expect(Networks.testnets, [Networks.sepolia]);
  });

  test("`testnets` method should return all testnets in the enum", () {
    expect(Networks.mainnets, [Networks.mainnet]);
  });

  test("`isTestnet` method should return true for sepolia", () {
    expect(Networks.sepolia.isTestnet, true);
  });

  test("`isTestnet` method should return false for mainnet", () {
    expect(Networks.mainnet.isTestnet, false);
  });

  test("Chain info extension should match for all networks", () {
    expect(
      Networks.sepolia.chainInfo,
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
      Networks.mainnet.chainInfo,
      ChainInfo(
        hexChainId: "0x1",
        chainName: "Ethereum",
        blockExplorerUrls: const ["https://etherscan.io"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://ethereum-rpc.publicnode.com"],
      ),
    );
  });

  test("wrapped native token address should match for all networks", () {
    expect(
      Networks.sepolia.wrappedNativeTokenAddress,
      "0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14",
      reason: "Sepolia wrapped native token address should match",
    );

    expect(
      Networks.mainnet.wrappedNativeTokenAddress,
      "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
      reason: "Ethereum wrapped native token address should match",
    );
  });

  test("wrapped native token should match for all networks", () {
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
      Networks.mainnet.wrappedNative,
      const TokenDto(
        address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        name: "Wrapped Ether",
        decimals: 18,
        symbol: "WETH",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/info/logo.png",
      ),
      reason: "Ethereum default token should match",
    );
  });

  test("RpcUrl extension should return the correct rpc url", () {
    expect(
      Networks.sepolia.rpcUrl,
      "https://ethereum-sepolia-rpc.publicnode.com",
      reason: "Sepolia rpc url should match",
    );

    expect(
      Networks.mainnet.rpcUrl,
      "https://ethereum-rpc.publicnode.com",
      reason: "Ethereum rpc url should match",
    );
  });

  test("openTx should open the correct url for each network", () async {
    const txHash = "0x1271892718912u198haisghsg7223617";

    for (final network in Networks.values) {
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
      Networks.sepolia.nativeCurrencyTokenDto,
      TokenDto(
        address: EthereumConstants.zeroAddress,
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
      Networks.mainnet.nativeCurrencyTokenDto,
      TokenDto(
        address: EthereumConstants.zeroAddress,
        name: NativeCurrencies.eth.currencyInfo.name,
        decimals: NativeCurrencies.eth.currencyInfo.decimals,
        symbol: NativeCurrencies.eth.currencyInfo.symbol,
        logoUrl: NativeCurrencies.eth.currencyInfo.logoUrl,
      ),
      reason: "Ethereum native currency should match",
    );
  });

  zGoldenTest("Sepolia network icon should match", goldenFileName: "sepolia_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      Networks.sepolia.icon,
      device: GoldenDevice.square,
    ));
  });

  zGoldenTest("Ethereum network icon should match", goldenFileName: "ethereum_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(
      Networks.mainnet.icon,
      device: GoldenDevice.square,
    ));
  });
}
