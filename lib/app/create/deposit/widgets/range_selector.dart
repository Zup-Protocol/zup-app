import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/token_amount_input_formatter.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

enum RangeSelectorStateType {
  regular,
  warning,
  error;

  Color get borderColor => [ZupColors.gray5, ZupColors.orange, ZupColors.red][index];

  double get borderSize => [0.5, 1.5, 1.5][index];

  Color get textColor => [ZupColors.gray, ZupColors.orange, ZupColors.red][index];

  Color get adjustmentIconBackgroundColor => [ZupColors.brand7, ZupColors.orange5, ZupColors.red5][index];
  Color get adjustmentIconForegroundColor => [ZupColors.brand, ZupColors.orange, ZupColors.red][index];
}

enum RangeSelectorType {
  minPrice,
  maxPrice;

  String label(BuildContext context) => [
        S.of(context).rangeSelectorMinRange,
        S.of(context).rangeSelectorMaxRange,
      ][index];

  String get infinityLabel => ["0", "∞"][index];
}

class RangeSelectorState {
  const RangeSelectorState({required this.type, this.message});

  final RangeSelectorStateType type;
  final String? message;
}

class RangeSelector extends StatefulWidget {
  const RangeSelector({
    super.key,
    required this.poolToken0,
    required this.poolToken1,
    required this.isReversed,
    required this.tickSpacing,
    required this.onPriceChanged,
    required this.type,
    this.isInfinity = false,
    this.initialPrice,
    this.state = const RangeSelectorState(type: RangeSelectorStateType.regular),
  });

  final TokenDto poolToken0;
  final TokenDto poolToken1;
  final bool isReversed;
  final double? initialPrice;
  final int tickSpacing;
  final Function(double price) onPriceChanged;
  final RangeSelectorState state;
  final RangeSelectorType type;
  final bool isInfinity;

  @override
  State<RangeSelector> createState() => _RangeSelectorState();
}

class _RangeSelectorState extends State<RangeSelector> with V3PoolConversorsMixin {
  final padding = 20.0;
  final TextEditingController controller = TextEditingController();

  String? userTypedValue;
  bool showError = false;

  void adjustTypedAmountAndCallback() {
    final typedPrice = double.tryParse(userTypedValue ?? "0") ?? 0;

    if (typedPrice == 0) {
      widget.onPriceChanged(0);

      return;
    }

    final typedDecimals = typedPrice.decimals;

    controller.text = Decimal.tryParse(getAdjustedPrice(typedPrice).toString())
            ?.toStringAsFixed(typedDecimals < 4 ? 4 : typedDecimals) ??
        "";

    widget.onPriceChanged(getAdjustedPrice(typedPrice));
  }

  double getAdjustedPrice(double price) {
    final adjustedPrice = priceToClosestValidPrice(
      price: price,
      poolToken0Decimals: widget.poolToken0.decimals,
      poolToken1Decimals: widget.poolToken1.decimals,
      tickSpacing: widget.tickSpacing,
      isReversed: widget.isReversed,
    );

    return adjustedPrice.price;
  }

  void increaseOrDecrease({required bool increasing}) {
    final currentPrice = double.tryParse(userTypedValue ?? "0") ?? 0;

    if (currentPrice == 0 && !increasing) return;

    if ((currentPrice == 0 || widget.isInfinity) && increasing) {
      final minimumPrice = tickToPrice(
        tick: BigInt.from(widget.tickSpacing),
        poolToken0Decimals: widget.poolToken0.decimals,
        poolToken1Decimals: widget.poolToken1.decimals,
      );

      userTypedValue = minimumPrice.priceAsBaseToken.toString();
      return adjustTypedAmountAndCallback();
    }

    BigInt nextTick() {
      final BigInt currentTick = tickToClosestValidTick(
        tick: priceToTick(
          price: currentPrice,
          poolToken0Decimals: widget.poolToken0.decimals,
          poolToken1Decimals: widget.poolToken1.decimals,
          isReversed: widget.isReversed,
        ),
        tickSpacing: widget.tickSpacing,
      );

      final adjustment = BigInt.from(widget.tickSpacing * 2);

      if (increasing && !widget.isReversed) return currentTick + adjustment;
      if (!increasing && widget.isReversed) return currentTick + adjustment;

      return currentTick - BigInt.from(widget.tickSpacing);
    }

    double nextPrice() {
      final nextPrice = tickToPrice(
        tick: nextTick(),
        poolToken0Decimals: widget.poolToken0.decimals,
        poolToken1Decimals: widget.poolToken1.decimals,
      );

      if (widget.isReversed) return nextPrice.priceAsQuoteToken;
      return nextPrice.priceAsBaseToken;
    }

    userTypedValue = nextPrice().toAmount(maxFixedDigits: 4);
    adjustTypedAmountAndCallback();
  }

