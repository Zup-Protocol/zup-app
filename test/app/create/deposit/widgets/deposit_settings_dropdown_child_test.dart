import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zup_app/app/create/deposit/widgets/deposit_settings_dropdown_child.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_core/zup_core.dart';

import '../../../../golden_config.dart';
import '../../../../mocks.dart';

void main() {
  setUp(() {
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();
    inject.registerFactory<GlobalKey<ScaffoldMessengerState>>(() => GlobalKey<ScaffoldMessengerState>());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder(
          {Slippage selectedSlippage = Slippage.onePercent,
          Duration selectedDeadline = const Duration(minutes: 30),
          void Function(Slippage slippage, Duration deadline)? onSettingsChanged}) async =>
      await goldenDeviceBuilder(
        SizedBox(
          height: 400,
          width: 500,
          child: Center(
            child: Builder(builder: (context) {
              return SizedBox(
                height: 400,
                width: 500,
                child: Center(
                  child: DepositSettingsDropdownChild(
                    context,
                    selectedSlippage: selectedSlippage,
                    selectedDeadline: selectedDeadline,
                    onSettingsChanged: onSettingsChanged ?? (slippage, deadline) {},
                  ),
                ),
              );
            }),
          ),
        ),
      );

  zGoldenTest(
    "When initialiazing the widget with a custom slippage, the text field should be filled with the custom value",
    goldenFileName: "deposit_settings_dropdown_child_custom_slippage",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(selectedSlippage: Slippage.custom(762)),
      );
    },
  );

  zGoldenTest(
    "When initialiazing the widget, the deadline text field should be filled with the passed deadline",
    goldenFileName: "deposit_settings_dropdown_child_deadline",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(selectedDeadline: const Duration(minutes: 1200)),
      );
    },
  );

  zGoldenTest(
    "When hovering over the slippage title, a tooltip explaining the slippage should appear",
    goldenFileName: "deposit_settings_dropdown_child_slippage_tooltip",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.hover(find.byKey(const Key("slippage-tooltip")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When clicking the 0.1% slippage, it should select it in the UI, and callback with the selected slippage",
    goldenFileName: "deposit_settings_dropdown_child_zero_point_one_percent_slippage",
    (tester) async {
      Slippage? expectedSlippage;
      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
        onSettingsChanged: (slippage, deadline) {
          expectedSlippage = slippage;
        },
      ));

      await tester.tap(find.byKey(const Key("zero-point-one-percent-slippage")));
      await tester.pumpAndSettle();

      expect(expectedSlippage, equals(Slippage.zeroPointOnePercent));
    },
  );

  zGoldenTest(
    "When clicking the 1% slippage, it should select it in the UI, and callback with the selected slippage",
    goldenFileName: "deposit_settings_dropdown_child_one_percent_slippage",
    (tester) async {
      Slippage? expectedSlippage;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
        onSettingsChanged: (slippage, deadline) {
          expectedSlippage = slippage;
        },
      ));

      await tester.tap(find.byKey(const Key("one-percent-slippage")));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(expectedSlippage, equals(Slippage.onePercent));
    },
  );

  zGoldenTest(
    "When clicking the 0.5% slippage, it should select it in the UI, and callback with the selected slippage",
    goldenFileName: "deposit_settings_dropdown_child_zero_point_five_percent_slippage",
    (tester) async {
      Slippage? expectedSlippage;

      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          selectedSlippage: Slippage.fromValue(21),
          onSettingsChanged: (slippage, deadline) => expectedSlippage = slippage,
        ),
      );

      await tester.tap(find.byKey(const Key("zero-point-five-percent-slippage")));
      await tester.pumpAndSettle();

      expect(expectedSlippage, equals(Slippage.fromValue(0.5)));
    },
  );

  zGoldenTest(
    "When typing in the text field, it should not callback with the slippage",
    (tester) async {
      Slippage? expectedSlippage;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
        onSettingsChanged: (slippage, deadline) => expectedSlippage = slippage,
      ));

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "123");
      await tester.pumpAndSettle();

      expect(expectedSlippage, null);
    },
  );

  zGoldenTest("""When typing a value greater than 50% in the slippage field and unfocusing it,
  it should reajust it to 50%, and callback with the new value (50%)""",
      goldenFileName: "deposit_settings_dropdown_child_custom_slippage_greater_than_50_adjust", (tester) async {
    Slippage? expectedSlippage;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      selectedSlippage: Slippage.halfPercent,
      onSettingsChanged: (slippage, deadline) => expectedSlippage = slippage,
    ));

    await tester.enterText(find.byKey(const Key("slippage-text-field")), "76");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(expectedSlippage, equals(Slippage.custom(50)));
  });

  zGoldenTest(
    "The slippage textfield should not allow caracteres other than numbers or a dot for decimal",
    goldenFileName: "deposit_settings_dropdown_child_slippage_textfield_disallowed_characters",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "a.,';;][');~]");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("""When typing a value lower than 50% in the slippage
  field and unfocusing it, it should callback with the new value typed""",
      goldenFileName: "deposit_settings_dropdown_child_custom_slippage_lower_than_50", (tester) async {
    Slippage? expectedSlippage;

    await tester.pumpDeviceBuilder(await goldenBuilder(
      selectedSlippage: Slippage.halfPercent,
      onSettingsChanged: (slippage, deadline) => expectedSlippage = slippage,
    ));

    await tester.enterText(find.byKey(const Key("slippage-text-field")), "3");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(expectedSlippage, equals(Slippage.custom(3.0)));
  });

  zGoldenTest("""When typing a value greater than 50% in the textfield, and not unfocusing it,
  it should be in error state (with the border red)""",
      goldenFileName: "deposit_settings_dropdown_child_custom_slippage_greater_than_50_error", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(
      selectedSlippage: Slippage.halfPercent,
    ));

    await tester.enterText(find.byKey(const Key("slippage-text-field")), "76");
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing a value greater than 1%, a warning about front running should be shown",
      goldenFileName: "deposit_settings_dropdown_child_front_running_warning", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(
      selectedSlippage: Slippage.halfPercent,
    ));

    await tester.enterText(find.byKey(const Key("slippage-text-field")), "1.1");
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When clicking `what's this` in the front runnning warning, it should launch a front running blog post",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
      ));

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "1.1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("whats-this-question-link")));
      await tester.pumpAndSettle();

      expect(
        UrlLauncherPlatformCustomMock.lastLaunchedUrl,
        "https://www.cyfrin.io/blog/what-is-blockchain-and-crypto-front-running",
      );
    },
  );

  zGoldenTest("When hovering the deadline title, a tooltip explaining the deadline should appear",
      goldenFileName: "deposit_settings_dropdown_child_deadline_tooltip", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(
      selectedSlippage: Slippage.halfPercent,
    ));

    await tester.hover(find.byKey(const Key("deadline-tooltip")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    """When typing a value greater than 1200 in the deadline,
    and unfocusing the textfield, it should adjust it to 1200,
    and callback with the new value (1200) """,
    goldenFileName: "deposit_settings_dropdown_child_deadline_greater_than_1200",
    (tester) async {
      Duration? expectedDeadline;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
        onSettingsChanged: (slippage, deadline) => expectedDeadline = deadline,
      ));

      await tester.enterText(find.byKey(const Key("deadline-textfield")), "1300");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(expectedDeadline, equals(const Duration(minutes: 1200)));
    },
  );

  zGoldenTest(
    """When typing a value lower than 1200 in the deadline, and unfocusing the textfield,
    it should callback with the new value passed""",
    goldenFileName: "deposit_settings_dropdown_child_deadline_lower_than_1200",
    (tester) async {
      Duration? expectedDeadline;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
        onSettingsChanged: (slippage, deadline) => expectedDeadline = deadline,
      ));

      await tester.enterText(find.byKey(const Key("deadline-textfield")), "600");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(expectedDeadline, equals(const Duration(minutes: 600)));
    },
  );

  zGoldenTest(
    "When typing not numbers in the deadline textfield, it should not allow it (will not even show them)",
    goldenFileName: "deposit_settings_dropdown_child_deadline_not_numbers",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
      ));

      await tester.enterText(find.byKey(const Key("deadline-textfield")), "a.,';;][');~]");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When typing a value greater than 1200 in the deadline,
    and not unfocusing the textfield, it should not callback
    and set the textfield to error state (with the border red),""",
    goldenFileName: "deposit_settings_dropdown_child_deadline_greater_than_1200_error",
    (tester) async {
      Duration? expectedDeadline;

      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
        onSettingsChanged: (slippage, deadline) {
          expectedDeadline = deadline;
        },
      ));

      await tester.enterText(find.byKey(const Key("deadline-textfield")), "1300");
      await tester.pumpAndSettle();

      expect(expectedDeadline, null);
    },
  );

  zGoldenTest(
    """When typing a custom value in the slippage,
  then selecting a default option, it should clear the textfield""",
    goldenFileName: "deposit_settings_dropdown_child_slippage_clear_textfield_after_selecting_default",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(
        selectedSlippage: Slippage.halfPercent,
      ));

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "12");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("zero-point-five-percent-slippage")));
      await tester.pumpAndSettle();
    },
  );
}
