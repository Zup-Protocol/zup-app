import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/extensions/route_verifier_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/app_header/app_header_tab_button.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key, required this.height});

  final double height;

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> with DeviceInfoMixin {
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
              child: Container(color: Colors.black.withOpacity(0.85)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    key: const Key("logo-button"),
                    onTap: () => navigator.navigateToInitial(),
                    child: Assets.logos.zup.svg(height: 30),
                  ),
                ),
                const SizedBox(width: 26),
                if (!isMobileSize(context)) ...[
                  AppHeaderTabButton(
                    key: const Key("new-position-button"),
                    title: "New Position",
                    icon: Assets.icons.plusDiamond.svg(),
                    selected: navigator.currentRoute.isNewPosition,
                    onPressed: () => navigator.navigateToNewPosition(),
                  ),
                  const SizedBox(width: 10),
                  AppHeaderTabButton(
                    key: const Key("my-positions-button"),
                    title: "My Positions (Soon)",
                    icon: Assets.icons.waterWaves.svg(),
                    selected: navigator.currentRoute.isMyPositions,
                    onPressed: null, // () => navigator.navigateToMyPositions(),
                  ),
                ],
                const Spacer(),
                NetworkSwitcher(
                  compact: !isDesktopSize(context),
                  initialNetworkIndex: 0, //appCubit.selectedNetwork.index,
                  onSelect: (item, index) => appCubit.updateAppNetwork(Networks.values[0]),
                  networks: List.generate(
                    1,
                    (index) => NetworkSwitcherItem(
                      title: appCubit.selectedNetwork.label, //Networks.values[index].label,
                      icon: appCubit.selectedNetwork.icon, //Networks.values[index].icon,
                      chainInfo: appCubit.selectedNetwork.chainInfo, // Networks.values[index].chainInfo,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const ConnectButton()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
