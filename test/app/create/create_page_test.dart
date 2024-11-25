import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/create_page.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  late AppCubit appCubit;

  setUp(() {
    appCubit = AppCubitMock();

    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupNavigator>(() => ZupNavigatorMock());

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);
  });

  tearDown(() => inject.reset());
  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(const CreatePage());

  zGoldenTest("When loading the create page, it should show the token selection stage",
      goldenFileName: "create_page_initial_stage", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();
  });
}
