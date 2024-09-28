import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/extensions/route_verifier_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/zup_header/zup_header_tab_button.dart';

class ZupHeader extends StatefulWidget {
  const ZupHeader({super.key, required this.height});

  final double height;

  @override
  State<ZupHeader> createState() => _ZupHeaderState();
}

class _ZupHeaderState extends State<ZupHeader> {
  final ZupNavigator navigator = inject<ZupNavigator>();
  final appCubit = inject<AppCubit>();

  Function() onRouteChange = () {};

  @override
  void initState() {
    onRouteChange = () {
      // prevent rebuilding from route changes that do not have connection
      if (navigator.currentRoute.isMyPositions || navigator.currentRoute.isNewPosition) setState(() {});
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
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.white.withOpacity(0.85)),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  key: const Key("logo-button"),
                  onTap: () => navigator.navigateToInitial(),
                  child: Assets.icons.zupLogo.svg(height: 60),
                ),
              ),
              const SizedBox(width: 16),
              ZupHeaderTabButton(
                key: const Key("my-positions-button"),
                title: "My Positions",
                icon: Assets.icons.waterWaves.svg(),
                selected: navigator.currentRoute.isMyPositions,
                onPressed: () => navigator.navigateToMyPositions(),
              ),
              const SizedBox(width: 10),
              ZupHeaderTabButton(
                key: const Key("new-position-button"),
                title: "New Position",
                icon: Assets.icons.plusDiamond.svg(),
                selected: navigator.currentRoute.isNewPosition,
                onPressed: () => navigator.navigateToNewPosition(),
              ),
              const Spacer(),
              NetworkSwitcher(
                initialNetworkIndex: appCubit.selectedNetwork.index,
                onSelect: (item, index) => appCubit.updateAppNetwork(Networks.values[index]),
                networks: List.generate(
                  Networks.values.length,
                  (index) => NetworkSwitcherItem(
                    title: Networks.values[index].label,
                    icon: Networks.values[index].icon,
                    chainInfo: Networks.values[index].chainInfo,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const ConnectButton()
            ],
          ),
        ],
      ),
    );
  }
}
