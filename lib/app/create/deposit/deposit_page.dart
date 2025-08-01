import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/deposit/widgets/deposit_settings_dropdown_child.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal.dart';
import 'package:zup_app/app/create/deposit/widgets/range_selector.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_input_card/token_amount_input_card.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/extensions/string_extension.dart';
import 'package:zup_app/core/extensions/widget_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/mixins/v3_pool_liquidity_calculations_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/v3_v4_pool_constants.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_app/widgets/zup_page_title.dart';
import 'package:zup_core/zup_core.dart';
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
        inject<Cache>(),
        inject<AppCubit>(),
        inject<ZupAnalytics>(),
        inject<PoolService>(),
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

class _DepositPageState extends State<DepositPage>
    with V3PoolConversorsMixin, V3PoolLiquidityCalculationsMixin, DeviceInfoMixin {
  final lottieClick = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieClick);
  final lottieEmpty = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieEmpty);
  final lottieRadar = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieRadar);
  final lottieNumbers = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieNumbers);
  final lottieMatching = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieMatching);
  final lottieSearching = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieSearching);

  final baseTokenAmountController = TextEditingController();
  final quoteTokenAmountController = TextEditingController();
  final yieldsPageController = PageController(initialPage: 0);
  final wallet = inject<Wallet>();
  final selectRangeSectorKey = GlobalKey();

  ZupNavigator get _navigator => inject<ZupNavigator>();
  DepositCubit get _cubit => context.read<DepositCubit>();
  AppCubit get _appCubit => inject<AppCubit>();

  String? get token0Id {
    return _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsNames<ZupDepositRouteParamsNames>().token0);
  }

  String? get token1Id {
    return _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsNames<ZupDepositRouteParamsNames>().token1);
  }

  String? get group0Id {
    return _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsNames<ZupDepositRouteParamsNames>().group0);
  }

  String? get group1Id {
    return _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsNames<ZupDepositRouteParamsNames>().group1);
  }

  TokenDto get baseToken {
    return areTokensReversed ? _cubit.selectedYield!.token1 : _cubit.selectedYield!.token0;
  }

  TokenDto get quoteToken {
    return areTokensReversed ? _cubit.selectedYield!.token0 : _cubit.selectedYield!.token1;
  }

  num currentYieldPage = 0;
  bool areTokensReversed = false;
  bool isMaxRangeInfinity = true;
  bool isMinRangeInfinity = true;
  bool isBaseTokenAmountUserInput = false;
  double? percentRange;
  double minPrice = 0;
  double maxPrice = 0;
  RangeController minRangeController = RangeController();
  RangeController maxRangeController = RangeController();
  StreamSubscription<BigInt?>? _poolTickStreamSubscription;
  YieldTimeFrame selectedYieldTimeFrame = YieldTimeFrame.day;

  late Slippage selectedSlippage = _cubit.depositSettings.slippage;
  late Duration selectedDeadline = _cubit.depositSettings.deadline;

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
      poolToken0Decimals: _cubit.selectedYield!.token0NetworkDecimals,
      poolToken1Decimals: _cubit.selectedYield!.token1NetworkDecimals,
    );

    return areTokensReversed ? price.priceAsQuoteToken : price.priceAsBaseToken;
  }

  ({bool minPrice, bool maxPrice, bool any}) get isOutOfRange {
    if (_cubit.latestPoolTick == null) return (minPrice: false, maxPrice: false, any: false);

    final isMinPriceOutOfRange = !isMinRangeInfinity && (minPrice) > currentPrice;
    final isMaxPriceOutOfRange = !isMaxRangeInfinity && (maxPrice) < currentPrice;

    return (
      minPrice: isMinPriceOutOfRange,
      maxPrice: isMaxPriceOutOfRange,
      any: isMinPriceOutOfRange || isMaxPriceOutOfRange,
    );
  }

  void setFullRange() {
    setState(() {
      percentRange = null;
      isMinRangeInfinity = true;
      isMaxRangeInfinity = true;
    });

    minPrice = 0;
    maxPrice = 0;

    calculateDepositTokensAmount();
  }

  void setPercentageRange(double percentage) {
    if (currentPrice == 0) return;

    setState(() {
      percentRange = percentage;
      isMinRangeInfinity = false;
      isMaxRangeInfinity = false;

      final percentageDecimals = percentage / 100;
      final percentageDifference = currentPrice * percentageDecimals;

      minPrice = currentPrice - percentageDifference;
      maxPrice = currentPrice + percentageDifference;

      minRangeController.setRange(minPrice);
      maxRangeController.setRange(maxPrice);

      calculateDepositTokensAmount();
    });
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

    if (percentRange != null) setPercentageRange(percentRange!);
    calculateDepositTokensAmount();
  }

  void calculateDepositTokensAmount() {
    if (_cubit.latestPoolTick == null || _cubit.selectedYield == null) return;

    if (isOutOfRange.minPrice) return quoteTokenAmountController.clear();
    if (isOutOfRange.maxPrice) return baseTokenAmountController.clear();

    final maxTickPrice = tickToPrice(
      tick: V3V4PoolConstants.maxTick,
      poolToken0Decimals: _cubit.selectedYield!.token0NetworkDecimals,
      poolToken1Decimals: _cubit.selectedYield!.token1NetworkDecimals,
    );

    final minTickPrice = tickToPrice(
      tick: V3V4PoolConstants.minTick,
      poolToken0Decimals: _cubit.selectedYield!.token0NetworkDecimals,
      poolToken1Decimals: _cubit.selectedYield!.token1NetworkDecimals,
    );

    double getMinPrice() {
      if (minPrice != 0 && !isMinRangeInfinity) return minPrice;

      return areTokensReversed ? maxTickPrice.priceAsQuoteToken : minTickPrice.priceAsBaseToken;
    }

    double getMaxPrice() {
      if (maxPrice != 0 && !isMaxRangeInfinity) return maxPrice;

      return areTokensReversed ? minTickPrice.priceAsQuoteToken : maxTickPrice.priceAsBaseToken;
    }

    final newQuoteTokenAmount = Decimal.tryParse(
      calculateToken1AmountFromToken0(
        double.tryParse(baseTokenAmountController.text) ?? 0,
        currentPrice,
        getMinPrice(),
        getMaxPrice(),
      ).toString(),
    )?.toStringAsFixed(quoteToken.decimals[_cubit.selectedYield!.network.chainId]!);

    final newBaseTokenAmount = Decimal.tryParse(
      calculateToken0AmountFromToken1(
        double.tryParse(quoteTokenAmountController.text) ?? 0,
        currentPrice,
        getMinPrice(),
        getMaxPrice(),
      ).toString(),
    )?.toStringAsFixed(baseToken.decimals[_cubit.selectedYield!.network.chainId]!);

    if (isBaseTokenAmountUserInput) {
      if (newQuoteTokenAmount?.isEmptyOrZero ?? true) return quoteTokenAmountController.clear();
      quoteTokenAmountController.text = newQuoteTokenAmount!;

      return;
    }

    if (newBaseTokenAmount?.isEmptyOrZero ?? true) return baseTokenAmountController.clear();
    baseTokenAmountController.text = newBaseTokenAmount!;
  }

  Future<({String title, Widget? icon, Function()? onPressed})> depositButtonState() async {
    final userWalletBaseTokenAmount = await _cubit.getWalletTokenAmount(
      baseToken.addresses[_cubit.selectedYield!.network.chainId]!,
      network: _cubit.selectedYield!.network,
    );

    final userWalletQuoteTokenAmount = await _cubit.getWalletTokenAmount(
      quoteToken.addresses[_cubit.selectedYield!.network.chainId]!,
      network: _cubit.selectedYield!.network,
    );

    if (isRangeInvalid) return (title: S.of(context).depositPageInvalidRange, icon: null, onPressed: null);

    if (isBaseTokenNeeded && baseTokenAmountController.text.isEmptyOrZero) {
      return (
        title: S.of(context).depositPageInvalidTokenAmount(tokenSymbol: baseToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    if (isQuoteTokenNeeded && quoteTokenAmountController.text.isEmptyOrZero) {
      return (
        title: S.of(context).depositPageInvalidTokenAmount(tokenSymbol: quoteToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    if (userWalletBaseTokenAmount < (double.tryParse(baseTokenAmountController.text) ?? 0) && isBaseTokenNeeded) {
      return (
        title: S.of(context).depositPageInsufficientTokenBalance(tokenSymbol: baseToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    if (userWalletQuoteTokenAmount < (double.tryParse(quoteTokenAmountController.text) ?? 0) && isQuoteTokenNeeded) {
      return (
        title: S.of(context).depositPageInsufficientTokenBalance(tokenSymbol: quoteToken.symbol),
        icon: null,
        onPressed: null,
      );
    }

    return (
      title: S.of(context).preview,
      icon: Assets.icons.scrollFill.svg(),
      onPressed: () {
        PreviewDepositModal(
          key: const Key("preview-deposit-modal"),
          yieldTimeFrame: selectedYieldTimeFrame,
          deadline: selectedDeadline,
          maxSlippage: selectedSlippage,
          currentYield: _cubit.selectedYield!,
          isReversed: areTokensReversed,
          token0DepositAmountController: areTokensReversed ? quoteTokenAmountController : baseTokenAmountController,
          token1DepositAmountController: areTokensReversed ? baseTokenAmountController : quoteTokenAmountController,
          maxPrice: (isInfinity: isMaxRangeInfinity, price: maxPrice),
          minPrice: (isInfinity: isMinRangeInfinity, price: minPrice),
        ).show(context, currentPoolTick: _cubit.latestPoolTick ?? BigInt.zero);
      },
    );
  }

  @override
  void initState() {
    _cubit.setup();

    final currentNetworkFromUrl =
        _navigator.getParam(ZupNavigatorPaths.deposit.routeParamsNames<ZupDepositRouteParamsNames>().network) ?? "";

    yieldsPageController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentControllerPage = yieldsPageController.page!.toInt();
        if (currentControllerPage == currentYieldPage) return;

        setState(() => currentYieldPage = currentControllerPage);
      });
    });

    if (currentNetworkFromUrl.isNotEmpty) {
      final currentNetwork = AppNetworks.fromValue(currentNetworkFromUrl);
      if (currentNetwork != null && currentNetwork != _appCubit.selectedNetwork) {
        _appCubit.updateAppNetwork(currentNetwork);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getBestPools(
        token0AddressOrId: token0Id,
        token1AddressOrId: token1Id,
        group0Id: group0Id,
        group1Id: group1Id,
      );
    });

    _poolTickStreamSubscription = _cubit.poolTickStream.listen((poolTick) {
      if (poolTick != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => calculateDepositTokensAmount());
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    minRangeController.dispose();
    maxRangeController.dispose();
    _poolTickStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isMobileSize(context) ? const EdgeInsets.all(20) : EdgeInsets.zero,
      child: BlocBuilder<DepositCubit, DepositState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => _buildLoadingState(),
            noYields: (filtersApplied) => _buildNoYieldsState(filtersApplied: filtersApplied),
            error: () => _buildErrorState(),
            success: (yields) => StreamBuilder<YieldDto?>(
              stream: _cubit.selectedYieldStream,
              builder: (context, selectedYieldSnapshot) {
                return Padding(
                  padding: EdgeInsets.only(top: isMobileSize(context) ? 20 : 60),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZupTextButton(
                            key: const Key("back-button"),
                            onPressed: () => _navigator.navigateToNewPosition(),
                            icon: Assets.icons.arrowLeft.svg(),
                            label: S.of(context).depositPageBackButtonTitle,
                          ),
                          Row(
                            children: [
                              ZupPageTitle(S.of(context).depositPageTitle),
                              const Spacer(),
                              const SizedBox(width: 14),
                              ZupPillButton(
                                key: const Key("deposit-settings-button"),
                                backgroundColor: selectedSlippage.riskBackgroundColor,
                                foregroundColor: selectedSlippage.riskForegroundColor,
                                title: selectedSlippage.value != DepositSettingsDto.defaultMaxSlippage
                                    ? S
                                          .of(context)
                                          .depositPagePercentSlippage(
                                            valuePercent: selectedSlippage.value.formatPercent,
                                          )
                                    : null,
                                onPressed: (buttonContext) => ZupPopover.show(
                                  adjustment: const Offset(0, 10),
                                  showBasedOnContext: buttonContext,
                                  child: DepositSettingsDropdownChild(
                                    context,
                                    selectedDeadline: selectedDeadline,
                                    selectedSlippage: selectedSlippage,
                                    onSettingsChanged: (slippage, deadline) {
                                      _cubit.saveDepositSettings(slippage, deadline);

                                      setState(() {
                                        selectedDeadline = deadline;
                                        selectedSlippage = slippage;
                                      });
                                    },
                                  ),
                                ),
                                icon: Assets.icons.gear.svg(
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildYieldSelectionSector(yields),
                          const SizedBox(height: 20),
                          if (selectedYieldSnapshot.data != null) ...[
                            _buildSelectRangeSector(),
                            const SizedBox(height: 20),
                            _buildDepositSection(),
                          ],
                          const SizedBox(height: 200),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600));

  Widget _buildNoYieldsState({required PoolSearchFiltersDto filtersApplied}) => Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        SizedBox(
          width: 400,
          child: ZupInfoState(
            icon: Transform.scale(scale: 3, child: lottieEmpty),
            iconSize: 120,
            title: S.of(context).depositPageEmptyStateTitle,
            description: S.of(context).depositPageEmptyStateDescription,
            helpButtonTitle: S.of(context).depositPageEmptyStateHelpButtonTitle,
            helpButtonIcon: Assets.icons.arrowLeft.svg(),
            onHelpButtonTap: () => _navigator.navigateToNewPosition(),
          ),
        ),
        const SizedBox(height: 60),
        if (filtersApplied.minTvlUsd > 0)
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Assets.icons.infoCircle.svg(
                      colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                    ),
                  ),
                ),
                TextSpan(
                  text: S
                      .of(context)
                      .depositPageMinLiquiditySearchAlert(
                        minLiquidity: NumberFormat.compactSimpleCurrency().format(
                          _cubit.poolSearchSettings.minLiquidityUSD,
                        ),
                      ),
                  style: const TextStyle(color: ZupColors.gray, fontSize: 14),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Transform.translate(
                    offset: const Offset(-2, 0),
                    child: TextButton(
                      key: const Key("search-all-pools-button"),
                      onPressed: () => _cubit.getBestPools(
                        token0AddressOrId: token0Id,
                        token1AddressOrId: token1Id,
                        group0Id: group0Id,
                        group1Id: group1Id,
                        ignoreMinLiquidity: true,
                      ),
                      style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.all(6))),
                      child: Text(
                        S.of(context).depositPageTrySearchAllPools,
                        style: const TextStyle(color: ZupColors.brand, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
    child: SizedBox(
      width: 400,
      child: ZupInfoState(
        icon: const IgnorePointer(
          child: Text(":(", style: TextStyle(color: ZupColors.brand)),
        ),
        title: S.of(context).depositPageErrorStateTitle,
        description: S.of(context).depositPageErrorStateDescription,
        helpButtonTitle: S.of(context).letsGiveItAnotherShot,
        helpButtonIcon: Assets.icons.arrowClockwise.svg(),
        onHelpButtonTap: () => _cubit.getBestPools(
          token0AddressOrId: token0Id,
          token1AddressOrId: token1Id,
          group0Id: group0Id,
          group1Id: group1Id,
        ),
      ),
    ),
  );

  Widget _buildLoadingState() {
    bool isGroupSearch = group0Id != null || group1Id != null;

    return Container(
      color: ZupColors.white,
      child: Center(
        child: ZupSteppedLoading(
          stepDuration: Duration(seconds: isGroupSearch ? 8 : 6),
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
              icon: lottieNumbers,
              iconSize: 200,
            ),
            ZupSteppedLoadingStep(
              title: S.of(context).depositPageLoadingStep4Title,
              description: S.of(context).depositPageLoadingStep4Description,
              icon: lottieSearching,
              iconSize: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYieldSelectionSector(YieldsDto yields) {
    final poolsCount = yields.poolsSortedByTimeframe(selectedYieldTimeFrame).length;
    final yieldCardsPerPage = isMobileSize(context) ? 1 : 2;
    final yieldsPagesCount = (poolsCount / yieldCardsPerPage).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(color: ZupColors.gray6, borderRadius: BorderRadius.circular(12)),
          child: Wrap(
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                S.of(context).depositPageBestYieldsIn,
                style: const TextStyle(color: ZupColors.black, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoSlidingSegmentedControl<YieldTimeFrame>(
                    proportionalWidth: true,
                    onValueChanged: (timeframe) {
                      setState(() {
                        selectedYieldTimeFrame = timeframe ?? YieldTimeFrame.day;
                      });

                      yieldsPageController.jumpToPage(0);
                    },
                    groupValue: selectedYieldTimeFrame,
                    children: Map.fromEntries(
                      YieldTimeFrame.values.map(
                        (timeframe) => MapEntry(
                          timeframe,
                          IgnorePointer(
                                key: Key("${timeframe.name}-timeframe-button"),
                                child: Text(
                                  timeframe.compactDaysLabel(context),
                                  style: const TextStyle(
                                    color: ZupColors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                              .animatedHover(animationValue: 0.2, type: ZupAnimatedHoverType.opacity)
                              .animatedHover(animationValue: 0.95, type: ZupAnimatedHoverType.scale),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ZupTooltip.text(
                    key: const Key("timeframe-tooltip"),
                    message: S.of(context).depositPageTimeFrameTooltipMessage,
                    child: Assets.icons.infoCircle.svg(
                      colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),

        SizedBox(
          height: 150,
          child: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: yieldsPageController,
            pageSnapping: false,
            padEnds: false,
            scrollDirection: Axis.horizontal,
            itemCount: yieldsPagesCount,
            itemBuilder: (_, pageIndex) {
              final startIndex = pageIndex * yieldCardsPerPage;
              final endIndex = (startIndex + yieldCardsPerPage).clamp(0, poolsCount);

              final yieldsInThisPage = yields
                  .poolsSortedByTimeframe(selectedYieldTimeFrame)
                  .sublist(startIndex, endIndex);

              return Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: yieldsInThisPage
                      .map(
                        (yieldItem) => Expanded(
                          child: YieldCard(
                            key: Key("yield-card-${yieldItem.poolAddress}"),
                            isHotestYield: yieldItem.equals(
                              yields.poolsSortedByTimeframe(selectedYieldTimeFrame).first,
                            ),
                            currentYield: yieldItem,
                            onChangeSelection: (yield) {
                              selectYield(yield);
                            },
                            isSelected: _cubit.selectedYield.equals(yieldItem),
                            timeFrame: selectedYieldTimeFrame,
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ZupIconButton(
              key: const Key("previous-yield-page-button"),
              icon: Assets.icons.arrowLeft.svg(height: 12, width: 12),
              padding: const EdgeInsets.all(10),
              onPressed: (_) async {
                yieldsPageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastEaseInToSlowEaseOut,
                );
              },
            ),
            const SizedBox(width: 10),

            ZupIconButton(
              key: const Key("next-yield-page-button"),
              padding: const EdgeInsets.all(10),
              icon: Assets.icons.arrowRight.svg(height: 12, width: 12),
              onPressed: (_) async {
                yieldsPageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastEaseInToSlowEaseOut,
                );
              },
            ),
            const Spacer(),

            Row(
              children: List.generate(
                (currentYieldPage + 4).clamp(0, yieldsPagesCount).ceil(),
                (index) => AnimatedContainer(
                  key: Key("yield-page-indicator-$index"),
                  duration: const Duration(milliseconds: 200),
                  height: (index != currentYieldPage) ? 8 : 12,
                  width: (index != currentYieldPage) ? 8 : 12,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        yieldsPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.decelerate,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: CircleAvatar(
                          backgroundColor: (currentYieldPage.truncate() == index) ? ZupColors.brand : ZupColors.gray5,
                        ),
                      ),
                    ).animatedHover(animationValue: index != currentYieldPage ? 4 : 1),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_cubit.poolSearchSettings.minLiquidityUSD > 0)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.icons.infoCircle.svg(
                    height: 14,
                    colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      yields.filters.minTvlUsd > 0
                          ? "${S.of(context).depositPageShowingOnlyPoolsWithMoreThan(minLiquidity: NumberFormat.compactSimpleCurrency().format(_cubit.poolSearchSettings.minLiquidityUSD))} "
                          : "${S.of(context).depositPageShowingAllPools} ",
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: ZupColors.gray),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(-6, 0),
                child: TextButton(
                  key: const Key("hide-show-all-pools-button"),
                  onPressed: () => _cubit.getBestPools(
                    token0AddressOrId: token0Id,
                    token1AddressOrId: token1Id,
                    group0Id: group0Id,
                    group1Id: group1Id,
                    ignoreMinLiquidity: yields.filters.minTvlUsd > 0,
                  ),
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.all(6))),
                  child: Text(
                    yields.filters.minTvlUsd > 0
                        ? S.of(context).depositPageSearchAllPools
                        : S
                              .of(context)
                              .depositPageSearchOnlyForPoolsWithMorethan(
                                minLiquidity: NumberFormat.compactSimpleCurrency().format(
                                  _cubit.poolSearchSettings.minLiquidityUSD,
                                ),
                              ),
                    style: const TextStyle(color: ZupColors.brand, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
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
          ),
        ],
      ],
    );
  }

  Widget _buildSelectRangeSector() {
    Widget tokenSwitcher = CupertinoSlidingSegmentedControl(
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
            ),
          ),
        ),
      },
      onValueChanged: (isReversed) {
        switchTokens(isReversed ?? false);
      },
    );

    return Column(
      key: selectRangeSectorKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionTitle(S.of(context).depositPageRangeSectionTitle),
            const SizedBox(width: 12),
            const Spacer(),
            if (!isMobileSize(context)) tokenSwitcher,
          ],
        ),
        if (isMobileSize(context)) ...[const SizedBox(height: 5), tokenSwitcher, const SizedBox(height: 5)],
        const SizedBox(height: 10),
        StreamBuilder(
          stream: _cubit.poolTickStream,
          initialData: _cubit.latestPoolTick,
          builder: (context, poolTickSnapshot) {
            return Text(
              "1 ${baseToken.symbol} ≈ ${() {
                final currentPrice = tickToPrice(tick: poolTickSnapshot.data ?? BigInt.zero, poolToken0Decimals: _cubit.selectedYield!.token0NetworkDecimals, poolToken1Decimals: _cubit.selectedYield!.token1NetworkDecimals);

                return areTokensReversed ? currentPrice.priceAsQuoteToken : currentPrice.priceAsBaseToken;
              }.call().formatCurrency(useLessThan: true, maxDecimals: 4, isUSD: false)} ${quoteToken.symbol}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
            ).redacted(enabled: poolTickSnapshot.data == null);
          },
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ZupMiniButton(
              key: const Key("full-range-button"),
              onPressed: (_) => setFullRange(),
              isSelected: isMaxRangeInfinity && isMinRangeInfinity,
              title: S.of(context).depositPageRangeSectionFullRange,
              icon: Assets.icons.circleDotted.svg(),
            ),
            ZupMiniButton(
              key: const Key("5-percent-range-button"),
              onPressed: (_) => setPercentageRange(5),
              isSelected: percentRange == 5,
              title: "5%",
              icon: Assets.icons.plusminus.svg(),
              // alignLeft: true,
            ),
            ZupMiniButton(
              key: const Key("20-percent-range-button"),
              onPressed: (_) => setPercentageRange(20),
              isSelected: percentRange == 20,
              title: "20%",
              icon: Assets.icons.plusminus.svg(),
              // alignLeft: true,
            ),
            ZupMiniButton(
              key: const Key("50-percent-range-button"),
              onPressed: (_) => setPercentageRange(50),
              isSelected: percentRange == 50,
              title: "50%",
              icon: Assets.icons.plusminus.svg(),
              // alignLeft: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder(
          stream: _cubit.poolTickStream,
          builder: (context, snapshot) {
            return RangeSelector(
              key: const Key("min-price-selector"),
              onUserType: () => percentRange = null,
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
              poolToken0Decimals: _cubit.selectedYield!.token0NetworkDecimals,
              poolToken1Decimals: _cubit.selectedYield!.token1NetworkDecimals,
              isReversed: areTokensReversed,
              displayBaseTokenSymbol: baseToken.symbol,
              displayQuoteTokenSymbol: quoteToken.symbol,
              tickSpacing: _cubit.selectedYield!.tickSpacing,
              type: RangeSelectorType.minPrice,
              isInfinity: isMinRangeInfinity,
              rangeController: minRangeController,
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
          },
        ),
        const SizedBox(height: 6),
        StreamBuilder(
          stream: _cubit.poolTickStream,
          builder: (context, snapshot) {
            return RangeSelector(
              key: const Key("max-price-selector"),
              displayBaseTokenSymbol: baseToken.symbol,
              displayQuoteTokenSymbol: quoteToken.symbol,
              onUserType: () => percentRange = null,
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
              poolToken0Decimals: _cubit.selectedYield!.token0NetworkDecimals,
              poolToken1Decimals: _cubit.selectedYield!.token1NetworkDecimals,
              isReversed: areTokensReversed,
              tickSpacing: _cubit.selectedYield!.tickSpacing,
              rangeController: maxRangeController,
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
          },
        ),
      ],
    );
  }

  Widget _buildDepositSection() => IgnorePointer(
    key: const Key("deposit-section"),
    ignoring: isRangeInvalid,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isRangeInvalid ? 0.2 : 1,
      child: StreamBuilder(
        stream: _cubit.poolTickStream,
        initialData: _cubit.latestPoolTick,
        builder: (context, poolTickSnapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(S.of(context).depositPageDepositSectionTitle),
              const SizedBox(height: 12),
              TokenAmountInputCard(
                key: const Key("base-token-input-card"),
                token: baseToken,
                isNative: baseToken.addresses[_cubit.selectedYield!.network.chainId]!.lowercasedEquals(
                  EthereumConstants.zeroAddress,
                ),
                onRefreshBalance: () => setState(() {}),
                disabledText: () {
                  if (!isBaseTokenNeeded) {
                    return S.of(context).depositPageDepositSectionTokenNotNeeded(tokenSymbol: baseToken.symbol);
                  }

                  if (!isBaseTokenAmountUserInput &&
                      !poolTickSnapshot.hasData &&
                      quoteTokenAmountController.text.isNotEmpty) {
                    return S.of(context).loading;
                  }
                }.call(),
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
                isNative: quoteToken.addresses[_cubit.selectedYield!.network.chainId]!.lowercasedEquals(
                  EthereumConstants.zeroAddress,
                ),
                onRefreshBalance: () => setState(() {}),
                disabledText: () {
                  if (!isQuoteTokenNeeded) {
                    return S.of(context).depositPageDepositSectionTokenNotNeeded(tokenSymbol: quoteToken.symbol);
                  }

                  if (isBaseTokenAmountUserInput &&
                      !poolTickSnapshot.hasData &&
                      baseTokenAmountController.text.isNotEmpty) {
                    return S.of(context).loading;
                  }
                }.call(),
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
              Row(
                children: [
                  Expanded(
                    child: StreamBuilder(
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
                            alignCenter: true,
                            hoverElevation: 0,
                            backgroundColor: ZupColors.brand7,
                            foregroundColor: ZupColors.brand,
                            onPressed: (buttonContext) => ConnectModal().show(context),
                          );
                        }

                        return FutureBuilder(
                          future: depositButtonState(),
                          builder: (context, stateSnapshot) {
                            return ZupPrimaryButton(
                              alignCenter: true,
                              title: stateSnapshot.data?.title ?? "Loading...",
                              icon: stateSnapshot.data?.icon,
                              isLoading: stateSnapshot.connectionState == ConnectionState.waiting,
                              fixedIcon: true,
                              onPressed: stateSnapshot.data?.onPressed == null
                                  ? null
                                  : (buttonContext) => stateSnapshot.data?.onPressed!(),
                              width: double.maxFinite,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}
