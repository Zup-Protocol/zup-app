import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/deposit/widgets/range_selector.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_input_card/token_amount_input_card.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
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
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_core/zup_singleton_cache.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, a1, a2) => BlocProvider(
      create: (context) => DepositCubit(
        inject<YieldRepository>(),
        inject<ZupSingletonCache>(),
        inject<Wallet>(),
        inject<UniswapV3Pool>(),
      ),
      child: const DepositPage(),
    ),
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
  final lottieClick = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieClick);
  final lottieEmpty = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieEmpty);
  final lottieRadar = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieRadar);
  final lottieMatching = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieMatching);
  final lottieSearching = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieSearching);

  final baseTokenAmountController = TextEditingController();
  final quoteTokenAmountController = TextEditingController();
  final wallet = inject<Wallet>();
  final selectRangeSectorKey = GlobalKey();

  ZupNavigator get _navigator => inject<ZupNavigator>();
  DepositCubit get _cubit => context.read<DepositCubit>();
  String get token0Address => _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName?.param0 ?? "") ?? "";
  String get token1Address => _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName?.param1 ?? "") ?? "";
  TokenDto get baseToken => areTokensReversed ? _cubit.selectedYield!.token1 : _cubit.selectedYield!.token0;
  TokenDto get quoteToken => areTokensReversed ? _cubit.selectedYield!.token0 : _cubit.selectedYield!.token1;

  bool areTokensReversed = false;
  bool isMaxRangeInfinity = true;
  bool isMinRangeInfinity = true;
  bool isBaseTokenAmountUserInput = false;
  double minPrice = 0;
  double maxPrice = 0;

  bool get isRangeInvalid {
    if (isMaxRangeInfinity || isMinRangeInfinity) return false;

    return (minPrice) >= (maxPrice);
  }

  bool get isBaseTokenNeeded => !isOutOfRange.maxPrice;

  bool get isQuoteTokenNeeded => !isOutOfRange.minPrice;

  double get currentPrice {
    if (_cubit.latestPoolTick == null || _cubit.selectedYield == null) return 0;

    final price = tickToPrice(
      tick: _cubit.latestPoolTick!,
      poolToken0Decimals: _cubit.selectedYield!.token0.decimals,
      poolToken1Decimals: _cubit.selectedYield!.token1.decimals,
    );

    return areTokensReversed ? price.priceAsQuoteToken : price.priceAsBaseToken;
  }

  ({bool minPrice, bool maxPrice, bool any}) get isOutOfRange {
    if (_cubit.latestPoolTick == null) return (minPrice: false, maxPrice: false, any: false);

    final isMinPriceOutOfRange = !isMinRangeInfinity && (minPrice) > currentPrice;
    final isMaxPriceOutOfRanfe = !isMaxRangeInfinity && (maxPrice) < currentPrice;

    return (
      minPrice: isMinPriceOutOfRange,
      maxPrice: isMaxPriceOutOfRanfe,
      any: isMinPriceOutOfRange || isMaxPriceOutOfRanfe
    );
  }

  void setFullRange() {
    setState(() {
      isMinRangeInfinity = true;
      isMaxRangeInfinity = true;
    });

    calculateDepositTokensAmount();
  }

  void selectYield(YieldDto? yieldDto) async {
    _cubit.selectYield(yieldDto).then((_) => calculateDepositTokensAmount());

    if (yieldDto != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectRangeSectorKey.currentContext != null) {
          Scrollable.ensureVisible(
            selectRangeSectorKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastEaseInToSlowEaseOut,
          );
        }
      });
    }
  }

  void switchTokens(bool isReversed) {
    setState(() => areTokensReversed = isReversed);

    final currentBaseTokenDepositAmount = baseTokenAmountController.text;
    final currentQuoteTokenDepositAmount = quoteTokenAmountController.text;

    baseTokenAmountController.text = currentQuoteTokenDepositAmount;
    quoteTokenAmountController.text = currentBaseTokenDepositAmount;
    isBaseTokenAmountUserInput = isReversed && !isBaseTokenAmountUserInput;

    calculateDepositTokensAmount();
  }

  void calculateDepositTokensAmount() {
    if (_cubit.latestPoolTick == null || _cubit.selectedYield == null) return;

    if (isOutOfRange.minPrice) return quoteTokenAmountController.clear();
    if (isOutOfRange.maxPrice) return baseTokenAmountController.clear();

    final maxTickPrice = tickToPrice(
      tick: V3PoolConstants.maxTick,
      poolToken0Decimals: _cubit.selectedYield!.token0.decimals,
      poolToken1Decimals: _cubit.selectedYield!.token1.decimals,
    );

    final minTickPrice = tickToPrice(
      tick: V3PoolConstants.minTick,
      poolToken0Decimals: _cubit.selectedYield!.token0.decimals,
      poolToken1Decimals: _cubit.selectedYield!.token1.decimals,
    );

    double getMinPrice() {
      if (minPrice != 0 && !isMinRangeInfinity) return minPrice;

      return areTokensReversed ? maxTickPrice.priceAsQuoteToken : minTickPrice.priceAsBaseToken;
    }

    double getMaxPrice() {
      if (maxPrice != 0 && !isMaxRangeInfinity) return maxPrice;

      return areTokensReversed ? minTickPrice.priceAsQuoteToken : maxTickPrice.priceAsBaseToken;
    }

    final newQuoteTokenAmount = calculateToken1AmountFromToken0(
      double.tryParse(baseTokenAmountController.text) ?? 0,
      currentPrice,
      getMinPrice(),
      getMaxPrice(),
    ).toString();

    final newBaseTokenAmount = calculateToken0AmountFromToken1(
      double.tryParse(quoteTokenAmountController.text) ?? 0,
      currentPrice,
      getMinPrice(),
      getMaxPrice(),
    ).toString();

    if (isBaseTokenAmountUserInput) {
      if (newQuoteTokenAmount.isEmptyOrZero) return quoteTokenAmountController.clear();
      quoteTokenAmountController.text = newQuoteTokenAmount;

      return;
    }

    if (newBaseTokenAmount.isEmptyOrZero) return baseTokenAmountController.clear();
    baseTokenAmountController.text = newBaseTokenAmount;
  }

  Future<({String title, Widget? icon, Function()? onPressed})> depositButtonState() async {
    final userWalletBaseTokenAmount = await _cubit.getWalletTokenAmount(
      baseToken.address,
      network: _cubit.selectedYield!.network,
    );

    final userWalletQuoteTokenAmount = await _cubit.getWalletTokenAmount(
      quoteToken.address,
      network: _cubit.selectedYield!.network,
    );

    if (isRangeInvalid) return (title: S.of(context).depositPageInvalidRange, icon: null, onPressed: null);

    if (isBaseTokenNeeded && baseTokenAmountController.text.isEmptyOrZero) {
      return (title: S.of(context).depositPageInvalidTokenAmount(baseToken.symbol), icon: null, onPressed: null);
    }

    if (isQuoteTokenNeeded && quoteTokenAmountController.text.isEmptyOrZero) {
      return (title: S.of(context).depositPageInvalidTokenAmount(quoteToken.symbol), icon: null, onPressed: null);
    }

    if (userWalletBaseTokenAmount < (double.tryParse(baseTokenAmountController.text) ?? 0) && isBaseTokenNeeded) {
      return (title: S.of(context).depositPageInsufficientTokenBalance(baseToken.symbol), icon: null, onPressed: null);
    }

    if (userWalletQuoteTokenAmount < (double.tryParse(quoteTokenAmountController.text) ?? 0) && isQuoteTokenNeeded) {
      return (title: S.of(context).depositPageInsufficientTokenBalance(quoteToken.symbol), icon: null, onPressed: null);
    }

    return (title: S.of(context).preview, icon: Assets.icons.scrollFill.svg(), onPressed: () {});
  }

  @override
  void initState() {
    _cubit.setup();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getBestPools(token0Address: token0Address, token1Address: token1Address);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DepositCubit, DepositState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => _buildLoadingState(),
          noYields: () => _buildNoYieldsState(),
          error: () => _buildErrorState(),
          success: (yields) => StreamBuilder<YieldDto?>(
              stream: _cubit.selectedYieldStream,
              builder: (context, selectedYieldSnapshot) {
                return Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZupTextButton(
                            key: const Key("back-button"),
                            onPressed: () => _navigator.back(context),
                            icon: Assets.icons.arrowLeft.svg(),
                            label: S.of(context).depositPageBackButtonTitle,
                          ),
                          ZupPageTitle(S.of(context).depositPageTitle),
                          const SizedBox(height: 16),
                          _buildYieldSelectionSector(yields),
                          const SizedBox(height: 20),
                          if (selectedYieldSnapshot.data != null) ...[
                            _buildSelectRangeSector(),
                            const SizedBox(height: 20),
                            _buildDepositSection(),
                          ],
                          const SizedBox(height: 200)
                        ],
                      ),
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600));

  Widget _buildNoYieldsState() => Center(
          child: SizedBox(
        width: 400,
        child: ZupInfoState(
          icon: Transform.scale(scale: 3, child: lottieEmpty),
          iconSize: 120,
          title: S.of(context).depositPageEmptyStateTitle,
          description: S.of(context).depositPageEmptyStateDescription,
          helpButtonTitle: S.of(context).depositPageEmptyStateHelpButtonTitle,
          helpButtonIcon: Assets.icons.arrowLeft.svg(),
          onHelpButtonTap: () => _navigator.back(context),
        ),
      ));

  Widget _buildErrorState() => Center(
        child: SizedBox(
          width: 400,
          child: ZupInfoState(
            icon: const IgnorePointer(child: Text(":(", style: TextStyle(color: ZupColors.brand))),
            title: S.of(context).depositPageErrorStateTitle,
            description: S.of(context).depositPageErrorStateDescription,
            helpButtonTitle: S.of(context).letsGiveItAnotherShot,
            helpButtonIcon: Assets.icons.arrowClockwise.svg(),
            onHelpButtonTap: () => _cubit.getBestPools(
              token0Address: token0Address,
              token1Address: token1Address,
            ),
          ),
        ),
      );

  Widget _buildLoadingState() => Container(
        color: ZupColors.white,
        child: Center(
          child: ZupSteppedLoading(
            steps: [
              ZupSteppedLoadingStep(
                title: S.of(context).depositPageLoadingStep1Title,
                description: S.of(context).depositPageLoadingStep1Description,
                icon: lottieMatching,
                iconSize: 200,
              ),
              ZupSteppedLoadingStep(
                title: S.of(context).depositPageLoadingStep2Title,
                description: S.of(context).depositPageLoadingStep2Description,
                icon: lottieRadar,
                iconSize: 200,
              ),
              ZupSteppedLoadingStep(
                title: S.of(context).depositPageLoadingStep3Title,
                description: S.of(context).depositPageLoadingStep3Description,
                icon: lottieSearching,
                iconSize: 200,
              ),
            ],
          ),
        ),
      );

  Widget _buildYieldSelectionSector(YieldsDto yields) {
    final best24hYield = yields.last24Yields.firstOrNull;
    final best30dYield = yields.last30dYields.firstOrNull;
    final best90dYield = yields.last90dYields.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              IgnorePointer(child: _sectionTitle(S.of(context).depositPageTimeFrameTitle)),
              const SizedBox(width: 8),
              Assets.icons.infoCircle.svg(
                colorFilter: const ColorFilter.mode(
                  ZupColors.gray,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (best24hYield != null)
              Expanded(
                child: YieldCard(
                  key: const Key("yield-card-24h"),
                  yield: best24hYield,
                  onChangeSelection: (yield) {
                    selectYield(yield);
                  },
                  isSelected: _cubit.selectedYield.equals(best24hYield),
                  timeFrame: YieldTimeFrame.day,
                ),
              ),
            const SizedBox(width: 8),
            if (best30dYield != null)
              Expanded(
                child: YieldCard(
                  key: const Key("yield-card-30d"),
                  yield: best30dYield,
                  onChangeSelection: (yield) {
                    selectYield(yield);
                  },
                  isSelected: _cubit.selectedYield.equals(best30dYield),
                  timeFrame: YieldTimeFrame.month,
                ),
              ),
            const SizedBox(width: 8),
            if (best90dYield != null)
              Expanded(
                child: YieldCard(
                  key: const Key("yield-card-90d"),
                  yield: best90dYield,
                  onChangeSelection: (yield) {
                    selectYield(yield);
                  },
                  isSelected: _cubit.selectedYield.equals(best90dYield),
                  timeFrame: YieldTimeFrame.threeMonth,
                ),
              ),
          ],
        ),
        if (_cubit.selectedYield == null) ...[
          const SizedBox(height: 60),
          Center(
            child: ZupInfoState(
              iconSize: 90,
              icon: lottieClick,
              title: S.of(context).depositPageNoYieldSelectedTitle,
              description: S.of(context).depositPageNoYieldSelectedDescription,
            ),
          )
        ]
      ],
    );
  }

  Widget _buildSelectRangeSector() => Column(
        key: selectRangeSectorKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(S.of(context).depositPageRangeSectionTitle),
              const SizedBox(width: 12),
              ZupTextButton(
                key: const Key("full-range-button"),
                onPressed: () => setFullRange(),
                label: S.of(context).depositPageRangeSectionFullRange,
                icon: Assets.icons.circleDotted.svg(),
                alignLeft: false,
              ),
              const Spacer(),
              CupertinoSlidingSegmentedControl(
                groupValue: areTokensReversed,
                children: {
                  false: MouseRegion(
                    key: const Key("reverse-tokens-not-reversed"),
                    cursor: SystemMouseCursors.click,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Text(
                        "${_cubit.selectedYield?.token0.symbol} / ${_cubit.selectedYield?.token1.symbol}",
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  true: MouseRegion(
                    key: const Key("reverse-tokens-reversed"),
                    cursor: SystemMouseCursors.click,
                    child: IgnorePointer(
                        ignoring: true,
                        child: Text(
                          "${_cubit.selectedYield?.token1.symbol} / ${_cubit.selectedYield?.token0.symbol}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        )),
                  ),
                },
                onValueChanged: (isReversed) {
                  switchTokens(isReversed ?? false);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder(
              stream: _cubit.poolTickStream,
              builder: (context, poolTickSnapshot) {
                return Text(
                        "1 ${baseToken.symbol} ≈ ${() {
                          final currentPrice = tickToPrice(
                            tick: poolTickSnapshot.data ?? BigInt.zero,
                            poolToken0Decimals: _cubit.selectedYield!.token0.decimals,
                            poolToken1Decimals: _cubit.selectedYield!.token1.decimals,
                          );

                          return areTokensReversed ? currentPrice.priceAsQuoteToken : currentPrice.priceAsBaseToken;
                        }.call().toAmount(useLessThan: true, maxFixedDigits: 4)} ${quoteToken.symbol}",
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))
                    .redacted(
                  enabled: poolTickSnapshot.data == null,
                );
              }),
          const SizedBox(height: 20),
          StreamBuilder(
              stream: _cubit.poolTickStream,
              builder: (context, snapshot) {
                return RangeSelector(
                  key: const Key("min-price-selector"),
                  onPriceChanged: (price) {
                    setState(() {
                      if (price == 0) {
                        isMinRangeInfinity = true;

                        return calculateDepositTokensAmount();
                      }

                      isMinRangeInfinity = false;
                      minPrice = price;
                      calculateDepositTokensAmount();
                    });
                  },
                  initialPrice: minPrice,
                  poolToken0: _cubit.selectedYield!.token0,
                  poolToken1: _cubit.selectedYield!.token1,
                  isReversed: areTokensReversed,
                  tickSpacing: _cubit.selectedYield!.tickSpacing,
                  type: RangeSelectorType.minPrice,
                  isInfinity: isMinRangeInfinity,
                  state: () {
                    if (isOutOfRange.minPrice) {
                      return RangeSelectorState(
                        type: RangeSelectorStateType.warning,
                        message: S.of(context).depositPageMinRangeOutOfRangeWarningText,
                      );
                    }

                    return const RangeSelectorState(type: RangeSelectorStateType.regular);
                  }.call(),
                );
              }),
          const SizedBox(height: 6),
          StreamBuilder(
              stream: _cubit.poolTickStream,
              builder: (context, snapshot) {
                return RangeSelector(
                  key: const Key("max-price-selector"),
                  onPriceChanged: (price) {
                    setState(() {
                      if (price == 0) {
                        isMaxRangeInfinity = true;

                        return calculateDepositTokensAmount();
                      }

                      isMaxRangeInfinity = false;
                      maxPrice = price;

                      calculateDepositTokensAmount();
                    });
                  },
                  type: RangeSelectorType.maxPrice,
                  isInfinity: isMaxRangeInfinity,
                  initialPrice: maxPrice,
                  poolToken0: _cubit.selectedYield!.token0,
                  poolToken1: _cubit.selectedYield!.token1,
                  isReversed: areTokensReversed,
                  tickSpacing: _cubit.selectedYield!.tickSpacing,
                  state: () {
                    if (isRangeInvalid) {
                      return RangeSelectorState(
                        type: RangeSelectorStateType.error,
                        message: S.of(context).depositPageInvalidRangeErrorText,
                      );
                    }

                    if (isOutOfRange.maxPrice) {
                      return RangeSelectorState(
                        type: RangeSelectorStateType.warning,
                        message: S.of(context).depositPageMaxRangeOutOfRangeWarningText,
                      );
                    }

                    return const RangeSelectorState(type: RangeSelectorStateType.regular);
                  }.call(),
                );
              }),
        ],
      );

  Widget _buildDepositSection() => IgnorePointer(
        key: const Key("deposit-section"),
        ignoring: isRangeInvalid,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isRangeInvalid ? 0.2 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(S.of(context).depositPageDepositSectionTitle),
              const SizedBox(height: 12),
              TokenAmountInputCard(
                key: const Key("base-token-input-card"),
                token: baseToken,
                disabledText: !(isBaseTokenNeeded)
                    ? S.of(context).depositPageDepositSectionTokenNotNeeded(baseToken.symbol)
                    : null,
                onInput: (amount) {
                  setState(() {
                    isBaseTokenAmountUserInput = true;

                    calculateDepositTokensAmount();
                  });
                },
                controller: baseTokenAmountController,
                network: _cubit.selectedYield!.network,
              ),
              const SizedBox(height: 6),
              TokenAmountInputCard(
                key: const Key("quote-token-input-card"),
                token: quoteToken,
                disabledText: !(isQuoteTokenNeeded)
                    ? S.of(context).depositPageDepositSectionTokenNotNeeded(quoteToken.symbol)
                    : null,
                onInput: (amount) {
                  setState(() {
                    isBaseTokenAmountUserInput = false;

                    calculateDepositTokensAmount();
                  });
                },
                controller: quoteTokenAmountController,
                network: _cubit.selectedYield!.network,
              ),
              const SizedBox(height: 20),
              StreamBuilder(
                key: const Key("deposit-button"),
                stream: wallet.signerStream,
                initialData: wallet.signer,
                builder: (context, signerSnapshot) {
                  if (!signerSnapshot.hasData) {
                    return ZupPrimaryButton(
                      width: double.maxFinite,
                      title: S.of(context).connectWallet,
                      icon: Assets.icons.walletBifold.svg(),
                      fixedIcon: true,
                      hoverElevation: 0,
                      backgroundColor: ZupColors.brand7,
                      foregroundColor: ZupColors.brand,
                      onPressed: () => ConnectModal.show(context),
                    );
                  }

                  return FutureBuilder(
                      future: depositButtonState(),
                      builder: (context, stateSnapshot) {
                        return ZupPrimaryButton(
                          title: stateSnapshot.data?.title ?? "Loading...",
                          icon: stateSnapshot.data?.icon,
                          isLoading: stateSnapshot.connectionState == ConnectionState.waiting,
                          fixedIcon: true,
                          onPressed: stateSnapshot.data?.onPressed,
                          width: double.maxFinite,
                        );
                      });
                },
              ),
            ],
          ),
        ),
      );
}
