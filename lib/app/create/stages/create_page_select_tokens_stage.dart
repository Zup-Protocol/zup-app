import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';
import 'package:zup_app/widgets/zup_page_title.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class CreatePageSelectTokensStage extends StatefulWidget {
  const CreatePageSelectTokensStage({super.key});

  @override
  State<CreatePageSelectTokensStage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePageSelectTokensStage> {
  final appCubit = inject<AppCubit>();

  late final tokenASelectorController = TokenSelectorButtonController(
    initialSelectedToken: appCubit.selectedNetwork.defaultToken,
  );
  final tokenBSelectorController = TokenSelectorButtonController(initialSelectedToken: null);
  StreamSubscription? _tokenASelectorStreamSubscription;
  StreamSubscription? _tokenBSelectorStreamSubscription;

  bool areTokensEqual(TokenDto? tokenA, TokenDto? tokenB) {
    if (tokenA == null || tokenB == null) return false;
    if (tokenA.address == tokenB.address) return true;

    return false;
  }

  @override
  void initState() {
    _tokenASelectorStreamSubscription = tokenASelectorController.selectedTokenStream.listen((token) {
      if (areTokensEqual(token, tokenBSelectorController.selectedToken)) {
        return tokenBSelectorController.changeToken(null);
      }
    });

    _tokenBSelectorStreamSubscription = tokenBSelectorController.selectedTokenStream.listen((token) {
      if (areTokensEqual(token, tokenASelectorController.selectedToken)) {
        return tokenASelectorController.changeToken(null);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tokenASelectorStreamSubscription?.cancel();
    _tokenBSelectorStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, bottom: 50),
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
                  S.of(context).tokenA,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ZupColors.gray,
                  ),
                ),
                const SizedBox(height: 5),
                TokenSelectorButton(
                  key: const Key("token-a-selector"),
                  controller: tokenASelectorController,
                ),
                const SizedBox(height: 10),
                Text(
                  S.of(context).tokenB,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ZupColors.gray,
                  ),
                ),
                const SizedBox(height: 5),
                TokenSelectorButton(
                  key: const Key("token-b-selector"),
                  controller: tokenBSelectorController,
                ),
                const SizedBox(height: 20),
                StreamBuilder(
                    stream: tokenASelectorController.selectedTokenStream,
                    builder: (context, _) {
                      return StreamBuilder(
                        stream: tokenBSelectorController.selectedTokenStream,
                        builder: (context, _) {
                          return ZupPrimaryButton(
                            height: 50,
                            fixedIcon: true,
                            alignCenter: true,
                            title: S.of(context).createPageShowMeTheMoney,
                            foregroundColor: ZupColors.white,
                            icon: Assets.icons.sparkleMagnifyingglass.svg(),
                            onPressed: tokenASelectorController.selectedToken != null &&
                                    tokenBSelectorController.selectedToken != null
                                ? () {}
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
