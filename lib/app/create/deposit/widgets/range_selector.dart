import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/token_amount_input_formatter.dart';
import 'package:zup_app/core/v3_pool_constants.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

enum RangeSelectorType { minRange, maxRange }

extension RangeSelectorTypeExtension on RangeSelectorType {
  String label(BuildContext context) => [
        S.of(context).rangeSelectorMinRange,
        S.of(context).rangeSelectorMaxRange,
      ][index];

  String get infinityLabel => ["0", "∞"][index];

  BigInt get infinityTick => [V3PoolConstants.minTick, V3PoolConstants.maxTick][index];
}

enum RangeSelectorStateType { regular, error, warning }

extension RangeSelectorStateTypeExtension on RangeSelectorStateType {
  bool get isRegular => this == RangeSelectorStateType.regular;

  double get borderWidth => isRegular ? 0.5 : 1.5;

  Color get borderColor => [
        ZupColors.gray5,
        ZupColors.red,
        ZupColors.orange,
      ][index];

  Color get primaryColor => [
        ZupColors.brand,
        ZupColors.red,
        ZupColors.orange,
      ][index];

  Color get secondaryColor => [
        ZupColors.brand6,
        ZupColors.red5,
        ZupColors.orange5,
      ][index];
}

class RangeSelectorState {
  const RangeSelectorState({this.helperText, required this.type});

  final String? helperText;
  final RangeSelectorStateType type;
}

class RangeSelector extends StatefulWidget {
  const RangeSelector({
    super.key,
    required this.type,
    required this.baseTokenSymbol,
    required this.onRangeChanged,
    required this.quoteTokenSymbol,
    required this.pooltoken0Decimals,
    required this.pooltoken1Decimals,
    required this.poolTickSpacing,
    this.state = const RangeSelectorState(type: RangeSelectorStateType.regular),
    this.isInfinity = false,
  });

  final RangeSelectorType type;
  final String baseTokenSymbol;
  final String quoteTokenSymbol;
  final int pooltoken0Decimals;
  final int pooltoken1Decimals;
  final int poolTickSpacing;
  final bool isInfinity;
  final RangeSelectorState state;

  final void Function(BigInt newRangeTick) onRangeChanged;

  @override
  State<RangeSelector> createState() => _RangeSelectorState();
}

class _RangeSelectorState extends State<RangeSelector> with V3PoolConversorsMixin {
  final debouncer = inject<Debouncer>();
  final double padding = 20;

  final TextEditingController controller = TextEditingController();
  String? typedPrice;

  void callbackPrice(double price) {
    if (price == 0) return widget.onRangeChanged(widget.type.infinityTick);

    final priceAsTick = priceToTick(
      token0Decimals: widget.pooltoken0Decimals,
      token1Decimals: widget.pooltoken1Decimals,
      value: price,
    );

    widget.onRangeChanged(priceAsTick);
  }

  void adjustTypedPriceAndCallback() {
    if (typedPrice == null || (double.tryParse(typedPrice!) ?? 0) == 0) return callbackPrice(0);

    final adjustedPrice = priceToClosestValidPrice(
      token0Decimals: widget.pooltoken0Decimals,
      token1Decimals: widget.pooltoken1Decimals,
      tickSpacing: widget.poolTickSpacing,
      value: double.tryParse(typedPrice!) ?? 0,
    );

    final decimals = num.parse(typedPrice!).decimals;

    final formattedPrice = Decimal.parse(adjustedPrice.toString()).toStringAsFixed(decimals < 4 ? 4 : decimals);

    setState(() => controller.text = formattedPrice);

    callbackPrice(double.tryParse(formattedPrice) ?? 0);
  }

