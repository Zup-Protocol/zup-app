import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/create_page.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  late AppCubit appCubit;
  late Cache cache;

  setUp(() {
    appCubit = AppCubitMock();
    cache = CacheMock();

    inject.registerFactory<Cache>(() => cache);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupNavigator>(() => ZupNavigatorMock());
    inject.registerFactory<ZupSingletonCache>(() => ZupSingletonCache.shared);
    inject.registerFactory<ProtocolRepository>(() => ProtocolRepositoryMock());

    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto.fixture());
    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() => inject.reset());
  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(const CreatePage());

  zGoldenTest("When loading the create page, it should show the token selection stage",
      goldenFileName: "create_page_initial_stage", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();
  });
}
