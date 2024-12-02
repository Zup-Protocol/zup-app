import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/fee_controller.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/zup_router.abi.g.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal_cubit.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/v3_pool_constants.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class PreviewDepositModal extends StatefulWidget {
  const PreviewDepositModal({
    super.key,
    required this.currentYield,
    required this.isReversed,
    required this.minPrice,
    required this.maxPrice,
    required this.token0DepositAmount,
    required this.token1DepositAmount,
  });

  final YieldDto currentYield;
  final bool isReversed;
  final ({double price, bool isInfinity}) minPrice;
  final ({double price, bool isInfinity}) maxPrice;
  final double token0DepositAmount;
  final double token1DepositAmount;
  final double paddingSize = 20;

  show(BuildContext context, {required BigInt currentPoolTick}) {
    return ZupModal.show(
      context,
      title: S.of(context).previewDepositModalTitle,
      size: const Size(550, 550),
      padding: EdgeInsets.only(left: paddingSize),
      content: BlocProvider(
        create: (context) => PreviewDepositModalCubit(
          currentYield: currentYield,
          uniswapPositionManager: inject<UniswapPositionManager>(),
          feeController: inject<FeeController>(),
          erc20: inject<Erc20>(),
          wallet: inject<Wallet>(),
          uniswapV3Pool: inject<UniswapV3Pool>(),
          initialPoolTick: currentPoolTick,
          zupRouter: inject<ZupRouter>(),
        ),
        child: PreviewDepositModal(
          token0DepositAmount: token0DepositAmount,
          token1DepositAmount: token1DepositAmount,
          minPrice: minPrice,
          maxPrice: maxPrice,
          currentYield: currentYield,
          isReversed: isReversed,
        ),
      ),
    );
  }

  @override
  State<PreviewDepositModal> createState() => _PreviewDepositModalState();
}

class _PreviewDepositModalState extends State<PreviewDepositModal> with V3PoolConversorsMixin {
  final zupCachedImage = inject<ZupCachedImage>();
  final navigator = inject<ZupNavigator>();
  final scaffoldMessengerKey = inject<GlobalKey<ScaffoldMessengerState>>();
  final positionsCubit = inject<PositionsCubit>();
  final ScrollController appScrollController = inject<ScrollController>(
    instanceName: InjectInstanceNames.appScrollController,
  );

  TokenDto get baseToken => isReversedLocal ? widget.currentYield.token1 : widget.currentYield.token0;
  TokenDto get quoteToken => isReversedLocal ? widget.currentYield.token0 : widget.currentYield.token1;
  double get baseTokenAmount => isReversedLocal ? widget.token1DepositAmount : widget.token0DepositAmount;
  double get quoteTokenAmount => isReversedLocal ? widget.token0DepositAmount : widget.token1DepositAmount;
  PreviewDepositModalCubit get cubit => context.read<PreviewDepositModalCubit>();
  BigInt get token0DepositAmount =>
      widget.token0DepositAmount.parseTokenAmount(decimals: widget.currentYield.token0.decimals);
  BigInt get token1DepositAmount =>
      widget.token1DepositAmount.parseTokenAmount(decimals: widget.currentYield.token1.decimals);

  double get currentPrice {
    final currentTick = cubit.latestPoolTick;

    final price = tickToPrice(
      tick: currentTick,
      poolToken0Decimals: widget.currentYield.token0.decimals,
      poolToken1Decimals: widget.currentYield.token1.decimals,
    );

    return isReversedLocal ? price.priceAsQuoteToken : price.priceAsBaseToken;
  }

  double get minPrice {
    BigInt tick() {
      if (widget.isReversed != isReversedLocal && widget.maxPrice.isInfinity) return V3PoolConstants.minTick;

      return priceToTick(
        price: (widget.isReversed == !isReversedLocal) ? widget.maxPrice.price : widget.minPrice.price,
        poolToken0Decimals: widget.currentYield.token0.decimals,
        poolToken1Decimals: widget.currentYield.token1.decimals,
        isReversed: widget.isReversed,
      );
    }

    ({double priceAsBaseToken, double priceAsQuoteToken}) price() => tickToPrice(
          tick: tick(),
          poolToken0Decimals: widget.currentYield.token0.decimals,
          poolToken1Decimals: widget.currentYield.token1.decimals,
        );

    return isReversedLocal ? price().priceAsQuoteToken : price().priceAsBaseToken;
  }

