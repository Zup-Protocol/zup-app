import 'package:flutter/material.dart';
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
    this.onRefreshBalance,
  });

  final TokenDto token;
  final Networks network;
  final TextEditingController controller;
  final Function(double value) onInput;
  final String? disabledText;
  final VoidCallback? onRefreshBalance;

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
    widget.onRefreshBalance,
  );

  final double paddingValue = 20;

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
          padding: EdgeInsets.all(paddingValue).copyWith(left: 0),
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
                            child: ClipRect(
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                children: [
                                  TextField(
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    clipBehavior: Clip.none,
                                    controller: widget.controller,
                                    onChanged: (value) => widget.onInput(double.tryParse(value) ?? 0),
                                    style: const TextStyle(fontSize: 28),
                                    inputFormatters: [
                                      TokenAmountInputFormatter(),
                                    ],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(right: paddingValue + 5, left: paddingValue),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      hintText: "0",
                                      hintStyle: const TextStyle(color: ZupColors.gray5),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Transform.translate(
                                      offset: const Offset(1, 0),
                                      child: Container(
                                        width: 40,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              ZupColors.white,
                                              ZupColors.white.withOpacity(0.8),
                                              ZupColors.white.withOpacity(0.0)
                                            ],
                                            stops: const [0.1, 0.5, 1.0],
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Transform.translate(
                                      offset: const Offset(0, 0),
                                      child: Container(
                                        width: 25,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [ZupColors.white, ZupColors.white.withOpacity(0.0)],
                                            stops: const [0.5, 1.0],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                width: 0.5,
                                color: ZupColors.gray5,
                              ),
                            ),
                            child: PositionToken(token: widget.token),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: paddingValue),
                            child: const Text(
                              r"$-",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: ZupColors.gray),
                            ),
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
                                        ZupRefreshButton(
                                          animationController: refreshBalanceAnimationController,
                                          key: const Key("refresh-balance-button"),
                                          onPressed: () async => state.mapOrNull(
                                            error: (_) async => await userBalanceCubit.getUserTokenAmount(
                                              ignoreCache: true,
                                            ),
                                            showUserBalance: (_) async => await userBalanceCubit.getUserTokenAmount(
                                              ignoreCache: true,
                                            ),
                                          ),
                                        ),
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
