import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  late TokenSelectorModalCubit cubit;
  late TokensRepository tokensRepository;
  late AppCubit appCubit;

  setUp(() {
    appCubit = AppCubitMock();
    tokensRepository = TokensRepositoryMock();

    cubit = TokenSelectorModalCubitMock();

    inject.registerFactory<TokenSelectorModalCubit>(() => cubit);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<Debouncer>(() => Debouncer(milliseconds: 0));

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.base);
    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => TokenListDto.fixture());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.state).thenReturn(const TokenSelectorModalState.initial());
    when(() => cubit.loadData()).thenAnswer((_) async {});
    when(() => cubit.searchToken(any())).thenAnswer((_) async {});
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({Function(TokenDto)? onSelectToken}) async => await goldenDeviceBuilder(
        Builder(builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            TokenSelectorModal.show(context, onSelectToken: onSelectToken ?? (token) {});
          });

          return const SizedBox();
        }),
      );

  zGoldenTest("When initializing the modal, it should immediately load the token list", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();

    verify(() => cubit.loadData()).called(1);
  });

  zGoldenTest("When typing on the search field, it should use the debouncer", (tester) async {
    final debouncer = DebouncerMock();
    const search = "dale search";

    await inject.unregister<Debouncer>();
    inject.registerFactory<Debouncer>(() => debouncer);

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("search-token-field")), search);
    await tester.pumpAndSettle();

    verify(() => debouncer.run(any())).called(1);
  });

  zGoldenTest("When typing on the search field, it should ask search for tokens in the cubit", (tester) async {
    const search = "dale search";

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("search-token-field")), search);
    await tester.pumpAndSettle();

    verify(() => cubit.searchToken(search)).called(1);
  });

  zGoldenTest("When cleaning the search query, it should call load data from cubit, in order to reset the state",
      (tester) async {
    when(() => cubit.searchToken(any())).thenAnswer((_) async {});

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("search-token-field")), "dale search");
    await tester.enterText(find.byKey(const Key("search-token-field")), "");

    verify(() => cubit.loadData()).called(2); // 2 because of the initial one
  });

  zGoldenTest("When the error state is emitted, it should show the error state",
      goldenFileName: "token_selector_modal_error_state", (tester) async {
    when(() => cubit.state).thenReturn(const TokenSelectorModalState.error());

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the helper button of the error state, it should get again the token list", (tester) async {
    when(() => cubit.state).thenReturn(const TokenSelectorModalState.error());

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => cubit.loadData()).called(2); // 2 because of the initial one
  });

  zGoldenTest("When the search error is emitted, it should show the search error state",
      goldenFileName: "token_selector_modal_search_error_state", (tester) async {
    const searchedTerm = "dale search";

    when(() => cubit.state).thenReturn(const TokenSelectorModalState.searchError(searchedTerm));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("search-token-field")), searchedTerm);
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the helper button of the search error state, it should try search again", (tester) async {
    const searchTerm = "dale search";

    when(() => cubit.state).thenReturn(const TokenSelectorModalState.searchError(searchTerm));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("search-token-field")), searchTerm);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => cubit.searchToken(searchTerm)).called(2); // 2 because of the initial one
  });

  zGoldenTest("When the state is search not found, it should show the not found state",
      goldenFileName: "token_selector_modal_search_not_found", (tester) async {
    const searchTerm = "dale search";

    when(() => cubit.state).thenReturn(const TokenSelectorModalState.searchNotFound(searchTerm));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When the state search loading is emitted, it should show the loading state",
      goldenFileName: "token_selector_modal_search_loading", (tester) async {
    when(() => cubit.state).thenReturn(const TokenSelectorModalState.searchLoading());

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When the state is search success, it should show the search success state",
      goldenFileName: "token_selector_modal_search_success", (tester) async {
    final tokenList = List.generate(10, (_) => TokenDto.fixture());

    when(() => cubit.state).thenReturn(TokenSelectorModalState.searchSuccess(tokenList));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When the state is loading, it should show the loading state",
      goldenFileName: "token_selector_modal_loading", (tester) async {
    when(() => cubit.state).thenReturn(const TokenSelectorModalState.loading());

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When the state is success, it should show the success state",
      goldenFileName: "token_selector_modal_success", (tester) async {
    final tokenList = TokenListDto.fixture();

    when(() => cubit.state).thenReturn(TokenSelectorModalState.success(tokenList));

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the mini button, it should callback with selected token", (tester) async {
    const tokenList = TokenListDto(
      mostUsedTokens: [TokenDto(address: "addr"), TokenDto()],
      popularTokens: [TokenDto()],
      userTokens: [TokenDto()],
    );
    TokenDto? selectedToken;

    when(() => cubit.state).thenReturn(const TokenSelectorModalState.success(tokenList));

    await tester.pumpDeviceBuilder(
        await goldenBuilder(
          onSelectToken: (token) {
            return selectedToken = token;
          },
        ),
        wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("most-used-token-0")));
    await tester.pumpAndSettle();

    expect(selectedToken.hashCode, tokenList.mostUsedTokens.first.hashCode);
  });

  zGoldenTest("When clicking the token card in the `My Tokens` section, it should callback with selected token",
      (tester) async {
    const tokenList = TokenListDto(
      mostUsedTokens: [TokenDto(address: "addr"), TokenDto()],
      popularTokens: [TokenDto()],
      userTokens: [TokenDto()],
    );
    TokenDto? selectedToken;

    when(() => cubit.state).thenReturn(const TokenSelectorModalState.success(tokenList));

    await tester.pumpDeviceBuilder(
        await goldenBuilder(
          onSelectToken: (token) {
            return selectedToken = token;
          },
        ),
        wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("user-token-0")));
    await tester.pumpAndSettle();

    expect(selectedToken.hashCode, tokenList.userTokens.first.hashCode);
  });

  zGoldenTest("When clicking the token card in the `Popular Tokens` section, it should callback with selected token",
      (tester) async {
    const tokenList = TokenListDto(
      mostUsedTokens: [TokenDto(address: "addr"), TokenDto()],
      popularTokens: [TokenDto()],
      userTokens: [TokenDto()],
    );
    TokenDto? selectedToken;

    when(() => cubit.state).thenReturn(const TokenSelectorModalState.success(tokenList));

    await tester.pumpDeviceBuilder(
        await goldenBuilder(
          onSelectToken: (token) {
            return selectedToken = token;
          },
        ),
        wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("popular-token-0")));
    await tester.pumpAndSettle();

    expect(selectedToken.hashCode, tokenList.popularTokens.first.hashCode);
  });
}