  double get maxPrice {
    BigInt tick() {
      if (widget.isReversed != isReversedLocal && widget.minPrice.isInfinity) return V3PoolConstants.minTick;

      return priceToTick(
        price: (widget.isReversed == !isReversedLocal) ? widget.minPrice.price : widget.maxPrice.price,
        poolToken0Decimals: widget.currentYield.token0.decimals,
        poolToken1Decimals: widget.currentYield.token1.decimals,
        isReversed: widget.isReversed,
      );
    }

    ({double priceAsBaseToken, double priceAsQuoteToken}) price() => tickToPrice(
          tick: tick(),
          poolToken0Decimals: widget.currentYield.token0.decimals,
          poolToken1Decimals: widget.currentYield.token1.decimals,
        );

    return isReversedLocal ? price().priceAsQuoteToken : price().priceAsBaseToken;
  }

  ({bool minPrice, bool maxPrice, bool any}) get isOutOfRange {
    final isMinPriceOutOfRange = !widget.minPrice.isInfinity && (minPrice) > currentPrice;
    final isMaxPriceOutOfRanfe = !widget.maxPrice.isInfinity && (maxPrice) < currentPrice;

    return (
      minPrice: isMinPriceOutOfRange,
      maxPrice: isMaxPriceOutOfRanfe,
      any: isMinPriceOutOfRange || isMaxPriceOutOfRanfe
    );
  }

  ({String title, Widget? icon, Function()? onPressed, bool? isLoading}) get depositButtonState {
    return cubit.state.maybeWhen(
      loading: () => (
        title: S.of(context).loading,
        icon: null,
        onPressed: null,
        isLoading: true,
      ),
      waitingTransaction: (txId) => (
        title: S.of(context).previewDepositModalWaitingTransaction,
        icon: null,
        onPressed: null,
        isLoading: true,
      ),
      approvingToken: (symbol) => (
        title: S.of(context).previewDepositModalApprovingToken(symbol),
        icon: null,
        onPressed: null,
        isLoading: true,
      ),
      depositing: () => (
        title: S.of(context).previewDepositModalDepositingIntoPool(baseToken.symbol, quoteToken.symbol),
        icon: null,
        onPressed: null,
        isLoading: true,
      ),
      initial: (token0Allowance, token1Allowance) {
        if (token0Allowance < token0DepositAmount) {
          return (
            title: S.of(context).previewDepositModalApproveToken(widget.currentYield.token0.symbol),
            icon: Assets.icons.lockOpen.svg(),
            isLoading: false,
            onPressed: () => cubit.approveToken(widget.currentYield.token0, token0DepositAmount)
          );
        }

        if (token1Allowance < token1DepositAmount) {
          return (
            title: S.of(context).previewDepositModalApproveToken(widget.currentYield.token1.symbol),
            icon: Assets.icons.lockOpen.svg(),
            isLoading: false,
            onPressed: () => cubit.approveToken(widget.currentYield.token1, token1DepositAmount)
          );
        }

        return (
          title: S.of(context).previewDepositModalDeposit,
          icon: Assets.icons.paperplaneFill.svg(),
          isLoading: false,
          onPressed: () => cubit.deposit(
                token0Amount: token0DepositAmount,
                token1Amount: token1DepositAmount,
                minPrice: widget.minPrice.price,
                maxPrice: widget.maxPrice.price,
                isMinPriceInfinity: widget.minPrice.isInfinity,
                isMaxPriceInfinity: widget.maxPrice.isInfinity,
                isReversed: widget.isReversed,
              ),
        );
      },
      depositSuccess: (txId) => (
        title: S.of(context).loading,
        icon: null,
        isLoading: true,
        onPressed: null,
      ),
      orElse: () => (
        title: S.of(context).previewDepositModalError,
        icon: null,
        onPressed: null,
        isLoading: false,
      ),
    );
  }

