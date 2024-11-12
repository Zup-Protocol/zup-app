import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/app/create/deposit/widgets/range_selector.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';

import '../../../../golden_config.dart';

class _UniswapV3Conversors with V3PoolConversorsMixin {}

void main() {
  setUp(() {
    inject.registerFactory<Debouncer>(() => Debouncer(milliseconds: 0));
  });

  tearDown(() async => await inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    String baseTokenSymbol = "Token0",
    String quoteTokenSymbol = "Token1",
    RangeSelectorType type = RangeSelectorType.minRange,
    Function(BigInt newRangeTick)? onRangeSelected,
    int token0Decimals = 18,
    int token1Decimals = 6,
    int tickSpacing = 10,
    bool isInfinity = false,
    RangeSelectorState state = const RangeSelectorState(type: RangeSelectorStateType.regular),
  }) async =>
      await goldenDeviceBuilder(
        Center(
          child: SizedBox(
            width: 500,
            height: 200,
            child: RangeSelector(
              type: type,
              baseTokenSymbol: baseTokenSymbol,
              quoteTokenSymbol: quoteTokenSymbol,
              onRangeChanged: (newRangeTick) => onRangeSelected?.call(newRangeTick),
              pooltoken0Decimals: token0Decimals,
              pooltoken1Decimals: token1Decimals,
              poolTickSpacing: tickSpacing,
              isInfinity: isInfinity,
              state: state,
            ),
          ),
        ),
      );

  zGoldenTest("When setting the type to min range, it should show the widget in the min range state",
      goldenFileName: "range_selector_min_range_type", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(type: RangeSelectorType.minRange));
  });

  zGoldenTest("When setting the type to max range, it should show the widget in the max range state",
      goldenFileName: "range_selector_max_range_type", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(type: RangeSelectorType.maxRange));
  });

  zGoldenTest("When setting is infinity to true, and the type is min range, it should set the range to zero",
      goldenFileName: "range_selector_min_range_type_infinity", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(type: RangeSelectorType.minRange, isInfinity: true));
  });

  zGoldenTest("When setting is infinity to true, and the type is max range, it should set the range to infinity",
      goldenFileName: "range_selector_max_range_type_infinity", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(type: RangeSelectorType.maxRange, isInfinity: true));
  });

  zGoldenTest("When the state is warning, and has a text, it should show the warning state",
      goldenFileName: "range_selector_warning_state", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(
      state: const RangeSelectorState(type: RangeSelectorStateType.warning, helperText: "This is a warning text"),
    ));
  });

  zGoldenTest("When the state is error, and has a text, it should show the error state",
      goldenFileName: "range_selector_error_state", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(
      state: const RangeSelectorState(type: RangeSelectorStateType.error, helperText: "This is a error text"),
    ));
  });

  zGoldenTest(
      "When the state is regular, it should show the regular state. If it has a text, it should not show the text",
      goldenFileName: "range_selector_regular_state", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(
          state: const RangeSelectorState(type: RangeSelectorStateType.regular, helperText: "This is a regular text")),
    );
  });

  zGoldenTest("When typing non-numbers in the text field, it should not change the value",
      goldenFileName: "range_selector_non_number_input", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byType(TextField), "some text");
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing numbers in the text field, it should change the value",
      goldenFileName: "range_selector_number_input", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byType(TextField), "1234");
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When typing numbers in the text field,
  and unfocusing it,it should ajust the typed value to
  the closest valid value (usable tick) and callback with it
  """, goldenFileName: "range_selector_number_input_adjust", (tester) async {
    const typedValue = 1234.5432;
    const token0Decimals = 18;
    const token1Decimals = 6;
    const tickSpacing = 60;

    final expectedCallbackTick = _UniswapV3Conversors().priceToTick(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      value: _UniswapV3Conversors().priceToClosestValidPrice(
        token0Decimals: token0Decimals,
        token1Decimals: token1Decimals,
        tickSpacing: tickSpacing,
        value: typedValue,
      ),
    );

    BigInt? actualCallbackTick;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      tickSpacing: tickSpacing,
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      onRangeSelected: (newRangeTick) => actualCallbackTick = newRangeTick,
    ));

    await tester.enterText(find.byType(TextField), typedValue.toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(actualCallbackTick, expectedCallbackTick);
  });

  zGoldenTest("""When using the plus button to increase the value,
       it should increase the tick spacing x2 and adjust the value to the
      closest valid value (usable tick)
      """, goldenFileName: "range_selector_number_increase", (tester) async {
    const typedValue = 1234.5432;
    const token0Decimals = 18;
    const token1Decimals = 6;
    const tickSpacing = 60;

    final currentPriceAsTick = _UniswapV3Conversors().priceToTick(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      value: _UniswapV3Conversors().priceToClosestValidPrice(
        token0Decimals: token0Decimals,
        token1Decimals: token1Decimals,
        tickSpacing: tickSpacing,
        value: typedValue,
      ),
    );

    final newExpectedCallbackTick = _UniswapV3Conversors().tickToClosestValidTick(
      tick: currentPriceAsTick - BigInt.from(tickSpacing * 2),
      tickSpacing: tickSpacing,
    );

    BigInt? actualCallbackTick;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      tickSpacing: tickSpacing,
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      onRangeSelected: (newRangeTick) => actualCallbackTick = newRangeTick,
    ));

    await tester.enterText(find.byType(TextField), typedValue.toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("range-increase-button")));
    await tester.pumpAndSettle();

    expect(actualCallbackTick, newExpectedCallbackTick);
  });

  zGoldenTest("""When using the minus button to decrease the value,
       it should decrease the tick spacing x2 and adjust the value to the
      closest valid value (usable tick)
      """, goldenFileName: "range_selector_number_decrease", (tester) async {
    const typedValue = 1234.5432;
    const token0Decimals = 18;
    const token1Decimals = 6;
    const tickSpacing = 60;

    await tester.pumpDeviceBuilder(
        await goldenBuilder(tickSpacing: tickSpacing, token0Decimals: token0Decimals, token1Decimals: token1Decimals));

    await tester.enterText(find.byType(TextField), typedValue.toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("range-decrease-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When using the plus button to increase the value, and there is no value,
  it should set a value with the base of the tick spacing, and increase it x2
      """, goldenFileName: "range_selector_number_increase_no_value", (tester) async {
    const token0Decimals = 18;
    const token1Decimals = 6;
    const tickSpacing = 60;

    await tester.pumpDeviceBuilder(
      await goldenBuilder(tickSpacing: tickSpacing, token0Decimals: token0Decimals, token1Decimals: token1Decimals),
    );

    await tester.tap(find.byKey(const Key("range-increase-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When using the minus button to decrease the value, and there is no value,
  it should do nothing
      """, goldenFileName: "range_selector_number_decrease_no_value", (tester) async {
    const token0Decimals = 18;
    const token1Decimals = 6;
    const tickSpacing = 60;

    await tester.pumpDeviceBuilder(
      await goldenBuilder(tickSpacing: tickSpacing, token0Decimals: token0Decimals, token1Decimals: token1Decimals),
    );

    await tester.tap(find.byKey(const Key("range-decrease-button")));
    await tester.pumpAndSettle();
  });
}
