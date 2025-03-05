import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/app/create/deposit/widgets/range_selector.dart';
import 'package:zup_app/core/dtos/token_dto.dart';

import '../../../../golden_config.dart';

void main() {
  Future<DeviceBuilder> goldenBuilder({
    Key? key,
    bool isReversed = false,
    Function(double price)? onPriceChanged,
    TokenDto? poolToken0,
    TokenDto? poolToken1,
    int tickSpacing = 10,
    RangeSelectorType type = RangeSelectorType.minPrice,
    double? initialPrice,
    bool isInfinity = false,
    RangeSelectorState? state,
  }) =>
      goldenDeviceBuilder(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 600,
              child: RangeSelector(
                key: key,
                displayBaseTokenSymbol: "Token A",
                displayQuoteTokenSymbol: "Token B",
                isReversed: isReversed,
                onPriceChanged: onPriceChanged ?? (_) {},
                poolToken0: poolToken0 ?? TokenDto.fixture().copyWith(symbol: "Token A"),
                poolToken1: poolToken1 ?? TokenDto.fixture().copyWith(symbol: "Token B"),
                tickSpacing: tickSpacing,
                type: type,
                initialPrice: initialPrice,
                isInfinity: isInfinity,
                state: state ?? const RangeSelectorState(type: RangeSelectorStateType.regular),
              ),
            ),
          ],
        ),
      );

  zGoldenTest("When the range selector type is min price, it should represent in the widget",
      goldenFileName: "range_selector_min_price", (tester) async {
    return tester.pumpDeviceBuilder(await goldenBuilder(type: RangeSelectorType.minPrice));
  });

  zGoldenTest("When the range selector type is max price, it should represent in the widget",
      goldenFileName: "range_selector_max_price", (tester) async {
    return tester.pumpDeviceBuilder(await goldenBuilder(type: RangeSelectorType.maxPrice));
  });

  zGoldenTest("When the `isReversed` param is true, it should reverse the tokens in the widget",
      goldenFileName: "range_selector_reversed", (tester) async {
    return tester.pumpDeviceBuilder(
      await goldenBuilder(
        isReversed: true,
        poolToken0: TokenDto.fixture().copyWith(symbol: "Token 0"),
        poolToken1: TokenDto.fixture().copyWith(symbol: "Token 1"),
      ),
    );
  });

  zGoldenTest(
    "When typing a price, and unfocusing the text field, it should callback with the typed price adjusted for the tick spacing",
    (tester) async {
      const typedPrice = "1200";
      const expectedAdjustedTypedPrice = 1199.4825370276806;
      double actualAdjustedTypedPrice = 0;

      await tester.pumpDeviceBuilder(
        await goldenBuilder(onPriceChanged: (price) {
          actualAdjustedTypedPrice = price;
        }),
      );

      await tester.enterText(find.byType(TextField), typedPrice);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(actualAdjustedTypedPrice, expectedAdjustedTypedPrice);
    },
  );

  zGoldenTest(
    "When the param `initialPrice` is not null, it should start with the initial price typed and adjusted",
    goldenFileName: "range_selector_initial_price",
    (tester) async {
      const double initialPrice = 1200;

      await tester.pumpDeviceBuilder(
        await goldenBuilder(initialPrice: initialPrice),
      );
    },
  );

  zGoldenTest("When the type is max price, and the isInfinity param is true, it should show the infinity symbol",
      goldenFileName: "range_selector_max_price_infinity", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(type: RangeSelectorType.maxPrice, isInfinity: true),
    );
  });

  zGoldenTest("When the type is min price, and the isInfinity param is true, it should show 0",
      goldenFileName: "range_selector_min_price_infinity", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(type: RangeSelectorType.minPrice, isInfinity: true),
    );
  });

  zGoldenTest("When the state is warning, it should set the colors to yellow",
      goldenFileName: "range_selector_warning_state", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(
        state: const RangeSelectorState(
          type: RangeSelectorStateType.warning,
          message: "This is a warning message",
        ),
      ),
    );
  });

  zGoldenTest("When the state is error, it should set the colors to red", goldenFileName: "range_selector_error_state",
      (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(
        state: const RangeSelectorState(
          type: RangeSelectorStateType.error,
          message: "This is a error message",
        ),
      ),
    );
  });

  zGoldenTest("""When updating the widget, and passing a isInfinity true,
      while is not infinity, it should change the price to 0 if the type is min price""",
      goldenFileName: "range_selector_update_infinity_price_min_price", (tester) async {
    const key = Key("some-key");

    await tester.pumpDeviceBuilder(await goldenBuilder(key: key, type: RangeSelectorType.minPrice));
    await tester.enterText(find.byKey(key), "1000");
    await tester.pumpAndSettle();

    await tester.pumpDeviceBuilder(await goldenBuilder(isInfinity: true, key: key, type: RangeSelectorType.minPrice));
  });

  zGoldenTest("""When updating the widget, and passing a isInfinity true,
      while is not infinity, it should change the price to infinity if the type is max price
      """, goldenFileName: "range_selector_update_infinity_price_max_price", (tester) async {
    const key = Key("some-key");

    await tester.pumpDeviceBuilder(await goldenBuilder(key: key, type: RangeSelectorType.maxPrice));
    await tester.enterText(find.byKey(key), "1000");
    await tester.pumpAndSettle();

    await tester.pumpDeviceBuilder(await goldenBuilder(isInfinity: true, key: key, type: RangeSelectorType.maxPrice));
  });

  zGoldenTest(""""When updating the widget, and passing a different tick spacing
    than it was before, it should recalculate the typed price and callback it""", (tester) async {
    const expectedNewPrice = 1211.5369312111138;
    const typedPrice = "1200";
    const key = Key("some-key");
    double actualNewPrice = 0;

    await tester.pumpDeviceBuilder(await goldenBuilder(key: key, tickSpacing: 10));
    await tester.enterText(find.byKey(key), typedPrice);

    await tester.pumpDeviceBuilder(await goldenBuilder(
      key: key,
      tickSpacing: 1000,
      onPriceChanged: (price) => actualNewPrice = price,
    ));

    expect(actualNewPrice, expectedNewPrice);
  });

  zGoldenTest("When passing typing a price with isReversed, it should correctly adjust and callback",
      goldenFileName: "range_selector_is_reversed_typed_price", (tester) async {
    const expectedAdjustedTypedPrice = 1200.0823982564434;
    const typedPrice = "1200";
    double actualAdjustedTypedPrice = 0;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      isReversed: true,
      tickSpacing: 1,
      onPriceChanged: (price) {
        actualAdjustedTypedPrice = price;
      },
    ));

    await tester.enterText(find.byType(TextField), typedPrice);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(actualAdjustedTypedPrice, expectedAdjustedTypedPrice);
  });

  zGoldenTest("""When passing a price, and clicking the button to increase,
   it should increase the price by 2 ticks (based on the tick spacing)""",
      goldenFileName: "range_selector_increase_price", (tester) async {
    const expectedIncreasedPrice = 1201.8837824865475;
    const typedPrice = "1200";
    double actualIncreasedPrice = 0;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      onPriceChanged: (price) {
        actualIncreasedPrice = price;
      },
    ));

    await tester.enterText(find.byType(TextField), typedPrice);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("increase-button")));
    await tester.pumpAndSettle();

    expect(actualIncreasedPrice, expectedIncreasedPrice);
  });

  zGoldenTest("""When passing a price, and clicking the button to decrease,
   it should decrease the price by 2 ticks (based on the tick spacing)""",
      goldenFileName: "range_selector_decrease_price", (tester) async {
    const expectedDecreasedPrice = 1198.283713942248;
    const typedPrice = "1200";
    double actualDecreasedPrice = 0;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      onPriceChanged: (price) {
        actualDecreasedPrice = price;
      },
    ));

    await tester.enterText(find.byType(TextField), typedPrice);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("decrease-button")));
    await tester.pumpAndSettle();

    expect(actualDecreasedPrice, expectedDecreasedPrice);
  });

  zGoldenTest(
    "When typing a price with `isReversed` true, and clicking the button to increase, it should increase the price by 2 ticks",
    goldenFileName: "range_selector_is_reversed_increase_price",
    (tester) async {
      const expectedIncreasedPrice = 1200.682559475813;
      const typedPrice = "1200";
      double actualIncreasedPrice = 0;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        isReversed: true,
        onPriceChanged: (price) {
          actualIncreasedPrice = price;
        },
      ));

      await tester.enterText(find.byType(TextField), typedPrice);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("increase-button")));
      await tester.pumpAndSettle();

      expect(actualIncreasedPrice, expectedIncreasedPrice);
    },
  );

  zGoldenTest(
    """When typing a price with `isReversed` true, and clicking the button to decrease,
    it should decrease the price by 2 ticks""",
    goldenFileName: "range_selector_is_reversed_decrease_price",
    (tester) async {
      const expectedDecreasedPrice = 1197.0860890208119;
      const typedPrice = "1200";
      double actualDecreasedPrice = 0;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        isReversed: true,
        onPriceChanged: (price) {
          actualDecreasedPrice = price;
        },
      ));

      await tester.enterText(find.byType(TextField), typedPrice);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("decrease-button")));
      await tester.pumpAndSettle();

      expect(actualDecreasedPrice, expectedDecreasedPrice);
    },
  );

  zGoldenTest(
    "When the price is infinity, and click to increase, the price should increase to the minimum price based on the tick spacing",
    goldenFileName: "range_selector_is_infinity_increase_price",
    (tester) async {
      const expectedIncreasedPrice = 1.0010004501200209e-12;
      double actualIncreasedPrice = 0;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        isInfinity: true,
        poolToken0: TokenDto.fixture().copyWith(decimals: 6),
        poolToken1: TokenDto.fixture().copyWith(decimals: 18),
        onPriceChanged: (price) {
          actualIncreasedPrice = price;
        },
      ));

      await tester.tap(find.byKey(const Key("increase-button")));
      await tester.pumpAndSettle();

      expect(actualIncreasedPrice, expectedIncreasedPrice);
    },
  );

  zGoldenTest(
    """When the price is infinity, and click to increase with tokens reversed,
    the price should increase to the minimum price based on the tick spacing""",
    goldenFileName: "range_selector_is_infinity_increase_price_reversed",
    (tester) async {
      const expectedIncreasedPrice = 1.0008055719626048e-12;
      double actualIncreasedPrice = 0;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        isInfinity: true,
        isReversed: true,
        poolToken0: TokenDto.fixture().copyWith(decimals: 6),
        poolToken1: TokenDto.fixture().copyWith(decimals: 18),
        onPriceChanged: (price) {
          actualIncreasedPrice = price;
        },
      ));

      await tester.tap(find.byKey(const Key("increase-button")));
      await tester.pumpAndSettle();

      expect(actualIncreasedPrice, expectedIncreasedPrice);
    },
  );

  zGoldenTest(
    """When the price is infinity, and click to decrease with tokens reversed,
    the price should not change""",
    goldenFileName: "range_selector_is_infinity_decrease_price_reversed",
    (tester) async {
      const expectedIncreasedPrice = 0;
      double actualIncreasedPrice = 0;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        isInfinity: true,
        isReversed: true,
        poolToken0: TokenDto.fixture().copyWith(decimals: 6),
        poolToken1: TokenDto.fixture().copyWith(decimals: 18),
        onPriceChanged: (price) {
          actualIncreasedPrice = price;
        },
      ));

      await tester.tap(find.byKey(const Key("decrease-button")));
      await tester.pumpAndSettle();

      expect(actualIncreasedPrice, expectedIncreasedPrice);
    },
  );

  zGoldenTest(
    "When the price is infinity, and click to decrease, it should not change the price",
    goldenFileName: "range_selector_is_infinity_decrease_price",
    (tester) async {
      const expectedIncreasedPrice = 0;
      double actualIncreasedPrice = 0;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        isInfinity: true,
        poolToken0: TokenDto.fixture().copyWith(decimals: 6),
        poolToken1: TokenDto.fixture().copyWith(decimals: 18),
        onPriceChanged: (price) {
          actualIncreasedPrice = price;
        },
      ));

      await tester.tap(find.byKey(const Key("decrease-button")));
      await tester.pumpAndSettle();

      expect(actualIncreasedPrice, expectedIncreasedPrice);
    },
  );
}
