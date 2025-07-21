import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/create/widgets/exchanges_filter_dropdown_button/exchanges_filter_dropdown_button_cubit.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_core/zup_singleton_cache.dart';

import '../../../../mocks.dart';

void main() {
  late ExchangesFilterDropdownButtonCubit sut;
  late ProtocolRepository protocolRepository;
  late ZupSingletonCache zupSingletonCache;

  setUp(() {
    protocolRepository = ProtocolRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;

    sut = ExchangesFilterDropdownButtonCubit(protocolRepository, zupSingletonCache);

    when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer((_) => Future.value([]));
  });

  tearDown(() => zupSingletonCache.clear());

  test("When calling 'getSupportedProtocols' it should emit the loading state", () async {
    expectLater(sut.stream, emits(const ExchangesFilterDropdownButtonState.loading()));

    await sut.getSupportedProtocols();
  });

  test(
    "When calling `getSupportedProtocols` and it succeds, it should sort the list by name",
    () async {
      final protocolListAnswer = [
        const ProtocolDto(name: "C"),
        const ProtocolDto(name: "A"),
        const ProtocolDto(name: "B"),
        const ProtocolDto(name: "A"),
      ];

      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer((_) => Future.value(protocolListAnswer));

      await sut.getSupportedProtocols();

      expect(
        sut.protocols,
        protocolListAnswer..sort((a, b) => a.name.compareTo(b.name)),
      );
    },
  );

  test(
    """When calling `getSupportedProtocols` and it succeds, it should emit success state with
    the sorted list by name""",
    () async {
      final protocolListAnswer = [
        const ProtocolDto(name: "C"),
        const ProtocolDto(name: "A"),
        const ProtocolDto(name: "B"),
        const ProtocolDto(name: "A"),
      ];

      when(() => protocolRepository.getAllSupportedProtocols()).thenAnswer((_) => Future.value(protocolListAnswer));

      await sut.getSupportedProtocols();

      expect(
        sut.state,
        ExchangesFilterDropdownButtonState.success(protocolListAnswer..sort((a, b) => a.name.compareTo(b.name))),
      );
    },
  );

  test("When an error happens while calling `getSupportedProtocols`, it should emit error state`", () async {
    when(() => protocolRepository.getAllSupportedProtocols()).thenThrow(Exception());

    await sut.getSupportedProtocols();

    expect(sut.state, const ExchangesFilterDropdownButtonState.error());
  });

  test(
    """When calling `getSupportedProtocols` it should use the zupSingletonCache
  to make the request ands cache it with no experation""",
    () async {
      zupSingletonCache = ZupSingletonCacheMock();
      sut = ExchangesFilterDropdownButtonCubit(protocolRepository, zupSingletonCache);

      when(() => zupSingletonCache.clear()).thenAnswer((_) => Future.value());
      when(() => zupSingletonCache.run<List<ProtocolDto>>(
            any(),
            key: any(named: "key"),
            expiration: any(named: "expiration"),
            ignoreCache: any(named: "ignoreCache"),
          )).thenAnswer((_) => Future.value([]));

      await sut.getSupportedProtocols();

      verify(() => zupSingletonCache.run<List<ProtocolDto>>(
            any(),
            key: "zup-supported-protocols",
            expiration: null,
            ignoreCache: false,
          )).called(1);
    },
  );
}
