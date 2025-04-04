import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/create_page_select_tokens_stage.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/token_card.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  late AppCubit appCubit;
  late TokensRepository tokensRepository;
  late Wallet wallet;

  setUp(() {
    appCubit = AppCubitMock();
    tokensRepository = TokensRepositoryMock();
    wallet = WalletMock();

    registerFallbackValue(Networks.sepolia);

    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<Debouncer>(() => Debouncer(milliseconds: 0));
    inject.registerFactory<ZupNavigator>(() => ZupNavigatorMock());
    inject.registerLazySingleton<TokenSelectorModalCubit>(
      () => TokenSelectorModalCubit(tokensRepository, appCubit, wallet),
    );

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);
    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => const Stream.empty());
    when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => TokenListDto.fixture());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({bool isMobile = false}) async => await goldenDeviceBuilder(
        const CreatePageSelectTokensStage(),
        device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
      );

  zGoldenTest(
      "When loading the page, it should select only the A token as the default token for the selected network (the token B should not be selected)",
      goldenFileName: "create_page_select_tokens_stage_default_a_token", (tester) async {
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When the device is mobile, it should have a horizontal padding, and less padding on the top",
      goldenFileName: "create_page_select_tokens_stage_mobile", (tester) async {
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);

    await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When selecting the B token with the same address as A token, it should change the A token to null, and the B token to the selected token",
      goldenFileName: "create_page_select_tokens_stage_change_b_token_to_same_token_as_a", (tester) async {
    const selectedNetwork = Networks.sepolia;
    final token0 = selectedNetwork.wrappedNative;

    when(() => tokensRepository.getTokenList(any())).thenAnswer(
      (_) async => TokenListDto.fixture().copyWith(
        mostUsedTokens: [token0],
        popularTokens: [token0],
        userTokens: [token0],
      ),
    );

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.tap(find.byKey(const Key("token-b-selector")));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TokenCard).first);
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When selecting the A token with the same address as B token, it should change the B token to null and the A token to the selected token",
      goldenFileName: "create_page_select_tokens_stage_change_a_token_to_same_token_as_b", (tester) async {
    const selectedNetwork = Networks.sepolia;
    final token0 = selectedNetwork.wrappedNative;

    when(() => tokensRepository.getTokenList(any())).thenAnswer(
      (_) async => TokenListDto.fixture().copyWith(
        mostUsedTokens: [token0],
        popularTokens: [token0],
        userTokens: [token0],
      ),
    );

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    /// making token A to be null by selecting the same token as A in token B
    await tester.tap(find.byKey(const Key("token-b-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenCard).first);
    await tester.pumpAndSettle();

    /// just to make sure that the change ocurred, so it is using the same golden file as the inverse test
    await screenMatchesGolden(tester, "create_page_select_tokens_stage_change_b_token_to_same_token_as_a");

    /// real test
    await tester.tap(find.byKey(const Key("token-a-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenCard).first);
    await tester.pumpAndSettle();
  });

  zGoldenTest("When the token A is selected, but the token B is not, the button to find liquidity should be disabled",
      goldenFileName: "create_page_select_tokens_stage_token_a_selected_disabled_button", (tester) async {
    const selectedNetwork = Networks.sepolia;

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.tap(find.byKey(const Key("token-a-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TokenCard).first);
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When the token B is selected, and the token A is also selected, the button to find liquidity should be enabled",
      goldenFileName: "create_page_select_tokens_stage_token_enabled_button", (tester) async {
    const token0Name = "Token1";
    const token1Name = "Token2";

    when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => const TokenListDto(popularTokens: [
          TokenDto(address: "token1", name: "Token1"),
          TokenDto(address: "token2", name: "Token2"),
        ]));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.tap(find.byKey(const Key("token-a-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(token0Name));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("token-b-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(token1Name));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When tokens are selected, but the app cubit notify about the app network change,
  it should reset the tokens.""", goldenFileName: "create_page_select_tokens_stage_reset_tokens_from_network",
      (tester) async {
    final networkStream = StreamController<Networks>();

    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => networkStream.stream);

    const token0Name = "Token1";
    const token1Name = "Token2";

    when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => const TokenListDto(popularTokens: [
          TokenDto(address: "token1", name: "Token1"),
          TokenDto(address: "token2", name: "Token2"),
        ]));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.tap(find.byKey(const Key("token-a-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(token0Name));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("token-b-selector")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(token1Name));
    await tester.pumpAndSettle();

    networkStream.add(Networks.mainnet);
  });
}
