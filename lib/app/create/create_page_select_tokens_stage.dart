import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';
import 'package:zup_app/widgets/zup_page_title.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class CreatePageSelectTokensStage extends StatefulWidget {
  const CreatePageSelectTokensStage({super.key});

  @override
  State<CreatePageSelectTokensStage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePageSelectTokensStage> with DeviceInfoMixin {
  final appCubit = inject<AppCubit>();
  final navigator = inject<ZupNavigator>();

  late final token0SelectorController = TokenSelectorButtonController(
    initialSelectedToken: appCubit.selectedNetwork.wrappedNative,
  );
  final token1SelectorController = TokenSelectorButtonController(initialSelectedToken: null);
  StreamSubscription? _token0SelectorStreamSubscription;
  StreamSubscription? _token1SelectorStreamSubscription;

  bool areTokensEqual(TokenDto? token0, TokenDto? token1) {
    if (token0 == null || token1 == null) return false;
    if (token0.address == token1.address) return true;

    return false;
  }

  @override
  void initState() {
    _token0SelectorStreamSubscription = token0SelectorController.selectedTokenStream.listen((token) {
      if (areTokensEqual(token, token1SelectorController.selectedToken)) {
        return token1SelectorController.changeToken(null);
      }
    });

    _token1SelectorStreamSubscription = token1SelectorController.selectedTokenStream.listen((token) {
      if (areTokensEqual(token, token0SelectorController.selectedToken)) {
        return token0SelectorController.changeToken(null);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _token0SelectorStreamSubscription?.cancel();
    _token1SelectorStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isMobileSize(context) ? 20 : 70,
        bottom: 50,
        left: isMobileSize(context) ? 20 : 0,
        right: isMobileSize(context) ? 20 : 0,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 490),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZupPageTitle(S.of(context).createPageTitle),
                Text(
                  S.of(context).createPageDescription,
                  style: const TextStyle(fontSize: 14, color: ZupColors.gray),
                ),
                const SizedBox(height: 20),
                Text(
                  S.of(context).token0,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ZupColors.gray,
                  ),
                ),
                const SizedBox(height: 5),
                TokenSelectorButton(
                  key: const Key("token-a-selector"),
                  controller: token0SelectorController,
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).token1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ZupColors.gray,
                  ),
                ),
                const SizedBox(height: 5),
                TokenSelectorButton(
                  key: const Key("token-b-selector"),
                  controller: token1SelectorController,
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                    stream: token0SelectorController.selectedTokenStream,
                    builder: (context, _) {
                      return StreamBuilder(
                        stream: token1SelectorController.selectedTokenStream,
                        builder: (context, _) {
                          return ZupPrimaryButton(
                            height: 50,
                            fixedIcon: true,
                            alignCenter: true,
                            title: S.of(context).createPageShowMeTheMoney,
                            foregroundColor: ZupColors.white,
                            icon: Assets.icons.sparkleMagnifyingglass.svg(),
                            onPressed: token0SelectorController.selectedToken != null &&
                                    token1SelectorController.selectedToken != null
                                ? () => navigator.navigateToDeposit(
                                      token0SelectorController.selectedToken!.address,
                                      token1SelectorController.selectedToken!.address,
                                    )
                                : null,
                            mainAxisSize: MainAxisSize.max,
                          );
                        },
                      );
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
