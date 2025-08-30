import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/extensions/route_verifier_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/app_header/app_header_tab_button.dart';
import 'package:zup_app/widgets/app_settings_dropdown.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key, required this.height});

  final double height;

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> with DeviceInfoMixin {
  final ZupNavigator navigator = inject<ZupNavigator>();
  final appCubit = inject<AppCubit>();

  List<AppNetworks> get currentModeNetworks {
    return appCubit.isTestnetMode ? AppNetworks.testnets : AppNetworks.mainnets;
  }

  Function() onRouteChange = () {};

  @override
  void initState() {
    onRouteChange = () {
      // prevent rebuilding from route changes that do not have connection
      if (navigator.currentRoute.isNewPosition) setState(() {});
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
    return BlocBuilder<AppCubit, AppState>(
      bloc: appCubit,
      builder: (context, state) {
        if (appCubit.isTestnetMode) {
          return Banner(
            message: "Testnet",
            location: BannerLocation.topEnd,
            color: ZupColors.brand6,
            shadow: const BoxShadow(color: ZupColors.gray6, offset: Offset(0, 1), blurRadius: 2),
            textStyle: const TextStyle(fontSize: 10, color: ZupColors.brand, fontWeight: FontWeight.w600),
            child: buildAppBar,
          );
        }

        return buildAppBar;
      },
    );
  }

  Widget get buildAppBar => SizedBox(
    height: widget.height,
    child: Stack(
      alignment: Alignment.center,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: ZupThemeColors.background.themed(context.brightness).withValues(alpha: 0.85)),
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
                  child: context.brightness.isDark
                      ? Assets.logos.zupOnBlack.svg(height: 21)
                      : Assets.logos.zupOnWhite.svg(height: 21),
                ),
              ),
              const SizedBox(width: 26),
              if (!isTabletSize(context)) ...[
                AppHeaderTabButton(
                  key: const Key("new-position-button"),
                  title: "New Position",
                  icon: Assets.icons.plusDiamond.svg(
                    colorFilter: ColorFilter.mode(
                      ZupThemeColors.primaryText.themed(context.brightness),
                      BlendMode.srcIn,
                    ),
                  ),
                  selected: navigator.currentRoute.isNewPosition,
                  onPressed: () => navigator.navigateToNewPosition(),
                ),
                const SizedBox(width: 10),
                AppHeaderTabButton(
                  key: const Key("my-positions-button"),
                  title: "My Positions (Soon)",
                  icon: Assets.icons.waterWaves.svg(
                    colorFilter: ColorFilter.mode(
                      ZupThemeColors.primaryText.themed(context.brightness),
                      BlendMode.srcIn,
                    ),
                  ),
                  selected: false,
                  onPressed: null, // () => navigator.navigateToMyPositions(),
                ),
              ],
              const Spacer(),
              NetworkSwitcher(
                compact: isMobileSize(context),
                initialNetworkIndex: currentModeNetworks.indexOf(appCubit.selectedNetwork),
                onSelect: (item, index) => appCubit.updateAppNetwork(currentModeNetworks[index]),
                networks: List.generate(
                  currentModeNetworks.length,
                  (index) => NetworkSwitcherItem(
                    title: currentModeNetworks[index].label,
                    icon: currentModeNetworks[index].icon,
                    chainInfo: currentModeNetworks[index].isAllNetworks ? null : currentModeNetworks[index].chainInfo,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ConnectButton(compact: isMobileSize(context)),
              const SizedBox(width: 12),
              ZupIconButton(
                iconColor: context.brightness.isLight ? ZupColors.brand : ZupColors.white,

                icon: Transform.rotate(angle: pi / 2, child: Assets.icons.ellipsis.svg(height: 3.5)),
                onPressed: (context) {
                  AppSettingsDropdown.show(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
