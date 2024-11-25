import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_input_card/token_amount_input_card_user_balance_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/extensions/widget_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/token_amount_input_formatter.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/position_token.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TokenAmountInputCard extends StatefulWidget {
  const TokenAmountInputCard({
    super.key,
    required this.token,
    required this.onInput,
    required this.controller,
    this.disabledText,
    required this.network,
  });

  final TokenDto token;
  final Networks network;
  final TextEditingController controller;
  final Function(double value) onInput;
  final String? disabledText;

  @override
  State<TokenAmountInputCard> createState() => _TokenAmountInputCardState();
}

class _TokenAmountInputCardState extends State<TokenAmountInputCard> with SingleTickerProviderStateMixin {
  AnimationController? refreshBalanceAnimationController;

  Wallet get wallet => inject<Wallet>();
  ZupSingletonCache get zupSingletonCache => inject<ZupSingletonCache>();

  late final TokenAmountCardUserBalanceCubit userBalanceCubit = TokenAmountCardUserBalanceCubit(
    wallet,
    widget.token.address,
    widget.network,
    zupSingletonCache,
  );

  @override
  void initState() {
    refreshBalanceAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    WidgetsBinding.instance.addPostFrameCallback((tester) {
      if (wallet.signer != null) userBalanceCubit.getUserTokenAmount();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TokenAmountInputCard oldWidget) {
    if (widget.token != oldWidget.token) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userBalanceCubit.updateToken(widget.token.address);
      });

      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 0.5, color: ZupColors.gray5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.disabledText != null)
                Text(
                  widget.disabledText!,
                  style: const TextStyle(color: ZupColors.gray, fontSize: 14),
                ),
              IgnorePointer(
                ignoring: widget.disabledText != null,
                child: AnimatedOpacity(
                  opacity: widget.disabledText == null ? 1 : 0.05,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.controller,
                              onChanged: (value) => widget.onInput(double.tryParse(value) ?? 0),
                              style: const TextStyle(fontSize: 28),
                              inputFormatters: [
                                TokenAmountInputFormatter(),
                              ],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "0",
                                hintStyle: TextStyle(color: ZupColors.gray5),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 0.5,
                                color: ZupColors.gray5,
                              ),
                            ),
                            child: PositionToken(
                              tokenSymbol: widget.token.symbol,
                              tokenLogoUrl: widget.token.logoUrl,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            r"$-",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ZupColors.gray),
                          ),
                          const Spacer(),
                          BlocProvider.value(
                            value: userBalanceCubit,
                            child: BlocConsumer<TokenAmountCardUserBalanceCubit, TokenAmountCardUserBalanceState>(
                              listener: (context, state) {
                                state.maybeWhen(
                                  orElse: () => refreshBalanceAnimationController?.forward(),
                                  loadingUserBalance: () => refreshBalanceAnimationController?.repeat(),
                                );
                              },
                              builder: (context, state) {
                                return state.maybeWhen(
                                  hideUserBalance: () => const SizedBox.shrink(),
                                  orElse: () => Center(
                                    child: Row(
                                      children: [
                                        ZupTextButton(
                                          key: const Key("user-balance-button"),
                                          onPressed: () {
                                            final userBalance = userBalanceCubit.userBalance;

                                            if (userBalance == 0) return;

                                            widget.controller.text = userBalance.toString();
                                            widget.onInput(userBalance);
                                          },
                                          alignLeft: false,
                                          icon: Assets.icons.walletBifold.svg(),
                                          label: state.maybeWhen(
                                            orElse: () => userBalanceCubit.userBalance.toAmount(
                                              useLessThan: true,
                                            ),
                                            loadingUserBalance: () => "........",
                                            error: () => "Error",
                                          ),
                                        ).redacted(
                                          enabled: state.maybeWhen(
                                            orElse: () => false,
                                            loadingUserBalance: () => true,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        ZupIconButton(
                                          key: const Key("refresh-balance-button"),
                                          backgroundColor: Colors.transparent,
                                          icon: Assets.icons.arrowClockwise.svg(),
                                          onPressed: () => state.mapOrNull(
                                            error: (_) => userBalanceCubit.getUserTokenAmount(ignoreCache: true),
                                            showUserBalance: (_) => userBalanceCubit.getUserTokenAmount(
                                              ignoreCache: true,
                                            ),
                                          ),
                                        ).animate(
                                            autoPlay: false,
                                            controller: refreshBalanceAnimationController,
                                            effects: [
                                              const RotateEffect(
                                                duration: Duration(milliseconds: 500),
                                                begin: 0,
                                                end: 1,
                                              )
                                            ])
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
