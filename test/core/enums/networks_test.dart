import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:web3kit/core/dtos/chain_info.dart';
import 'package:web3kit/core/enums/native_currencies.dart';
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
