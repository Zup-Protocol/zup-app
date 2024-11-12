// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/deposit/widgets/range_selector.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_card/token_amount_card.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/extensions/bigint_extension.dart';
import 'package:zup_app/core/extensions/list_extension.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/extensions/string_extension.dart';
import 'package:zup_app/core/extensions/widget_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/mixins/v3_pool_liquidity_calculations_mixin.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/v3_pool_constants.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_app/widgets/zup_page_title.dart';
import 'package:zup_core/zup_singleton_cache.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, a1, a2) => const DepositPage(),
    transitionsBuilder: (_, a1, a2, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(a1),
      child: FadeTransition(opacity: a1, child: child),
    ),
  );
}

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> with V3PoolConversorsMixin, V3PoolLiquidityCalculationsMixin {
  final navigator = inject<ZupNavigator>();
  late final token0Address = navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param0) ?? "";
  late final token1Address = navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param1) ?? "";
  final wallet = inject<Wallet>();
  final uniswapV3Pool = inject<UniswapV3Pool>();
  final cacher = inject<ZupSingletonCache>();
  final yieldRepository = inject<YieldRepository>();
  final lottieClick = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieClick);
  final lottieGhost = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieGhost);

  final token0AmountController = TextEditingController();
  final token1AmountController = TextEditingController();
  final selectRangeSectionKey = GlobalKey();
  bool userSetToken0Amount = false;

  YieldDto? selectedYield;
  TokenDto? baseToken;

  BigInt tickLower = V3PoolConstants.minTick;
  BigInt tickUpper = V3PoolConstants.maxTick;

  DepositCubit _cubit(BuildContext context) => context.read<DepositCubit>();

  TokenDto quoteToken() {
    assert(selectedYield != null, "Selected yield should not be null to access secondary token");

    if (baseToken == selectedYield!.token1) return selectedYield!.token0;
    return selectedYield!.token1;
  }

  bool get isRangeInvalid {
    if (tickUpper == V3PoolConstants.maxTick || tickLower == V3PoolConstants.minTick) return false;

    return (tickUpper) >= (tickLower);
  }

  Future<({bool enabled, String text})> depositButtonState(BuildContext context) async {
    final token0Amount = double.tryParse(token0AmountController.text) ?? 0;
    final token1Amount = double.tryParse(token1AmountController.text) ?? 0;

    if (isRangeInvalid) return (enabled: false, text: "Invalid Range");

    if ((await isOutOfRange(context)).minRange && token0AmountController.text.isEmptyOrZero) {
      return (
        enabled: false,
        text: S.of(context).depositPageInvalidTokenAmount(selectedYield!.token0.symbol),
      );
    }

    if ((await isOutOfRange(context)).maxRange && token1AmountController.text.isEmptyOrZero) {
      return (
        enabled: false,
        text: S.of(context).depositPageInvalidTokenAmount(selectedYield!.token1.symbol),
      );
    }

    if (context.mounted &&
        await _cubit(context).getWalletTokenAmount(baseToken!.address, network: selectedYield!.network) <
            token0Amount) {
      return (
        enabled: false,
        text: S.of(context).depositPageInsufficientTokenBalance(baseToken!.symbol),
      );
    }

    if (context.mounted &&
        await _cubit(context).getWalletTokenAmount(quoteToken().address, network: selectedYield!.network) <
            token1Amount) {
      return (
        enabled: false,
        text: S.of(context).depositPageInsufficientTokenBalance(quoteToken().symbol),
      );
    }

    if (context.mounted && token0AmountController.text.isEmptyOrZero && (await isToken0Needed(context))) {
      return (
        enabled: false,
        text: S.of(context).depositPagePleaseEnterAmountForToken(selectedYield!.token0.symbol),
      );
    }

    if (context.mounted && token1AmountController.text.isEmptyOrZero && (await isToken1Needed(context))) {
      return (
        enabled: false,
        text: S.of(context).depositPagePleaseEnterAmountForToken(selectedYield!.token1.symbol),
      );
    }

    return (
      enabled: token0AmountController.text.isNotEmptyOrZero || token1AmountController.text.isNotEmptyOrZero,
      text: S.of(context).depositPageDeposit,
    );
  }

  Future<({bool minRange, bool maxRange, bool any})> isOutOfRange(BuildContext context) async {
    if (selectedYield == null) return (minRange: false, maxRange: false, any: false);

    final currentPriceTick = await _cubit(context).getPoolTick(selectedYield!.network, selectedYield!.poolAddress);

    final currentPrice = tickToPrice(
      token0Decimals: selectedYield!.token0.decimals,
      token1Decimals: selectedYield!.token1.decimals,
      tick: currentPriceTick,
      asToken0byToken1: baseToken == selectedYield!.token0,
    );

    final minRangePrice = tickToPrice(
      token0Decimals: selectedYield!.token0.decimals,
      token1Decimals: selectedYield!.token1.decimals,
      tick: tickLower,
      asToken0byToken1: tickLower.isMinTick,
    );

    final maxRangePrice = tickToPrice(
      token0Decimals: selectedYield!.token0.decimals,
      token1Decimals: selectedYield!.token1.decimals,
      tick: tickUpper,
      asToken0byToken1: tickUpper.isMaxTick,
    );

    return (
      minRange: minRangePrice > currentPrice,
      maxRange: maxRangePrice < currentPrice,
      any: (minRangePrice > currentPrice) || (maxRangePrice < currentPrice),
    );
  }

  Future<bool> isToken0Needed(BuildContext context) async {
    return !((await isOutOfRange(context)).maxRange);
  }

  Future<bool> isToken1Needed(BuildContext context) async {
    return !((await isOutOfRange(context)).minRange);
  }

  void resetInputs() {
    tickUpper = V3PoolConstants.maxTick;
    tickLower = V3PoolConstants.minTick;
    token0AmountController.clear();
    token1AmountController.clear();
  }

  void calculateTokensAmount(BuildContext context) async {
    final token0Amount = double.tryParse(token0AmountController.text) ?? 0;
    final token1Amount = double.tryParse(token1AmountController.text) ?? 0;
    final currentTick = await _cubit(context).getPoolTick(selectedYield!.network, selectedYield!.poolAddress);

    if (context.mounted && (await isOutOfRange(context)).minRange) {
      return setState(() => token1AmountController.clear());
    }

    if (context.mounted && (await isOutOfRange(context)).maxRange) {
      return setState(() => token0AmountController.clear());
    }

    final token0NewAmount = calculateTokenYAmountFromTokenX(
      token1Amount,
      tickToPrice(
        token0Decimals: selectedYield!.token0.decimals,
        token1Decimals: selectedYield!.token1.decimals,
        tick: currentTick,
        asToken0byToken1: baseToken == selectedYield!.token1,
      ),
      tickToPrice(
        token0Decimals: selectedYield!.token0.decimals,
        token1Decimals: selectedYield!.token1.decimals,
        tick: tickUpper,
        asToken0byToken1: !(tickUpper.isMaxTick),
      ),
      tickToPrice(
        token0Decimals: selectedYield!.token0.decimals,
        token1Decimals: selectedYield!.token1.decimals,
        tick: tickLower,
        asToken0byToken1: !(tickLower.isMinTick),
      ),
    );

    final token1NewAmount = calculateTokenYAmountFromTokenX(
      token0Amount,
      tickToPrice(
        token0Decimals: selectedYield!.token0.decimals,
        token1Decimals: selectedYield!.token1.decimals,
        tick: currentTick,
        asToken0byToken1: baseToken == selectedYield!.token0,
      ),
      tickToPrice(
        token0Decimals: selectedYield!.token0.decimals,
        token1Decimals: selectedYield!.token1.decimals,
        tick: tickLower,
        asToken0byToken1: tickLower.isMinTick,
      ),
      tickToPrice(
        token0Decimals: selectedYield!.token0.decimals,
        token1Decimals: selectedYield!.token1.decimals,
        tick: tickUpper,
        asToken0byToken1: tickUpper.isMaxTick,
      ),
    );

    if (userSetToken0Amount) {
      return setState(() {
        token1NewAmount == 0
            ? token1AmountController.clear()
            : token1AmountController.text = token1NewAmount.toStringAsFixed(8);
      });
    }

    return setState(() {
      token0NewAmount == 0
          ? token0AmountController.clear()
          : token0AmountController.text = token0NewAmount.toStringAsFixed(8);
    });
  }

  void selectYield(YieldDto? yield) {
    setState(() {
      selectedYield = yield;

      if (yield == null) return resetInputs();

      if (yield.token1.symbol == baseToken?.symbol) {
        baseToken = yield.token1;

        return;
      }

      baseToken = yield.token0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectRangeSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          selectRangeSectionKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastEaseInToSlowEaseOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return DepositCubit(yieldRepository, cacher, wallet, uniswapV3Pool)
          ..getBestPools(token0Address: token0Address, token1Address: token1Address);
      },
      child: BlocBuilder<DepositCubit, DepositState>(
        builder: (cubitContext, state) => state.maybeWhen(
          orElse: () => buildLoadingState(),
          error: () => buildErrorState(cubitContext),
          noYields: () => buildEmptyState(),
          success: (yields) => buildSuccessState(cubitContext, yields),
        ),
      ),
    );
  }

  Widget buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: ZupSteppedLoading(
          steps: [
            ZupSteppedLoadingStep(
              title: S.of(context).depositPageLoadingStep1Title,
              description: S.of(context).depositPageLoadingStep1Description,
              icon: Assets.lotties.matching.lottie(fit: BoxFit.cover),
              iconSize: 200,
            ),
            ZupSteppedLoadingStep(
              title: S.of(context).depositPageLoadingStep2Title,
              description: S.of(context).depositPageLoadingStep2Description,
              icon: Assets.lotties.radar.lottie(),
              iconSize: 200,
            ),
            ZupSteppedLoadingStep(
              title: S.of(context).depositPageLoadingStep3Title,
              description: S.of(context).depositPageLoadingStep3Description,
              icon: Assets.lotties.seaching.lottie(fit: BoxFit.cover),
              iconSize: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
        child: SizedBox(
      width: 400,
      child: ZupInfoState(
        icon: lottieGhost,
        iconSize: 120,
        title: S.of(context).depositPageEmptyStateTitle,
        description: S.of(context).depositPageEmptyStateDescription,
        helpButtonTitle: S.of(context).depositPageEmptyStateHelpButtonTitle,
        helpButtonIcon: Assets.icons.arrowLeft.svg(),
        onHelpButtonTap: () => navigator.navigateToNewPosition(),
      ),
    ));
  }

  Widget buildErrorState(BuildContext context) => Center(
        child: SizedBox(
          width: 400,
          child: ZupInfoState(
            icon: const Text(":(", style: TextStyle(color: ZupColors.brand)),
            title: S.of(context).depositPageErrorStateTitle,
            description: S.of(context).depositPageErrorStateDescription,
            helpButtonTitle: S.of(context).letsGiveItAnotherShot,
            helpButtonIcon: Assets.icons.arrowClockwise.svg(),
            onHelpButtonTap: () => _cubit(context).getBestPools(
              token0Address: token0Address,
              token1Address: token1Address,
            ),
          ),
        ),
      );

  Widget buildSuccessState(BuildContext context, YieldsDto yields) {
    final best24hYield = yields.last24Yields.bestYield;
    final best30dYield = yields.last30dYields.bestYield;
    final best90dYield = yields.last90dYields.bestYield;

    Widget sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600));

    void setFullRange() {
      setState(() {
        tickLower = V3PoolConstants.minTick;
        tickUpper = V3PoolConstants.maxTick;
      });

      calculateTokensAmount(context);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZupTextButton(
                  key: const Key("back-button"),
                  onPressed: () => navigator.back(context),
                  icon: Assets.icons.arrowLeft.svg(),
                  label: S.of(context).depositPageBackButtonTitle,
                ),
                ZupPageTitle(S.of(context).depositPageTitle),
                const SizedBox(height: 16),
                ZupTooltip(
                  key: const Key("timeframe-tooltip"),
                  message: S.of(context).depositPageTimeFrameTooltipMessage,
                  helperButtonTitle: S.of(context).depositPageTimeFrameTooltipHelperButtonTitle,
                  helperButtonOnPressed: () {
                    // launchUrl(Uri.parse("https://docs.thirdweb.com/zap/liquidity-mining/"));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      sectionTitle(S.of(context).depositPageTimeFrameTitle),
                      const SizedBox(width: 8),
                      Assets.icons.infoCircle.svg(
                        colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    YieldCard(
                      key: const Key("best-24h-yield-card"),
                      yield: best24hYield,
                      onSelect: (yield) => selectYield(yield),
                      isSelected: best24hYield == selectedYield,
                      timeFrame: YieldTimeFrame.day,
                    ),
                    const SizedBox(width: 10),
                    YieldCard(
                      key: const Key("best-30d-yield-card"),
                      yield: best30dYield,
                      timeFrame: YieldTimeFrame.month,
                      onSelect: (yield) => selectYield(yield),
                      isSelected: best30dYield == selectedYield,
                    ),
                    const SizedBox(width: 10),
                    YieldCard(
                      key: const Key("best-90d-yield-card"),
                      onSelect: (yield) => selectYield(yield),
                      isSelected: best90dYield == selectedYield,
                      timeFrame: YieldTimeFrame.threeMonth,
                      yield: best90dYield,
                    ),
                    // const SizedBox(width: 10),
                    // ZupIconButton(
                    //   padding: const EdgeInsets.all(12),
                    //   icon: Assets.icons.chevronRight.svg(),
                    //   onPressed: () {},
                    // )
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(thickness: 0.5, color: ZupColors.gray5),
                const SizedBox(height: 40),
                if (selectedYield == null) ...[
                  Center(
                    child: ZupInfoState(
                      iconSize: 90,
                      icon: lottieClick,
                      title: S.of(context).depositPageNoYieldSelectedTitle,
                      description: S.of(context).depositPageNoYieldSelectedDescription,
                    ),
                  )
                ] else ...[
                  Row(
                    key: selectRangeSectionKey,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      sectionTitle(S.of(context).depositPageRangeSectionTitle),
                      const SizedBox(width: 20),
                      ZupTextButton(
                        key: const Key("full-range-button"),
                        onPressed: () => setFullRange(),
                        label: S.of(context).depositPageRangeSectionFullRange,
                        icon: Assets.icons.circleDotted.svg(),
                      ),
                      const Spacer(),
                      if (selectedYield != null)
                        SizedBox(
                          width: 240,
                          child: CupertinoSlidingSegmentedControl(
                            padding: const EdgeInsets.all(0),
                            groupValue: baseToken,
                            children: {
                              selectedYield!.token0: InkWell(
                                key: const Key("base-token-selector"),
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() => baseToken = selectedYield!.token0);
                                  calculateTokensAmount(context);
                                },
                                child: SizedBox(
                                  height: 30,
                                  width: 120,
                                  child: Center(
                                    child: Text("${selectedYield!.token0.symbol} / ${selectedYield!.token1.symbol}"),
                                  ),
                                ),
                              ),
                              selectedYield!.token1: InkWell(
                                key: const Key("quote-token-selector"),
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() => baseToken = selectedYield!.token1);
                                  calculateTokensAmount(context);
                                },
                                child: SizedBox(
                                  height: 30,
                                  width: 120,
                                  child: Center(
                                    child: Text("${selectedYield!.token1.symbol} / ${selectedYield!.token0.symbol}"),
                                  ),
                                ),
                              ),
                            },
                            onValueChanged: (value) {},
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 5),
                  FutureBuilder(
                    future: _cubit(context).getPoolTick(
                      selectedYield!.network,
                      selectedYield!.poolAddress,
                    ),
                    builder: (context, snapshot) {
                      return Text(
                        key: const Key("token-price"),
                        "1 ${baseToken?.symbol} ~ ${snapshot.hasError ? "???" : tickToPrice(
                            token0Decimals: selectedYield!.token0.decimals,
                            token1Decimals: selectedYield!.token1.decimals,
                            tick: snapshot.data ?? BigInt.from(0),
                            asToken0byToken1: baseToken == selectedYield!.token0,
                          ).toAmount()} ${quoteToken().symbol}",
                      ).redacted(
                        enabled: snapshot.connectionState != ConnectionState.done,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder(
                      future: isOutOfRange(context),
                      builder: (context, isOutOfRangeSnapshot) {
                        return RangeSelector(
                          key: const Key("min-range-selector"),
                          state: RangeSelectorState(
                            helperText: S.of(context).depositPageMinRangeOutOfRangeWarningText,
                            type: (isOutOfRangeSnapshot.data?.minRange ?? false)
                                ? RangeSelectorStateType.warning
                                : RangeSelectorStateType.regular,
                          ),
                          onRangeChanged: (value) async {
                            setState(() => tickLower = value);
                            calculateTokensAmount(context);
                          },
                          pooltoken0Decimals: selectedYield!.token0.decimals,
                          pooltoken1Decimals: selectedYield!.token1.decimals,
                          poolTickSpacing: selectedYield!.tickSpacing,
                          isInfinity: tickLower.isMinTick,
                          baseTokenSymbol: baseToken?.symbol ?? "",
                          quoteTokenSymbol: quoteToken().symbol,
                          type: RangeSelectorType.minRange,
                        );
                      }),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: isOutOfRange(context),
                    builder: (context, isOutOfRangeSnapshot) {
                      RangeSelectorState getRangeSelectorState() {
                        if (isRangeInvalid) {
                          return RangeSelectorState(
                            type: RangeSelectorStateType.error,
                            helperText: S.of(context).depositPageInvalidRangeErrorText,
                          );
                        }

                        if (isOutOfRangeSnapshot.data?.maxRange ?? false) {
                          return RangeSelectorState(
                            type: RangeSelectorStateType.warning,
                            helperText: S.of(context).depositPageMaxRangeOutOfRangeWarningText,
                          );
                        }

                        return const RangeSelectorState(type: RangeSelectorStateType.regular);
                      }

                      return RangeSelector(
                        key: const Key("max-range-selector"),
                        pooltoken0Decimals: selectedYield!.token0.decimals,
                        pooltoken1Decimals: selectedYield!.token1.decimals,
                        state: getRangeSelectorState(),
                        poolTickSpacing: selectedYield!.tickSpacing,
                        isInfinity: tickUpper.isMaxTick,
                        onRangeChanged: (value) {
                          setState(() => tickUpper = value);
                          calculateTokensAmount(context);
                        },
                        type: RangeSelectorType.maxRange,
                        baseTokenSymbol: baseToken?.symbol ?? "",
                        quoteTokenSymbol: quoteToken().symbol,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  IgnorePointer(
                    ignoring: isRangeInvalid,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: !isRangeInvalid ? 1 : 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          sectionTitle(S.of(context).depositPageDepositSectionTitle),
                          const SizedBox(height: 20),
                          FutureBuilder(
                              future: isToken0Needed(context),
                              builder: (context, isToken0NeededSnapshot) {
                                return TokenAmountCard(
                                  key: const Key("token-0-amount-card"),
                                  network: selectedYield!.network,
                                  controller: token0AmountController,
                                  disabledText: isToken0NeededSnapshot.data ?? true
                                      ? null
                                      : S.of(context).depositPageDepositSectionTokenNotNeeded(baseToken!.symbol),
                                  onInput: (input) {
                                    userSetToken0Amount = true;
                                    calculateTokensAmount(context);
                                  },
                                  token: baseToken ?? TokenDto.empty(),
                                );
                              }),
                          const SizedBox(height: 10),
                          FutureBuilder(
                              future: isToken1Needed(context),
                              builder: (context, isToken1NeededSnapshot) {
                                return TokenAmountCard(
                                  key: const Key("token-1-amount-card"),
                                  network: selectedYield!.network,
                                  disabledText: isToken1NeededSnapshot.data ?? true
                                      ? null
                                      : S.of(context).depositPageDepositSectionTokenNotNeeded(quoteToken().symbol),
                                  controller: token1AmountController,
                                  onInput: (input) {
                                    userSetToken0Amount = false;
                                    calculateTokensAmount(context);
                                  },
                                  token: quoteToken(),
                                );
                              }),
                          const SizedBox(height: 20),
                          StreamBuilder(
                            key: const Key("deposit-button"),
                            stream: wallet.signerStream,
                            initialData: wallet.signer,
                            builder: (context, signerSnapshot) {
                              return signerSnapshot.data != null
                                  ? FutureBuilder(
                                      future: depositButtonState(context),
                                      builder: (context, depositStateSnapshot) => ZupPrimaryButton(
                                        width: double.infinity,
                                        icon: Assets.icons.paperplaneFill.svg(),
                                        fixedIcon: true,
                                        title: depositStateSnapshot.data?.text ?? S.of(context).loading,
                                        onPressed: (depositStateSnapshot.data?.enabled ?? false) ? () {} : null,
                                      ),
                                    )
                                  : ZupPrimaryButton(
                                      width: double.infinity,
                                      icon: Assets.icons.cableConnectorHorizontal.svg(),
                                      fixedIcon: true,
                                      title: S.of(context).connectWallet,
                                      onPressed: () => ConnectModal.show(context),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
