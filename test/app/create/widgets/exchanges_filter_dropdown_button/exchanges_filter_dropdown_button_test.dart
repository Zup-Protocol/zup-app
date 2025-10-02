import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/create/widgets/exchanges_filter_dropdown_button/exchanges_filter_dropdown_button.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_singleton_cache.dart';

import '../../../../golden_config.dart';
import '../../../../mocks.dart';

void main() {
  late ZupSingletonCache zupSingletonCache;
  late ProtocolRepository protocolRepository;
  late ZupCachedImage zupCachedImage;
  late AppCache cache;

  setUp(() {
    zupSingletonCache = ZupSingletonCache.shared;
    protocolRepository = ProtocolRepositoryMock();
    zupCachedImage = mockZupCachedImage();
    cache = AppCacheMock();

    when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer((_) => Future.value([]));
    when(() => cache.blockedProtocolsIds).thenReturn([]);

    inject.registerFactory<ZupSingletonCache>(() => zupSingletonCache);
    inject.registerFactory<ProtocolRepository>(() => protocolRepository);
    inject.registerFactory<ZupCachedImage>(() => zupCachedImage);
    inject.registerFactory<AppCache>(() => cache);
  });

  tearDown(() {
    inject.reset();
    zupSingletonCache.clear();
  });

  Future<DeviceBuilder> goldenBuilder() async =>
      await goldenDeviceBuilder(const Center(child: ExchangesFilterDropdownButton()));

  zGoldenTest(
    """When the widget is created, it should call the cubit to get the exchanges
  and show a preview of the exchanges count""",
    goldenFileName: "exchanges_filter_dropdown_button",
    (tester) async {
      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer(
        (_) async => [
          const ProtocolDto(name: "C"),
          const ProtocolDto(name: "A"),
          const ProtocolDto(name: "B"),
          const ProtocolDto(name: "A"),
        ],
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      verify(() => protocolRepository.getAllSupportedProtocols()).called(1);
    },
  );

  zGoldenTest(
    """When the widget is created, it should call the cubit to get the exchanges.
  If some of the exchanges are blocked by the user, the button should show a counter with
  the number of total exchanages slash blocked exchanges""",
    goldenFileName: "exchanges_filter_dropdown_button_blocked_exchanges_counter",
    (tester) async {
      final blockedProtocolsIds = ["32983", "sag", "nnnn", "dale"];
      when(() => cache.blockedProtocolsIds).thenReturn(blockedProtocolsIds);

      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer(
        (_) async => [
          ProtocolDto(name: "C", rawId: blockedProtocolsIds[0]),
          ProtocolDto(name: "A", rawId: blockedProtocolsIds[1]),
          ProtocolDto(name: "B", rawId: blockedProtocolsIds[2]),
          const ProtocolDto(name: "A", rawId: "some other id not blocked"),
        ],
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the cubit state is error, it should show only "Exchanges" in the button,
    without the counter""",
    goldenFileName: "exchanges_filter_dropdown_button_error_counter",
    (tester) async {
      when(() => protocolRepository.getAllSupportedProtocols()).thenThrow(Exception());

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );
  zGoldenTest(
    """When the cubit state is error, and the user clicks the button,
    it should show a snackbar saying to try to refresh the page""",
    goldenFileName: "exchanges_filter_dropdown_button_error_click",
    (tester) async {
      when(() => protocolRepository.getAllSupportedProtocols()).thenThrow(Exception());

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("exchanges-filter-dropdown-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is success, and the user clicks the button, it should
    show a dropdown to select and unselect exchanges""",
    goldenFileName: "exchanges_filter_dropdown_button_click",
    (tester) async {
      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer(
        (_) async => [
          const ProtocolDto(name: "C"),
          const ProtocolDto(name: "A"),
          const ProtocolDto(name: "B"),
          const ProtocolDto(name: "A"),
        ],
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("exchanges-filter-dropdown-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is success, and the user clicks the button, it should
    show a dropdown to select and unselect exchanges. The exchanges that
    are blocked already in the cache, should be unchecked""",
    goldenFileName: "exchanges_filter_dropdown_button_click_with_blocked_exchanges",
    (tester) async {
      final blockedProtocolsIds = ["32983", "sag", "nnnn", "dale"];
      when(() => cache.blockedProtocolsIds).thenReturn(blockedProtocolsIds);

      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer(
        (_) async => [
          ProtocolDto(name: "A", rawId: blockedProtocolsIds[0]),
          const ProtocolDto(name: "B", rawId: "some other id not blocked"),
          ProtocolDto(name: "C", rawId: blockedProtocolsIds[2]),
          const ProtocolDto(name: "D", rawId: "some other id not blocked"),
        ],
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("exchanges-filter-dropdown-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is success, and the user clicks the button, it should
    show a dropdown to select and unselect exchanges. When the user clicks
    on a checked exchange, it should save to the cache as blocked exchange""",
    (tester) async {
      final blockedProtocolsIds = ["32983", "sag", "nnnn", "dale"];
      final allProtocols = [
        ProtocolDto(name: "A", rawId: blockedProtocolsIds[0]),
        const ProtocolDto(name: "B", rawId: "some other id not blocked"),
        ProtocolDto(name: "C", rawId: blockedProtocolsIds[2]),
        const ProtocolDto(name: "D", rawId: "some other id not blocked"),
      ];

      when(
        () => cache.saveBlockedProtocolIds(blockedProtocolIds: any(named: "blockedProtocolIds")),
      ).thenAnswer((_) async => {});
      when(() => cache.blockedProtocolsIds).thenReturn(blockedProtocolsIds);
      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer((_) async => allProtocols);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("exchanges-filter-dropdown-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("checkbox-item-1")));
      await tester.pumpAndSettle();

      verify(
        () => cache.saveBlockedProtocolIds(
          blockedProtocolIds: [blockedProtocolsIds[0], "some other id not blocked", blockedProtocolsIds[2]],
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When the state is success, and the user clicks the button, it should
    show a dropdown to select and unselect exchanges. When the user clicks
    on a unchecked exchange, it should remove it from the saved cached""",
    (tester) async {
      final blockedProtocolsIds = ["32983", "sag", "nnnn", "dale"];
      final allProtocols = [
        ProtocolDto(name: "A", rawId: blockedProtocolsIds[0]),
        const ProtocolDto(name: "B", rawId: "some other id not blocked"),
        ProtocolDto(name: "C", rawId: blockedProtocolsIds[2]),
        const ProtocolDto(name: "D", rawId: "some other id not blocked"),
      ];

      when(
        () => cache.saveBlockedProtocolIds(blockedProtocolIds: any(named: "blockedProtocolIds")),
      ).thenAnswer((_) async => {});
      when(() => cache.blockedProtocolsIds).thenReturn(blockedProtocolsIds);
      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer((_) async => allProtocols);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("exchanges-filter-dropdown-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("checkbox-item-0")));
      await tester.pumpAndSettle();

      verify(() => cache.saveBlockedProtocolIds(blockedProtocolIds: ["nnnn"])).called(1);
    },
  );
}