  void maybeAdjustInitialPriceAndCallback() {
    if (widget.initialPrice != null) {
      final adjustedInitialPrice = priceToClosestValidPrice(
        price: widget.initialPrice ?? 0,
        poolToken0Decimals: widget.poolToken0.decimals,
        poolToken1Decimals: widget.poolToken1.decimals,
        tickSpacing: widget.tickSpacing,
        isReversed: widget.isReversed,
      );

      controller.text = adjustedInitialPrice.price.toString();

      widget.onPriceChanged(adjustedInitialPrice.price);
    }
  }

  void setInfinity() {
    userTypedValue = "0";
    controller.text = widget.type.infinityLabel;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isInfinity) return setInfinity();

      maybeAdjustInitialPriceAndCallback();
    });
  }

  @override
  void didUpdateWidget(RangeSelector oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isInfinity) return setInfinity();

      if (widget.tickSpacing != oldWidget.tickSpacing || widget.isReversed != oldWidget.isReversed) {
        adjustTypedAmountAndCallback();
      }
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(padding).copyWith(left: 0, bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          strokeAlign: 1,
          width: widget.state.type.borderSize,
          color: widget.state.type.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: padding),
            child: Text(
              widget.type.label(context),
              style: const TextStyle(color: ZupColors.black, fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: padding),
            child: Text(
              widget.isReversed
                  ? "${widget.poolToken1.symbol}/${widget.poolToken0.symbol}"
                  : "${widget.poolToken0.symbol}/${widget.poolToken1.symbol}",
              style: const TextStyle(color: ZupColors.gray, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      Focus(
                        onFocusChange: (isFocused) {
                          if (!isFocused) adjustTypedAmountAndCallback();
                        },
                        child: TextField(
                          clipBehavior: Clip.none,
                          controller: controller,
                          onChanged: (value) => userTypedValue = value,
                          style: const TextStyle(fontSize: 28),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(right: 20, left: 20),
                            hintStyle: TextStyle(color: ZupColors.gray5),
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                          inputFormatters: [TokenAmountInputFormatter()],
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
              const SizedBox(width: 8),
              ZupIconButton(
                key: const Key("increase-button"),
                icon: Assets.icons.plus.svg(),
                iconColor: widget.state.type.adjustmentIconForegroundColor,
                backgroundColor: widget.state.type.adjustmentIconBackgroundColor,
                onPressed: () => increaseOrDecrease(increasing: true),
              ),
              const SizedBox(width: 8),
              ZupIconButton(
                key: const Key("decrease-button"),
                padding: const EdgeInsets.all(12),
                icon: Assets.icons.minus.svg(),
                backgroundColor: widget.state.type.adjustmentIconBackgroundColor,
                iconColor: widget.state.type.adjustmentIconForegroundColor,
                onPressed: () => increaseOrDecrease(increasing: false),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: padding, bottom: padding),
            child: AnimatedContainer(
              height: widget.state.message == null ? 0 : 20,
              duration: const Duration(milliseconds: 200),
              curve: Curves.decelerate,
              onEnd: () {
                setState(() => showError = widget.state.message != null);
              },
              child: AnimatedOpacity(
                duration: Duration(
                  milliseconds: widget.state.message == null ? 0 : 200,
                ),
                curve: Curves.decelerate,
                opacity: () {
                  if (widget.state.message == null) return 0.0;

                  return showError ? 1.0 : 0.0;
                }.call(),
                child: Text(
                  widget.state.message ?? "",
                  style: TextStyle(color: widget.state.type.textColor, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
