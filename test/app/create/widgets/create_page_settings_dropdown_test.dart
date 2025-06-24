import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/create/widgets/create_page_settings_dropdown.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_core/zup_core.dart';

import '../../../golden_config.dart';
import '../../../mocks.dart';

void main() {
  late Cache cache;

  setUp(() {
    registerFallbackValue(PoolSearchSettingsDto());

    cache = CacheMock();

    inject.registerFactory<Cache>(() => cache);
    inject.registerFactory<Debouncer>(() => Debouncer(milliseconds: 0));

    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto.fixture());
    when(() => cache.savePoolSearchSettings(settings: any(named: "settings"))).thenAnswer((_) async {});
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(Center(
        child: CreatePageSettingsDropdown(
          onClose: () {},
        ),
      ));

  zGoldenTest(
    "When initializing the widget, it should immediately assign the cached min pool tvl to the min tvl field",
    goldenFileName: "create_page_settings_dropdown",
    (tester) async {
      final poolSearchSettingsDto = PoolSearchSettingsDto(minLiquidityUSD: 89765.23);

      when(() => cache.getPoolSearchSettings()).thenReturn(poolSearchSettingsDto);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When initializing the widget, and the cached min tvl is less than the default min tvl, it should show a warning",
    goldenFileName: "create_page_settings_dropdown_low_min_tvl_warning",
    (tester) async {
      final poolSearchSettingsDto = PoolSearchSettingsDto(
        minLiquidityUSD: PoolSearchSettingsDto.defaultMinLiquidityUSD - 1,
      );

      when(() => cache.getPoolSearchSettings()).thenReturn(poolSearchSettingsDto);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When hovering over the info icon in the min tvl field, it should show a tooltip explaining the field",
      goldenFileName: "create_page_settings_dropdown_min_liquidity_tooltip", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.hover(find.byKey(const Key("min-liquidity-tooltip")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When changing the min tvl field for a value less than the default, it should show a warning",
    goldenFileName: "create_page_settings_dropdown_min_liquidity_warning_field",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key("min-liquidity-field")),
        (PoolSearchSettingsDto.defaultMinLiquidityUSD - 1).toString(),
      );

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When typing in the min tvl field, it should update the cached min tvl",
    (tester) async {
      const typedMinLiquidity = 8721001234;
      final poolSearchSettingsDto = cache.getPoolSearchSettings();
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-liquidity-field")), typedMinLiquidity.toString());
      await tester.pumpAndSettle();

      verify(
        () => cache.savePoolSearchSettings(
          settings: poolSearchSettingsDto.copyWith(minLiquidityUSD: typedMinLiquidity),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When typing a non-numeric value in the min tvl field, it should not be written to the cache nor the field.
    The default value instead should be saved in the cache""",
    goldenFileName: "create_page_setting_dropdown_min_liquidity_non_numeric",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-liquidity-field")), "siuuaysfays*&%~]]/");
      await tester.pumpAndSettle();

      verify(
        () => cache.savePoolSearchSettings(
          settings: PoolSearchSettingsDto(
            minLiquidityUSD: PoolSearchSettingsDto.defaultMinLiquidityUSD,
          ),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    "When hovering over the info icon in the allowed pool types section, it should show a tooltip explaining the field",
    goldenFileName: "create_page_settings_dropdown_pool_types_tooltip_hover",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.hover(find.byKey(const Key("pool-types-allowed-tooltip")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When clicking to disable the v4 switch, it should update the UI",
      goldenFileName: "create_page_settings_dropdown_v4_pool_type_disabled", (tester) async {
    when(() => cache.getPoolSearchSettings()).thenReturn(
      PoolSearchSettingsDto().copyWith(allowV4Search: true),
    );

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    when(() => cache.getPoolSearchSettings()).thenReturn(
      PoolSearchSettingsDto().copyWith(allowV4Search: false),
    ); // using this when because it fetches again after click

    await tester.tap(find.byKey(const Key("pool-types-allowed-v4-switch")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking to disable the v3 switch, it should update the UI",
      goldenFileName: "create_page_settings_dropdown_v3_pool_type_disabled", (tester) async {
    when(() => cache.getPoolSearchSettings()).thenReturn(
      PoolSearchSettingsDto().copyWith(allowV3Search: true),
    );

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    when(() => cache.getPoolSearchSettings()).thenReturn(
      PoolSearchSettingsDto().copyWith(allowV3Search: false),
    ); // using this when because it fetches again after click

    await tester.tap(find.byKey(const Key("pool-types-allowed-v3-switch")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When clicking to disable the v4 switch, it should call the cache to update the settings only for the v4 switch",
    (tester) async {
      final initialSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: true, allowV4Search: true);
      when(() => cache.getPoolSearchSettings()).thenReturn(initialSettings);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-types-allowed-v4-switch")));
      await tester.pumpAndSettle();

      verify(
        () => cache.savePoolSearchSettings(settings: initialSettings.copyWith(allowV4Search: false)),
      ).called(1);
    },
  );

  zGoldenTest(
    "When clicking to disable the v3 switch, it should call the cache to update the settings only for the v3 switch",
    (tester) async {
      final initialSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: true, allowV4Search: true);
      when(() => cache.getPoolSearchSettings()).thenReturn(initialSettings);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-types-allowed-v3-switch")));
      await tester.pumpAndSettle();

      verify(
        () => cache.savePoolSearchSettings(settings: initialSettings.copyWith(allowV3Search: false)),
      ).called(1);
    },
  );

  zGoldenTest("When clicking to enable the v4 switch, it should update the UI",
      goldenFileName: "create_page_settings_dropdown_v4_pool_type_enable", (tester) async {
    final initialSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: false, allowV4Search: false);
    when(() => cache.getPoolSearchSettings()).thenReturn(
      initialSettings,
    );

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    when(() => cache.getPoolSearchSettings()).thenReturn(
      initialSettings.copyWith(allowV4Search: true),
    ); // using this when because it fetches again after click

    await tester.tap(find.byKey(const Key("pool-types-allowed-v4-switch")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking to disable the v3 switch, it should update the UI",
      goldenFileName: "create_page_settings_dropdown_v3_pool_type_enable", (tester) async {
    final initialSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: false, allowV4Search: false);

    when(() => cache.getPoolSearchSettings()).thenReturn(initialSettings);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    when(() => cache.getPoolSearchSettings()).thenReturn(
      initialSettings.copyWith(allowV3Search: true),
    ); // using this when because it fetches again after click

    await tester.tap(find.byKey(const Key("pool-types-allowed-v3-switch")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When clicking to enable the v4 switch, it should call the cache to update the settings only for the v4 switch",
    (tester) async {
      final initialSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: false, allowV4Search: false);
      when(() => cache.getPoolSearchSettings()).thenReturn(initialSettings);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-types-allowed-v4-switch")));
      await tester.pumpAndSettle();

      verify(
        () => cache.savePoolSearchSettings(settings: initialSettings.copyWith(allowV4Search: true)),
      ).called(1);
    },
  );

  zGoldenTest(
    "When clicking to disable the v3 switch, it should call the cache to update the settings only for the v3 switch",
    (tester) async {
      final initialSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: false, allowV4Search: false);
      when(() => cache.getPoolSearchSettings()).thenReturn(initialSettings);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("pool-types-allowed-v3-switch")));
      await tester.pumpAndSettle();

      verify(
        () => cache.savePoolSearchSettings(settings: initialSettings.copyWith(allowV3Search: true)),
      ).called(1);
    },
  );
}