  void decreaseOrIncreaseRange({required bool increasing}) {
    double price = double.tryParse(controller.text) ?? 0;

    if (price == 0 && increasing) {
      price = tickToPrice(
        token0Decimals: widget.pooltoken0Decimals,
        token1Decimals: widget.pooltoken1Decimals,
        tick: BigInt.from(widget.poolTickSpacing),
      );
    }

    if (price == 0 && !increasing) return;

    final currentPriceAsTick = priceToTick(
      token0Decimals: widget.pooltoken0Decimals,
      token1Decimals: widget.pooltoken1Decimals,
      value: price,
    );

    final newPriceAsTick = increasing
        ? currentPriceAsTick - BigInt.from(widget.poolTickSpacing * 2)
        : currentPriceAsTick + BigInt.from(widget.poolTickSpacing * 2);

    final newPrice = tickToPrice(
      token0Decimals: widget.pooltoken0Decimals,
      token1Decimals: widget.pooltoken1Decimals,
      tick: tickToClosestValidTick(tick: newPriceAsTick, tickSpacing: widget.poolTickSpacing),
    );

    final decimals = price.decimals;

    final formattedPrice = Decimal.parse(newPrice.toString()).toStringAsFixed(decimals < 4 ? 4 : decimals);

    setState(() => controller.text = formattedPrice);
    debouncer.run(() => callbackPrice(double.tryParse(formattedPrice) ?? 0));
  }

  void checkInfinity() {
    if (widget.isInfinity) {
      controller.text = widget.type.infinityLabel;
      typedPrice = null;
    }
  }

  @override
  void didUpdateWidget(covariant RangeSelector oldWidget) {
    checkInfinity();

    if (widget.poolTickSpacing != oldWidget.poolTickSpacing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => adjustTypedPriceAndCallback());
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    checkInfinity();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastEaseInToSlowEaseOut,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: widget.state.type.borderWidth,
          color: widget.state.type.borderColor,
          strokeAlign: 1,
        ),
      ),
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.type.label(context), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text(
              "${widget.baseTokenSymbol}/${widget.quoteTokenSymbol}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ZupColors.gray),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Focus(
                    onFocusChange: (isFocused) {
                      if (!isFocused) adjustTypedPriceAndCallback();
                    },
                    child: Stack(
                      children: [
                        TextField(
                          clipBehavior: Clip.none,
                          controller: controller,
                          onChanged: (value) => typedPrice = value,
                          style: const TextStyle(fontSize: 28),
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: ZupColors.gray5),
                            hintText: "0",
                            border: InputBorder.none,
                          ),
                          inputFormatters: [TokenAmountInputFormatter()],
                        ),
                        Transform.translate(
                          offset: Offset(-(padding + 0.4), 0),
                          child: Container(
                            width: padding,
                            height: 50,
                            color: ZupColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(1, 0),
                  child: Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [ZupColors.white, ZupColors.white.withOpacity(0.8), ZupColors.white.withOpacity(0.0)],
                        stops: const [0.1, 0.5, 1.0],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
                Container(
                  color: ZupColors.white,
                  height: 50,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ZupIconButton(
                        key: const Key("range-increase-button"),
                        icon: Assets.icons.plus.svg(),
                        onPressed: () => decreaseOrIncreaseRange(increasing: true),
                        backgroundColor: widget.state.type.secondaryColor,
                        iconColor: widget.state.type.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      ZupIconButton(
                        key: const Key("range-decrease-button"),
                        icon: Assets.icons.minus.svg(),
                        padding: const EdgeInsets.all(12),
                        onPressed: () => decreaseOrIncreaseRange(increasing: false),
                        backgroundColor: widget.state.type.secondaryColor,
                        iconColor: widget.state.type.primaryColor,
                      ),
                    ],
                  ),
                )
              ],
            ),
            AnimatedContainer(
                alignment: Alignment.centerLeft,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastEaseInToSlowEaseOut,
                height: widget.state.type.isRegular ? 0 : 20,
                child: widget.state.helperText != null
                    ? AnimatedScale(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.fastEaseInToSlowEaseOut,
                        scale: widget.state.type.isRegular ? 0.6 : 1,
                        child: Text(
                          widget.state.helperText!,
                          style: TextStyle(
                            color: widget.state.type.isRegular ? Colors.transparent : widget.state.type.primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
