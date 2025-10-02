import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/yields/yields_cubit.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_app/widgets/zup_page_title.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

// Used by Routefly to build custom routes
Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (_, a1, a2) => BlocProvider(
      create: (context) =>
          YieldsCubit(inject<AppCubit>(), inject<AppCache>(), inject<YieldRepository>(), inject<ZupAnalytics>()),
      child: const YieldsPage(),
    ),
    transitionsBuilder: (_, a1, a2, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(a1),
      child: FadeTransition(opacity: a1, child: child),
    ),
  );
}

class YieldsPage extends StatefulWidget {
  const YieldsPage({super.key});

  @override
  State<YieldsPage> createState() => _YieldsPageState();
}

class _YieldsPageState extends State<YieldsPage> with DeviceInfoMixin, SingleTickerProviderStateMixin {
  final navigator = inject<ZupNavigator>();
  final appCubit = inject<AppCubit>();
  final appCache = inject<AppCache>();
  final lottieEmpty = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieEmpty);
  final lottieRadar = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieRadar);
  final lottieNumbers = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieNumbers);
  final lottieMatching = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieMatching);
  final lottieSearching = inject<LottieBuilder>(instanceName: InjectInstanceNames.lottieList);
  final appScrollController = inject<ScrollController>(instanceName: InjectInstanceNames.appScrollController);
  final pageController = PageController(initialPage: 0);
  final pageTransitionDuration = const Duration(milliseconds: 800);
  final pageTransitionCurve = Curves.easeInOutCubicEmphasized;
  final double mobilePageHorizontalPadding = 20;

  YieldsCubit get cubit => context.read<YieldsCubit>();

  String? get token0QueryParam {
    return navigator.getParam(ZupNavigatorPaths.yields.routeParamsNames<YieldsRouteParamsNames>().token0);
  }

  String? get token1QueryParam {
    return navigator.getParam(ZupNavigatorPaths.yields.routeParamsNames<YieldsRouteParamsNames>().token1);
  }

  String? get group0QueryParam {
    return navigator.getParam(ZupNavigatorPaths.yields.routeParamsNames<YieldsRouteParamsNames>().group0);
  }

  String? get group1QueryParam {
    return navigator.getParam(ZupNavigatorPaths.yields.routeParamsNames<YieldsRouteParamsNames>().group1);
  }

  YieldTimeFrame selectedYieldTimeFrame = YieldTimeFrame.day;
  num currentYieldPage = 0;
  bool isYieldsPageGoingBackwards = false;

  void resetScrollAndFetch({bool ignoreMinLiquidity = false}) {
    appScrollController.jumpTo(0);

    cubit.fetchYields(
      token0AddressOrId: token0QueryParam,
      token1AddressOrId: token1QueryParam,
      group0Id: group0QueryParam,
      group1Id: group1QueryParam,
      ignoreMinLiquidity: ignoreMinLiquidity,
    );
  }

  @override
  void initState() {
    final currentNetworkFromUrl =
        navigator.getParam(ZupNavigatorPaths.yields.routeParamsNames<YieldsRouteParamsNames>().network) ?? "";

    if (currentNetworkFromUrl.isNotEmpty) {
      final currentNetwork = AppNetworks.fromValue(currentNetworkFromUrl);
      if (currentNetwork != null) appCubit.updateAppNetwork(currentNetwork);
    }

    pageController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentControllerPage = pageController.page!.toInt();
        if (currentControllerPage == currentYieldPage) return;

        setState(() => currentYieldPage = currentControllerPage);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => resetScrollAndFetch());

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YieldsCubit, YieldsState>(
      builder: (context, state) {
        return state.maybeWhen(
          success: (yields) => _buildSuccessState(yields),
          noYields: (filtersApplied) => _buildNoYieldsState(filtersApplied: filtersApplied),
          error: (error, stackTrace) => _buildErrorState,
          orElse: () => _buildLoadingState,
        );
      },
    );
  }

  Widget _buildSuccessState(YieldsDto yields) {
    int getYieldDisplayCountPerPage() {
      return yields.pools.length.clamp(1, isMobileSize(context) ? 1 : 2);
    }

    final yieldsPagesCount = (yields.pools.length / getYieldDisplayCountPerPage()).ceil();

    return Padding(
      padding: EdgeInsets.only(top: isMobileSize(context) ? 20 : 70),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMobileSize(context)) ...[
                yieldsPagesCount == 1
                    ? const SizedBox(width: 60)
                    : AnimatedOpacity(
                        key: const Key("move-to-previous-yields-page-button"),
                        opacity: currentYieldPage > 0 ? 1 : 0.3,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ZupIconButton(
                            icon: Assets.icons.arrowLeft.svg(height: 12, width: 12),
                            onPressed: (context) async {
                              if (currentYieldPage.equals(0)) return;
                              isYieldsPageGoingBackwards = true;

                              pageController.previousPage(duration: pageTransitionDuration, curve: pageTransitionCurve);
                            },
                            circle: true,
                            padding: const EdgeInsets.all(15),
                          ).animatedHover(animationValue: 1.2),
                        ),
                      ),
              ],
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobileSize(context) ? mobilePageHorizontalPadding : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZupTextButton(
                            key: const Key("back-button"),
                            onPressed: () => navigator.navigateToNewPosition(),
                            icon: Assets.icons.arrowLeft.svg(),
                            label: S.of(context).yieldsPageBackButtonTitle,
                          ),
                          ZupPageTitle(S.of(context).yieldsPageTitle),
                          Text(
                            S.of(context).yieldsPageDescription,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ZupColors.gray),
                          ),
                          const SizedBox(height: 10),
                          _buildTimeframeSelector,
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildYieldsSection(
                      yieldsPagesCount: yieldsPagesCount,
                      yieldsCardPerPage: getYieldDisplayCountPerPage(),
                      yields: yields,
                    ),
                    const SizedBox(height: 20),
                    if (yieldsPagesCount > 1) _buildPageIndicator(pageCount: yieldsPagesCount),
                    const SizedBox(height: 20),
                    ..._buildMinTvlFilterAlert(currentMinTVLUSD: yields.filters.minTvlUsd),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              if (!isMobileSize(context)) ...[
                yieldsPagesCount == 1
                    ? const SizedBox(width: 60)
                    : AnimatedOpacity(
                        key: const Key("move-to-next-yields-page-button"),
                        opacity: currentYieldPage.equals(yieldsPagesCount - 1) ? 0.3 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ZupIconButton(
                            icon: Assets.icons.arrowRight.svg(height: 12, width: 12),
                            onPressed: (context) {
                              if (currentYieldPage.equals(yieldsPagesCount - 1)) return;
                              isYieldsPageGoingBackwards = false;

                              pageController.nextPage(duration: pageTransitionDuration, curve: pageTransitionCurve);
                            },
                            circle: true,
                            padding: const EdgeInsets.all(15),
                          ).animatedHover(animationValue: 1.2),
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYieldsSection({
    required int yieldsPagesCount,
    required int yieldsCardPerPage,
    required YieldsDto yields,
  }) {
    final poolsSortedByTimeframe = yields.poolsSortedByTimeframe(selectedYieldTimeFrame);

    return SizedBox(
      height: 310,
      child: PageView.builder(
        physics: isMobileSize(context) ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        controller: pageController,
        padEnds: false,
        pageSnapping: true,
        scrollDirection: Axis.horizontal,
        itemCount: yieldsPagesCount,
        itemBuilder: (_, pageIndex) {
          final firstYieldIndex = pageIndex * yieldsCardPerPage;
          final lastYieldIndex = (firstYieldIndex + yieldsCardPerPage).clamp(0, yields.pools.length);

          final yieldsCurrentPage = poolsSortedByTimeframe.sublist(firstYieldIndex, lastYieldIndex);

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobileSize(context) ? mobilePageHorizontalPadding : 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 10,
                children: yieldsCurrentPage.map((yieldItem) {
                  final animationDurationMultiplier = () {
                    if (isYieldsPageGoingBackwards) {
                      return yieldsCurrentPage.reversed.toList().indexOf(yieldItem) + 1;
                    }

                    return yieldsCurrentPage.indexOf(yieldItem) + 1;
                  }();

                  return Flexible(
                    child: YieldCard(
                      key: Key("yield-card-${yieldItem.poolAddress}"),
                      yieldPool: yieldItem,
                      yieldTimeFrame: selectedYieldTimeFrame,
                      isHotestYield: yieldItem.equals(poolsSortedByTimeframe.first),
                    ),
                  ).animate(
                    autoPlay: true,
                    effects: [
                      SlideEffect(
                        begin: Offset(isYieldsPageGoingBackwards ? 1 : -1, 0),
                        end: const Offset(0, 0),
                        curve: Curves.easeOutQuart,
                        duration: Duration(milliseconds: 600 * animationDurationMultiplier),
                      ),
                      FadeEffect(
                        duration: const Duration(milliseconds: 800),
                        begin: 0,
                        end: 1,
                        curve: Curves.easeOutQuart,
                        delay: Duration(milliseconds: (100 * animationDurationMultiplier)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget get _buildTimeframeSelector => Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    child: Wrap(
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          S.of(context).yieldsPageTimeframeSelectorTitle,
          style: TextStyle(
            color: ZupThemeColors.primaryText.themed(context.brightness),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoSlidingSegmentedControl<YieldTimeFrame>(
              proportionalWidth: true,
              onValueChanged: (timeframe) async {
                setState(() {
                  pageController.jumpTo(0);
                  selectedYieldTimeFrame = timeframe ?? YieldTimeFrame.day;
                });
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
                            style: TextStyle(
                              color: ZupThemeColors.primaryText.themed(context.brightness),
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
              message: S.of(context).yieldsPageTimeframeExplanation,
              child: Assets.icons.infoCircle.svg(colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn)),
            ),
          ],
        ),
      ],
    ),
  );

  List<Widget> _buildMinTvlFilterAlert({required num currentMinTVLUSD}) => [
    if (currentMinTVLUSD > 0) ...[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: ZupInlineTextActionButton(
            text: S.of(context).yieldsPageDisplayingPoolsWithMinTvlAlert(tvlUSD: currentMinTVLUSD.formatCurrency()),
            style: TextStyle(color: ZupThemeColors.primaryText.themed(context.brightness), fontSize: 13),
            onActionButtonPressed: () => resetScrollAndFetch(ignoreMinLiquidity: true),
            actionButtonTitle: S.of(context).yieldsPageSearchAllPools,
          ),
        ),
      ),
    ] else if (appCache.getPoolSearchSettings().minLiquidityUSD > 0) ...[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: ZupInlineTextActionButton(
            text: S.of(context).yieldsPageDisplayingAllPoolsAlert,
            style: TextStyle(color: ZupThemeColors.primaryText.themed(context.brightness), fontSize: 13),
            onActionButtonPressed: () => resetScrollAndFetch(ignoreMinLiquidity: false),
            actionButtonTitle: S
                .of(context)
                .yieldsPageApplyTvlFilterButtonTitle(
                  tvlUSD: appCache.getPoolSearchSettings().minLiquidityUSD.formatCurrency(),
                ),
          ),
        ),
      ),
    ],
  ];

  Widget _buildNoYieldsState({required PoolSearchFiltersDto filtersApplied}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        SizedBox(
          width: 400,
          child: ZupInfoState(
            icon: Transform.scale(scale: 3, child: lottieEmpty),
            iconSize: 120,
            title: S.of(context).yieldsPageEmptyStateTitle,
            description: S.of(context).yieldsPageEmptyStateDescription,
            helpButtonTitle: S.of(context).yieldsPageEmptyStateHelperButtonTitle,
            helpButtonIcon: Assets.icons.arrowLeft.svg(),
            onHelpButtonTap: () => navigator.navigateToNewPosition(),
          ),
        ),
        const SizedBox(height: 60),
        if (filtersApplied.minTvlUsd > 0) ...[
          Center(
            child: ZupInlineTextActionButton(
              text: S.of(context).yieldsPageEmptyStateMinTVLAlert(tvlUSD: filtersApplied.minTvlUsd.formatCurrency()),
              style: TextStyle(color: ZupThemeColors.primaryText.themed(context.brightness), fontSize: 13),
              onActionButtonPressed: () => resetScrollAndFetch(ignoreMinLiquidity: true),
              actionButtonTitle: S.of(context).yieldsPageSearchAllPools,
            ),
          ),
        ],
      ],
    );
  }

  Widget get _buildErrorState {
    return Center(
      child: SizedBox(
        width: 400,
        child: ZupInfoState(
          icon: const IgnorePointer(
            child: Text(":(", style: TextStyle(color: ZupColors.brand)),
          ),
          title: S.of(context).yieldsPageErrorStateTitle,
          description: S.of(context).yieldsPageErrorStateDescription,
          helpButtonTitle: S.of(context).letsGiveItAnotherShot,
          helpButtonIcon: Assets.icons.arrowClockwise.svg(),
          onHelpButtonTap: () => resetScrollAndFetch(),
        ),
      ),
    );
  }

  Widget get _buildLoadingState {
    bool isGroupSearch = group0QueryParam != null || group1QueryParam != null;

    return Container(
      color: ZupThemeColors.background.themed(context.brightness),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ZupSteppedLoading(
          stepDuration: Duration(seconds: isGroupSearch ? 8 : 6),
          steps: [
            ZupSteppedLoadingStep(
              title: S.of(context).yieldsPageLoadingStep1Title,
              description: S.of(context).yieldsPageLoadingStep1Description,
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                child: lottieMatching,
              ),
              iconSize: 200,
            ),
            ZupSteppedLoadingStep(
              title: S.of(context).yieldsPageLoadingStep2Title,
              description: S.of(context).yieldsPageLoadingStep2Description,
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                child: lottieRadar,
              ),
              iconSize: 200,
            ),
            ZupSteppedLoadingStep(
              title: S.of(context).yieldsPageLoadingStep3Title,
              description: S.of(context).yieldsPageLoadingStep3Description,
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                child: lottieNumbers,
              ),
              iconSize: 200,
            ),
            ZupSteppedLoadingStep(
              title: S.of(context).yieldsPageLoadingStep4Title,
              description: S.of(context).yieldsPageLoadingStep4Description,
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                child: lottieSearching,
              ),
              iconSize: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator({required int pageCount}) => Center(
    child: SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          (currentYieldPage + 4).clamp(0, pageCount).ceil(),
          (index) => AnimatedContainer(
            key: Key("yield-page-indicator-$index"),
            duration: const Duration(milliseconds: 200),
            height: (index != currentYieldPage) ? 8 : 12,
            width: (index != currentYieldPage) ? 8 : 12,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOutExpo,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CircleAvatar(
                    backgroundColor: (currentYieldPage.truncate() == index)
                        ? ZupColors.brand
                        : ZupThemeColors.disabledButtonBackground.themed(context.brightness),
                  ),
                ),
              ).animatedHover(animationValue: index != currentYieldPage ? 4 : 1),
            ),
          ),
        ),
      ),
    ),
  );
}
