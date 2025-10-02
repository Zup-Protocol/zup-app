import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/create_page_select_tokens_stage.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/token_card.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  late AppCubit appCubit;
  late TokensRepository tokensRepository;
  late Wallet wallet;
  late AppCache cache;
  late ZupNavigator zupNavigator;
  late ProtocolRepository protocolRepository;
  late ZupSingletonCache zupSingletonCache;

  setUp(() {
    appCubit = AppCubitMock();
    tokensRepository = TokensRepositoryMock();
    wallet = WalletMock();
    zupNavigator = ZupNavigatorMock();
    protocolRepository = ProtocolRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;

    registerFallbackValue(AppNetworks.sepolia);

    cache = AppCacheMock();
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<Debouncer>(() => Debouncer(milliseconds: 0));
    inject.registerFactory<ZupNavigator>(() => zupNavigator);
    inject.registerFactory<AppCache>(() => cache);
    inject.registerFactory<ZupSingletonCache>(() => zupSingletonCache);
    inject.registerFactory<ProtocolRepository>(() => protocolRepository);

    inject.registerLazySingleton<TokenSelectorModalCubit>(
      () => TokenSelectorModalCubit(tokensRepository, appCubit, wallet),
    );
    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto.fixture());
    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
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
    goldenFileName: "create_page_select_tokens_stage_default_a_token",
    (tester) async {
      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the device is mobile, it should have a horizontal padding, and less padding on the top",
    goldenFileName: "create_page_select_tokens_stage_mobile",
    (tester) async {
      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);

      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When selecting the B token with the same address as A token, it should change the A token to null, and the B token to the selected token",
    goldenFileName: "create_page_select_tokens_stage_change_b_token_to_same_token_as_a",
    (tester) async {
      const selectedNetwork = AppNetworks.sepolia;
      when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
      when(() => appCubit.currentChainId).thenReturn(selectedNetwork.chainId);

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.tap(find.byKey(const Key("token-a-selector")));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TokenCard).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("token-b-selector")));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TokenCard).first);
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When selecting the A token with the same address as B token, it should change the B token to null and the A token to the selected token",
    goldenFileName: "create_page_select_tokens_stage_change_a_token_to_same_token_as_b",
    (tester) async {
      const selectedNetwork = AppNetworks.sepolia;
      when(() => appCubit.currentChainId).thenReturn(selectedNetwork.chainId);

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
    },
  );

  zGoldenTest(
    "When the token A is selected, but the token B is not, the button to find liquidity should be disabled",
    goldenFileName: "create_page_select_tokens_stage_token_a_selected_disabled_button",
    (tester) async {
      const selectedNetwork = AppNetworks.sepolia;

      when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

      await tester.tap(find.byKey(const Key("token-a-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TokenCard).first);
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the token B is selected, and the token A is also selected, the button to find liquidity should be enabled",
    goldenFileName: "create_page_select_tokens_stage_token_enabled_button",
    (tester) async {
      const token0Name = "Token1";
      const token1Name = "Token2";

      when(() => appCubit.currentChainId).thenAnswer((_) => appCubit.selectedNetwork.chainId);
      when(() => tokensRepository.getTokenList(any())).thenAnswer(
        (_) async => (TokenListDto(
          popularTokens: [
            TokenDto(addresses: {appCubit.selectedNetwork.chainId: token1Name}, name: token0Name),
            TokenDto(addresses: {appCubit.selectedNetwork.chainId: token0Name}, name: token1Name),
          ],
        )),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

      await tester.tap(find.byKey(const Key("token-a-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(token0Name));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("token-b-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(token1Name));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When tokens are selected, but the app cubit notify about the app network change,
  it should reset the tokens.""",
    goldenFileName: "create_page_select_tokens_stage_reset_tokens_from_network",
    (tester) async {
      final networkStream = StreamController<AppNetworks>();

      when(() => appCubit.selectedNetworkStream).thenAnswer((_) => networkStream.stream);
      when(() => appCubit.currentChainId).thenAnswer((_) => appCubit.selectedNetwork.chainId);

      const token0Name = "Token1";
      const token1Name = "Token2";

      when(() => tokensRepository.getTokenList(any())).thenAnswer(
        (_) async => (TokenListDto(
          popularTokens: [
            TokenDto(addresses: {appCubit.selectedNetwork.chainId: "token1"}, name: "Token1"),
            TokenDto(addresses: {appCubit.selectedNetwork.chainId: "token2"}, name: "Token2"),
          ],
        )),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

      await tester.tap(find.byKey(const Key("token-a-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(token0Name));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("token-b-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(token1Name));
      await tester.pumpAndSettle();

      networkStream.add(AppNetworks.mainnet);
    },
  );

  zGoldenTest(
    "When the saved pool search settings are not the default ones, a badge should be shown in the config button",
    goldenFileName: "create_page_select_tokens_stage_pool_search_settings_not_default",
    (tester) async {
      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 129793782.32));
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    },
  );

  zGoldenTest(
    "When the saved pool search settings are the default ones, a badge should not be shown in the config button",
    goldenFileName: "create_page_select_tokens_stage_pool_search_settings_default",
    (tester) async {
      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto());
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    },
  );

  zGoldenTest(
    "When clicking the settings button, the pool search settings dropdown should be opened",
    goldenFileName: "create_page_select_tokens_stage_pool_search_settings_open",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.tap(find.byKey(const Key("pool-search-settings-button"))); // open the dropdown
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When opening the pool search settings dropdown,
  changing the search settings for the default one, and closing it,
  the badge should be removed from the button""",
    goldenFileName: "create_page_select_tokens_stage_pool_search_settings_remove_badge",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.tap(find.byKey(const Key("pool-search-settings-button"))); // open the dropdown
      await tester.pumpAndSettle();

      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto());

      await tester.tap(find.byKey(const Key("pool-search-settings-button"))); // close the dropdown
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When opening the pool search settings dropdown,
  changing the search settings from the default to a custom one,
  and closing it, the badge should be added to the button""",
    goldenFileName: "create_page_select_tokens_stage_pool_search_settings_add_badge",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.tap(find.byKey(const Key("pool-search-settings-button"))); // open the dropdown
      await tester.pumpAndSettle();

      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 821567152.21));

      await tester.tap(find.byKey(const Key("pool-search-settings-button"))); // close the dropdown
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the network is all networks, clicking the search button should pass the internal ids as token ids to the next stage",
    (tester) async {
      const token0Id = "32";
      const token1Id = "87";

      final tokens = [
        TokenDto.fixture().copyWith(
          name: "TokenA",
          internalId: token0Id,
          addresses: {appCubit.selectedNetwork.chainId: token0Id},
        ),
        TokenDto.fixture().copyWith(
          name: "TokenB",
          internalId: token1Id,
          addresses: {appCubit.selectedNetwork.chainId: token1Id},
        ),
      ];

      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.allNetworks);
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => TokenListDto(popularTokens: tokens));
      when(
        () => zupNavigator.navigateToYields(
          group0: any(named: "group0"),
          group1: any(named: "group1"),
          network: any(named: "network"),
          token0: any(named: "token0"),
          token1: any(named: "token1"),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

      await tester.tap(find.byKey(const Key("token-a-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tokens[0].name).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("token-b-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tokens[1].name).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("search-button")));
      await tester.pumpAndSettle();

      verify(
        () => zupNavigator.navigateToYields(
          token0: token0Id,
          token1: token1Id,
          network: AppNetworks.allNetworks,
          group0: null,
          group1: null,
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    "When selecting two token groups, and then clicking to search, it should pass the groups ids to the next stage",
    (tester) async {
      final tokenGroups = [TokenGroupDto.fixture(), const TokenGroupDto(id: "group2", name: "Group 2")];

      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.allNetworks);
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => TokenListDto(tokenGroups: tokenGroups));
      when(
        () => zupNavigator.navigateToYields(
          group0: any(named: "group0"),
          group1: any(named: "group1"),
          network: any(named: "network"),
          token0: any(named: "token0"),
          token1: any(named: "token1"),
        ),
      ).thenAnswer((_) async {
        return;
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

      await tester.tap(find.byKey(const Key("token-a-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tokenGroups[0].name).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("token-b-selector")));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tokenGroups[1].name).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("search-button")));
      await tester.pumpAndSettle();

      verify(
        () => zupNavigator.navigateToYields(
          token0: null,
          token1: null,
          network: AppNetworks.allNetworks,
          group0: tokenGroups[0].id,
          group1: tokenGroups[1].id,
        ),
      ).called(1);
    },
  );
}
