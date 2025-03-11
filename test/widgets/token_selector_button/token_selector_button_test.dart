import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/widgets/token_card.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  late TokensRepository tokensRepository;
  late AppCubit appCubit;
  late Wallet wallet;

  setUp(() {
    tokensRepository = TokensRepositoryMock();
    appCubit = AppCubitMock();
    wallet = WalletMock();

    registerFallbackValue(Networks.sepolia);

    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerLazySingleton<TokenSelectorModalCubit>(
      () => TokenSelectorModalCubit(tokensRepository, appCubit, wallet),
    );
    inject.registerLazySingleton<Debouncer>(() => Debouncer(milliseconds: 0));

    when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => TokenListDto.fixture());

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder(TokenSelectorButtonController? controller, {bool isMobile = false}) async =>
      await goldenDeviceBuilder(
        Center(child: TokenSelectorButton(controller: controller ?? TokenSelectorButtonController())),
        device: isMobile ? GoldenDevice.mobile : GoldenDevice.square,
      );

  zGoldenTest("When the initialSelectedToken is not null in the controller, it should show the selected token",
      goldenFileName: "token_selector_button_initial_selected_token", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(TokenSelectorButtonController(initialSelectedToken: TokenDto.fixture())),
    );

    await tester.pumpAndSettle();
  });

  zGoldenTest("When the initialSelectedToken is null in the controller, it should show the state to select token",
      goldenFileName: "token_selector_button_initial_selected_token_null", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(TokenSelectorButtonController(initialSelectedToken: null)),
    );

    await tester.pumpAndSettle();
  });

  zGoldenTest("When pressing the button, it show the modal to select tokens",
      goldenFileName: "token_selector_button_click", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(TokenSelectorButtonController()),
        wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenSelectorButton));

    await tester.pumpAndSettle();
  });

  zGoldenTest(
    """When pressing the button in a mobile-size device,
  it should show a bottom sheet instead of a dialog to select tokens""",
    goldenFileName: "token_selector_button_click_mobile",
    (tester) async {
      await tester.pumpDeviceBuilder(
          await goldenBuilder(
            TokenSelectorButtonController(),
            isMobile: true,
          ),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
      await tester.tap(find.byType(TokenSelectorButton));

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When selecting a token in the modal, it should update the button state to selected",
      goldenFileName: "token_selector_button_selection", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(TokenSelectorButtonController()),
        wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenSelectorButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenCard).first);

    await tester.pumpAndSettle();
  });

  zGoldenTest("When hovering the button, it should show the hover state", goldenFileName: "token_selector_button_hover",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(
      TokenSelectorButtonController(),
    ));

    await tester.pumpAndSettle();
    await tester.hover(find.byType(TokenSelectorButton));

    await tester.pumpAndSettle();
  });
}
