import 'package:flutter/material.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/extensions/route_verifier_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/zup_header/zup_header_tab_button.dart';

class ZupHeader extends StatefulWidget {
  const ZupHeader({super.key});

  @override
  State<ZupHeader> createState() => _ZupHeaderState();
}

class _ZupHeaderState extends State<ZupHeader> {
  ZupNavigator navigator = inject<ZupNavigator>();
  Function() onRouteChange = () {};

  @override
  void initState() {
    onRouteChange = () {
      // prevent rebuilding from route changes that do not have connection
      if (navigator.currentRoute.isMyPositions || navigator.currentRoute.isNewPosition) {
        setState(() {});
      }
    };

    navigator.listenable.addListener(onRouteChange);
    super.initState();
  }

  @override
  void dispose() {
    navigator.listenable.removeListener(onRouteChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => navigator.navigateToInitial(),
            child: Assets.icons.zupLogo.svg(height: 60),
          ),
        ),
        const SizedBox(width: 16),
        ZupHeaderTabButton(
            title: "My Positions",
            icon: Assets.icons.waterWaves.svg(),
            selected: navigator.currentRoute.isMyPositions,
            onPressed: () => navigator.navigateToMyPositions()),
        const SizedBox(width: 10),
        ZupHeaderTabButton(
            title: "New Position",
            icon: Assets.icons.plusDiamond.svg(),
            selected: navigator.currentRoute.isNewPosition,
            onPressed: () => navigator.navigateToNewPosition()),
        const Spacer(),
        const ConnectButton()
        // ZupButton(
        //   title: "Connect Wallet",
        //   icon: Assets.icons.cableConnectorHorizontal.svg(),
        //   onPressed: () async {
        //     Ethers().connectWallet();
        //     // print("Metamask ${Wallets().isMetamaskInstalled()}");
        //     // print("Rabby ${Wallets().isRabbyInstalled()}");
        //   },
        // ),
      ],
    );
  }
}
