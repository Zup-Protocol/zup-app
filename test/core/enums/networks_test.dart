import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:web3kit/core/dtos/chain_info.dart';
import 'package:web3kit/core/enums/native_currencies.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

import '../../golden_config.dart';

void main() {
  test("Label extension should match for all networks", () {
    expect(Networks.all.label, "All Networks", reason: "All networks's Label should match");
    expect(Networks.arbitrum.label, "Arbitrum One", reason: "Arbitrum's Label should match");
    expect(Networks.base.label, "Base", reason: "Base's Label should match");
    expect(Networks.ethereum.label, "Ethereum", reason: "Ethereum's Label should match");
  });

  test("Chain info extension should match for all networks", () {
    expect(
      Networks.all.chainInfo,
      null,
      reason: "All networks's ChainInfo should be null",
    );

    expect(
      Networks.arbitrum.chainInfo,
      ChainInfo(
        hexChainId: "0xa4b1",
        chainName: "Arbitrum One",
        blockExplorerUrls: const ["https://arbiscan.io"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://arb1.arbitrum.io/rpc"],
      ),
      reason: "Arbitrum's ChainInfo should match",
    );

    expect(
      Networks.base.chainInfo,
      ChainInfo(
        hexChainId: "0x2105",
        chainName: "Base",
        blockExplorerUrls: const ["https://basescan.org/"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://mainnet.base.org"],
      ),
    );

    expect(
      Networks.ethereum.chainInfo,
      ChainInfo(
        hexChainId: "0x1",
        chainName: "Ethereum",
        blockExplorerUrls: const ["https://etherscan.io"],
        nativeCurrency: NativeCurrencies.eth.currencyInfo,
        rpcUrls: const ["https://eth.llamarpc.com"],
      ),
      reason: "Ethereum's ChainInfo should match",
    );
  });

  test("wrapped native token address should match for all networks", () {
    expect(
      Networks.all.wrappedNativeTokenAddress,
      null,
      reason: "All networks's wrapped native token address should be null",
    );

    expect(
      Networks.ethereum.wrappedNativeTokenAddress,
      "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
      reason: "Ethereum's wrapped native token address should match",
    );

    expect(
      Networks.base.wrappedNativeTokenAddress,
      "0x4200000000000000000000000000000000000006",
      reason: "Base's wrapped native token address should match",
    );

    expect(
      Networks.arbitrum.wrappedNativeTokenAddress,
      "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
      reason: "Arbitrum's wrapped native token address should match",
    );
  });

  test("default token should match for all networks", () {
    expect(
      Networks.all.defaultToken,
      null,
      reason: "All networks's default token should be null",
    );

    expect(
      Networks.ethereum.defaultToken,
      TokenDto(
        address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        name: "Wrapped Ether",
        symbol: "WETH",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/${Networks.ethereum.wrappedNativeTokenAddress}/logo.png",
      ),
      reason: "Ethereum's default token should match",
    );

    expect(
      Networks.base.defaultToken,
      TokenDto(
        address: "0x4200000000000000000000000000000000000006",
        name: "Wrapped Ether",
        symbol: "WETH",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/base/assets/${Networks.base.wrappedNativeTokenAddress}/logo.png",
      ),
      reason: "Base's default token should match",
    );

    expect(
      Networks.arbitrum.defaultToken,
      TokenDto(
        address: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1",
        name: "Wrapped Ether",
        symbol: "WETH",
        logoUrl:
            "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/arbitrum/assets/${Networks.arbitrum.wrappedNativeTokenAddress}/logo.png",
      ),
      reason: "Arbitrum's default token should match",
    );
  });

  test("When calling `isAll` it should return true if the network is All", () {
    expect(Networks.all.isAll, true);
  });

  test("When calling `isAll` it should return false if the network is not All", () {
    expect(Networks.arbitrum.isAll, false);
  });

  zGoldenTest("All networks icon should match", goldenFileName: "all_networks_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Networks.all.icon, largeDevice: false));
  });

  zGoldenTest("Ethereum network icon should match", goldenFileName: "ethereum_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Networks.ethereum.icon, largeDevice: false));
  });

  zGoldenTest("Base network icon should match", goldenFileName: "base_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Networks.base.icon, largeDevice: false));
  });

  zGoldenTest("Arbitrum network icon should match", goldenFileName: "arbitrum_network_icon", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Networks.arbitrum.icon, largeDevice: false));
  });
}