  late bool isReversedLocal = widget.isReversed;

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ZupColors.gray),
      );

  Widget _fieldColumn({required String title, Widget? image, required String value, double spacing = 8}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          SizedBox(height: spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (image != null) ...[
                image,
                const SizedBox(width: 8),
              ],
              Flexible(
                fit: FlexFit.loose,
                child: Text(value, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => cubit.setup());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PreviewDepositModalCubit, PreviewDepositModalState>(
      listener: (context, state) {
        state.whenOrNull(
          waitingTransaction: (txId) => ScaffoldMessenger.of(context).showSnackBar(
            ZupSnackBar(
              context,
              message: S.of(context).previewDepositModalWaitingTransactionSnackBarMessage,
              type: ZupSnackBarType.info,
              helperButton: (
                title: S.of(context).previewDepositModalWaitingTransactionSnackBarHelperButtonTitle,
                onButtonTap: () => widget.currentYield.network.openTx(txId)
              ),
              customIcon: const ZupCircularLoadingIndicator(size: 20),
              snackDuration: const Duration(minutes: 10),
            ),
          ),
          approveSuccess: (txId, tokenSymbol) async {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(
              ZupSnackBar(
                context,
                message: S.of(context).previewDepositModalApproveSuccessSnackBarMessage(tokenSymbol),
                type: ZupSnackBarType.success,
                helperButton: (
                  title: S.of(context).previewDepositModalApproveSuccessSnackBarHelperButtonTitle,
                  onButtonTap: () => widget.currentYield.network.openTx(txId),
                ),
              ),
            );
          },
          depositSuccess: (txId) async {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).pop();

            await navigator.navigateToMyPositions();
            positionsCubit.getUserPositions();
            appScrollController.jumpTo(0);

            scaffoldMessengerKey.currentState?.showSnackBar(
              ZupSnackBar(
                context,
                maxWidth: 450,
                message: S.of(context).previewDepositModalDepositSuccessSnackBarMessage(
                      baseToken.symbol,
                      quoteToken.symbol,
                    ),
                type: ZupSnackBarType.success,
                helperButton: (
                  title: S.of(context).previewDepositModalDepositSuccessSnackBarHelperButtonTitle,
                  onButtonTap: () => widget.currentYield.network.openTx(txId),
                ),
              ),
            );
          },
          transactionError: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            return ScaffoldMessenger.of(context).showSnackBar(
              ZupSnackBar(
                context,
                helperButton: (
                  title: S.of(context).previewDepositModalTransactionErrorSnackBarHelperButtonTitle,
                  onButtonTap: () {}
                ),
                message: S.of(context).previewDepositModalTransactionErrorSnackBarMessage,
                type: ZupSnackBarType.error,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        return CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ZupColors.brand5, width: 1.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _sectionTitle(S.of(context).previewDepositModalMyPosition),
                                  const SizedBox(width: 10),
                                  StreamBuilder(
                                      stream: cubit.poolTickStream,
                                      builder: (context, tickSnapshot) {
                                        return ZupTag(
                                          title: isOutOfRange.any
                                              ? S.of(context).previewDepositModalOutOfRange
                                              : S.of(context).previewDepositModalInRange,
                                          color: isOutOfRange.any ? ZupColors.orange : ZupColors.green,
                                        );
                                      }),
                                  const Spacer(),
                                  CupertinoSlidingSegmentedControl(
                                    groupValue: isReversedLocal,
                                    children: {
                                      false: MouseRegion(
                                        key: const Key("unreverse-tokens"),
                                        cursor: SystemMouseCursors.click,
                                        child: IgnorePointer(
                                          child: SizedBox(
                                            height: 16,
                                            child: Text(
                                              "${widget.currentYield.token0.symbol} / ${widget.currentYield.token1.symbol}",
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      ),
                                      true: MouseRegion(
                                        key: const Key("reverse-tokens"),
                                        child: IgnorePointer(
                                          child: SizedBox(
                                            height: 16,
                                            child: Text(
                                              "${widget.currentYield.token1.symbol} / ${widget.currentYield.token0.symbol}",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    },
                                    onValueChanged: (value) => setState(() => isReversedLocal = value ?? false),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  zupCachedImage.build(baseToken.logoUrl, height: 30, width: 30, radius: 50),
                                  const SizedBox(width: 10),
                                  Text(baseToken.symbol),
                                  const Spacer(),
                                  Text(
                                      "${baseTokenAmount.formatCurrency(
                                        isUSD: false,
                                        useLessThan: true,
                                        maxDecimals: 10,
                                      )} ${baseToken.symbol}",
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  zupCachedImage.build(quoteToken.logoUrl, height: 30, width: 30, radius: 50),
                                  const SizedBox(width: 10),
                                  Text(quoteToken.symbol),
                                  const Spacer(),
                                  Text(
                                      "${quoteTokenAmount.formatCurrency(
                                        isUSD: false,
                                        useLessThan: true,
                                        maxDecimals: 10,
                                      )} ${quoteToken.symbol}",
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: ZupDivider(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: _fieldColumn(
                                      title: S.of(context).previewDepositModalProtocol,
                                      image: zupCachedImage.build(
                                        widget.currentYield.protocol.logoUrl,
                                        width: 30,
                                        height: 30,
                                        radius: 100,
                                      ),
                                      value: widget.currentYield.protocol.name,
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  Flexible(
                                      fit: FlexFit.loose,
                                      child: _fieldColumn(
                                        title: S.of(context).previewDepositModalNetwork,
                                        image: SizedBox(width: 30, height: 30, child: widget.currentYield.network.icon),
                                        value: widget.currentYield.network.label,
                                      )),
                                  const SizedBox(width: 40),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: _fieldColumn(
                                      spacing: 11,
                                      title: S.of(context).previewDepositModalYearlyYieldTimeFrame(
                                            widget.currentYield.yieldTimeFrame.compactDaysLabel(context),
                                          ),
                                      value: widget.currentYield.yearlyYield.formatPercent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: rangeInfoCard(isMinPrice: true),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: rangeInfoCard(
                                isMinPrice: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: currentPriceCard,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ZupPrimaryButton(
                                key: const Key("deposit-button"),
                                fixedIcon: true,
                                title: depositButtonState.title,
                                onPressed: depositButtonState.onPressed,
                                icon: depositButtonState.icon,
                                isLoading: depositButtonState.isLoading ?? false,
                                width: double.maxFinite,
                              ),
                            ),
                            const SizedBox(width: 20),
                            ZupIconButton(icon: Assets.icons.gear.svg(), onPressed: () {})
                          ],
                        ),
                        const SizedBox(height: 20)
                      ],
                    ),
                  ),
                )),
          ],
        );
      },
    );
  }

  Widget get currentPriceCard => StreamBuilder(
        stream: cubit.poolTickStream,
        initialData: cubit.latestPoolTick,
        builder: (context, tickSnapshot) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZupColors.brand.withOpacity(0.02),
              border: Border.all(color: ZupColors.brand5, width: 0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).previewDepositModalCurrentPrice,
                  style: const TextStyle(
                    color: ZupColors.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                    currentPrice.maybeFormatCompactCurrency(
                      isUSD: false,
                      useLessThan: true,
                      useMoreThan: true,
                      maxBeforeCompact: pow(10, 6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: ZupColors.black,
                    )),
                const SizedBox(height: 5),
                Text(
                  "${baseToken.symbol} / ${quoteToken.symbol}",
                  style: const TextStyle(
                    color: ZupColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget rangeInfoCard({required bool isMinPrice}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ZupColors.brand.withOpacity(0.02),
          border: Border.all(color: ZupColors.brand5, width: 0.5),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMinPrice ? S.of(context).previewDepositModalMinPrice : S.of(context).previewDepositModalMaxPrice,
              style: const TextStyle(
                color: ZupColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
                () {
                  if (isMinPrice) {
                    return widget.minPrice.isInfinity
                        ? "0"
                        : minPrice.maybeFormatCompactCurrency(
                            isUSD: false,
                            maxBeforeCompact: pow(10, 6),
                            useLessThan: true,
                            useMoreThan: true,
                          );
                  }

                  return widget.maxPrice.isInfinity
                      ? "∞"
                      : maxPrice.maybeFormatCompactCurrency(
                          isUSD: false,
                          maxBeforeCompact: pow(10, 6),
                          useLessThan: true,
                          useMoreThan: true,
                        );
                }.call(),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: ZupColors.black,
                )),
            const SizedBox(height: 5),
            Text(
              "${baseToken.symbol} / ${quoteToken.symbol}",
              style: const TextStyle(
                color: ZupColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}
