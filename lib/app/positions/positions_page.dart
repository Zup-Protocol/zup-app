import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/app/positions/widgets/position_card.dart';
import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/zup_skeletonizer.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class PositionsPage extends StatefulWidget {
  const PositionsPage({super.key});

  @override
  State<PositionsPage> createState() => _PositionsPageState();
}

class _PositionsPageState extends State<PositionsPage> {
  final navigator = inject<ZupNavigator>();
  final cubit = inject<PositionsCubit>();
  final appCubit = inject<AppCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<PositionsCubit, PositionsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 70),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 690),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.maybeWhen(
                            orElse: () => S.of(context).positionsPageMyPositions,
                            positions: (positions) => "${S.of(context).positionsPageMyPositions} (${positions.length})",
                          ),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        state.maybeWhen(
                          notConnected: () => const SizedBox.shrink(),
                          error: () => const SizedBox.shrink(),
                          loading: () => ZupSkeletonizer(
                            child: ZupPrimaryButton(
                              title: "Loading Positions Page...",
                              backgroundColor: Colors.transparent,
                              onPressed: () {},
                              height: 40,
                            ),
                          ),
                          orElse: () => ZupPrimaryButton(
                            key: const Key("hide-show-closed-positions"),
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            hoverElevation: 0,
                            icon: Transform.rotate(
                              angle: cubit.hidingClosedPositions ? 0 : pi,
                              child: Assets.icons.switch2.svg(),
                            ),
                            backgroundColor: Colors.transparent,
                            title: S
                                .of(context)
                                .positionsPageShowHideClosedPositions(cubit.hidingClosedPositions.toString()),
                            fontWeight: FontWeight.w500,
                            foregroundColor: ZupColors.brand,
                            onPressed: () {
                              cubit.filterUserPositions(hideClosedPositions: !cubit.hidingClosedPositions);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ZupPrimaryButton(
                          key: const Key("new-position-button"),
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          fixedIcon: true,
                          hoverElevation: 0,
                          icon: Assets.icons.plus.svg(),
                          title: S.of(context).newPosition,
                          onPressed: () => navigator.navigateToNewPosition(),
                        ),
                      ],
                    ),
                    state.maybeWhen(
                      orElse: () => ZupSkeletonizer(
                        child: buildPositionsState(List.generate(3, (_) => PositionDto.fixture())),
                      ),
                      error: () => buildErrorState(),
                      notConnected: () => buildNotConnectedState(),
                      noPositions: () => buildNoPositionsState(),
                      noPositionsInNetwork: () => buildNoPositionsInNetworkState(),
                      positions: (positions) => buildPositionsState(positions),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildNotConnectedState() => Column(
        children: [
          const SizedBox(height: 150),
          ZupInfoState(
            icon: Assets.icons.walletBifold.svg(
              colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
            ),
            helpButtonSpacing: 12,
            iconSize: 80,
            title: S.of(context).connectYourWallet,
            description: S.of(context).positionsPageNotConnectedDescription,
            helpButtonTitle: S.of(context).connectYourWallet,
            helpButtonIcon: Assets.icons.cableConnectorHorizontal.svg(),
            onHelpButtonTap: () => ConnectModal.show(context, onConnectWallet: (Signer signer) {}),
          )
        ],
      );

  Widget buildNoPositionsState() => Column(
        children: [
          const SizedBox(height: 150),
          ZupInfoState(
            icon: Assets.icons.tray.svg(colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn)),
            helpButtonSpacing: 12,
            iconSize: 80,
            title: S.of(context).positionsPageNoPositionsTitle,
            description: S.of(context).positionsPageNoPositionsDescription,
            helpButtonTitle: S.of(context).createNewPosition,
            helpButtonIcon: Assets.icons.plus.svg(),
            onHelpButtonTap: () => navigator.navigateToNewPosition(),
          )
        ],
      );

  Widget buildNoPositionsInNetworkState() => Column(
        children: [
          const SizedBox(height: 150),
          ZupInfoState(
            icon: appCubit.selectedNetwork.icon,
            helpButtonSpacing: 12,
            iconSize: 120,
            title: S.of(context).positionsPageNoPositionsInNetwork(appCubit.selectedNetwork.label),
            description: S.of(context).positionsPageNoPositionsInNetworkDescription(appCubit.selectedNetwork.label),
            helpButtonTitle: S.of(context).createNewPosition,
            helpButtonIcon: Assets.icons.plus.svg(),
            onHelpButtonTap: () => navigator.navigateToNewPosition(),
          )
        ],
      );

  Widget buildPositionsState(List<PositionDto> positions) => Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: positions.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: PositionCard(key: Key("position-card-$index"), position: positions[index]),
            ),
          ),
          if (appCubit.selectedNetwork != Networks.all)
            Text(
              S.of(context).positionsPageCantFindAPosition,
              style: const TextStyle(
                fontSize: 14,
                color: ZupColors.gray,
              ),
            ),
        ],
      );

  Widget buildErrorState() => Column(
        children: [
          const SizedBox(height: 150),
          ZupInfoState(
            icon: Assets.icons.networkSlash.svg(colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn)),
            helpButtonSpacing: 12,
            iconSize: 80,
            title: S.of(context).somethingWhenWrong,
            description: S.of(context).positionsPageErrorStateDescription,
            helpButtonTitle: S.of(context).letsGiveItAnotherGo,
            helpButtonIcon: Assets.icons.arrowClockwise.svg(),
            onHelpButtonTap: () => cubit.getUserPositions(),
          )
        ],
      );
}
