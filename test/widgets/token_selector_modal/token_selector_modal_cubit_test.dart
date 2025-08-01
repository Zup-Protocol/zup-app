import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';

import '../../mocks.dart';

void main() {
  late TokenSelectorModalCubit sut;
  late TokensRepository tokensRepository;
  late AppCubit appCubit;
  late Wallet wallet;

  setUp(() {
    appCubit = AppCubitMock();
    tokensRepository = TokensRepositoryMock();
    wallet = WalletMock();
    registerFallbackValue(AppNetworks.sepolia);

    sut = TokenSelectorModalCubit(tokensRepository, appCubit, wallet);

    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
    when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => TokenListDto.fixture());
    when(() => tokensRepository.searchToken(any(), any())).thenAnswer((_) async => []);
  });

  test(
    "Whe calling `fetchTokenList` and it has already been called in the same network, it should return the cached token list",
    () async {
      final tokenList = TokenListDto.fixture();

      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList);

      expectLater(
        sut.stream,
        emitsInOrder([
          const TokenSelectorModalState.loading(),
          TokenSelectorModalState.success(tokenList),
          const TokenSelectorModalState.searchLoading(),
          const TokenSelectorModalState.searchNotFound(""),

          // expected to emit the cached token list
          TokenSelectorModalState.success(tokenList),
        ]),
      );

      await sut.fetchTokenList();

      // update the state to make it emit the cached token list again
      await sut.searchToken("");

      await sut.fetchTokenList();

      verify(() => tokensRepository.getTokenList(any())).called(1);
    },
  );

  test(
    "When calling `fetchTokenList` and it has not already been called yet in the current network, it should get the tokens list again",
    () async {
      final tokenList1 = TokenListDto.fixture();
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList1);
      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);

      await sut.fetchTokenList();

      final tokenList2 = TokenListDto.fixture();
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList2);
      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.mainnet);

      await sut.fetchTokenList();

      expect((await sut.tokenList).hashCode, tokenList2.hashCode);
      verify(() => tokensRepository.getTokenList(any())).called(2);
    },
  );

  test(
    "When calling `fetchTokenList` switching networks, and the current network has already been called, it should return the cached list ",
    () async {
      final tokenList1 = TokenListDto.fixture();
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList1);
      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);

      await sut.fetchTokenList();

      final tokenList2 = TokenListDto.fixture();
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList2);
      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.mainnet);

      await sut.fetchTokenList();

      when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
      when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList1);
      await sut.fetchTokenList();

      expect((await sut.tokenList).hashCode, tokenList1.hashCode);
      verify(() => tokensRepository.getTokenList(any())).called(2);
    },
  );

  test(
    """When calling `fetchTokenList` and right after calling 
  another function that will change the state before the
  future to get the list of tokens completes, it should
  not emit the state of loaded, but should update the
  cached list""",
    () async {
      const requestDuration = Duration(milliseconds: 1);
      final tokenList = TokenListDto.fixture();

      when(
        () => tokensRepository.getTokenList(any()),
      ).thenAnswer((_) async => Future.delayed(requestDuration, () => tokenList));

      expectLater(sut.stream, neverEmits(TokenSelectorModalState.success(tokenList)));

      sut.fetchTokenList();
      await Future.delayed(Duration.zero);
      await sut.searchToken(""); // update the state before the future completes

      await Future.delayed(requestDuration);

      sut.close(); // should not emit a new state, so we close it to make the test fail if it does
    },
  );

  test(
    """When calling `fetchTokenList` and right after calling 
  another function that will change the state before the
  future to get the list of tokens completes, it should
  not emit the List loaded state, and if it completes with
  error, it should not update the cached list or emit error state""",
    () async {
      const requestDuration = Duration(milliseconds: 1);

      when(
        () => tokensRepository.getTokenList(any()),
      ).thenAnswer((_) => Future.delayed(requestDuration, () => throw "dale"));

      sut.fetchTokenList();
      await sut.searchToken(""); // update the state before the future completes

      await Future.delayed(requestDuration);

      expect(sut.state != const TokenSelectorModalState.error(), true);
    },
  );

  test("when calling load data, and the repository throws an error, it should emit an error state", () async {
    when(() => tokensRepository.getTokenList(any())).thenThrow("dale");

    await sut.fetchTokenList();

    expect(sut.state, const TokenSelectorModalState.error());
  });

  test("when calling load data, and the repository returns success, it should emit the success state", () async {
    final tokenList = TokenListDto.fixture();

    when(() => tokensRepository.getTokenList(any())).thenAnswer((_) async => tokenList);

    await sut.fetchTokenList();

    expect(sut.state, TokenSelectorModalState.success(tokenList));
  });

  test("When calling `searchToken`  it should call the repository with the passed query", () async {
    const query = "dale";

    when(() => tokensRepository.searchToken(query, any())).thenAnswer((_) async => []);

    await sut.searchToken(query);

    verify(() => tokensRepository.searchToken(query, any())).called(1);
  });

  test(
    """When calling `searchTokens` and right after call another function
  that changes the state before the future to get the search results completes
  it should not emit the searchSuccess state when it completes""",
    () async {
      const requestDuration = Duration(milliseconds: 1);
      final futureResult = <TokenDto>[];

      when(
        () => tokensRepository.searchToken(any(), any()),
      ).thenAnswer((_) => Future.delayed(requestDuration, () => futureResult));

      expectLater(sut.stream, neverEmits(TokenSelectorModalState.searchSuccess(futureResult)));
      sut.searchToken("dale");
      await sut.fetchTokenList();

      await Future.delayed(requestDuration);

      sut.close();
    },
  );

  test(
    """When calling `searchTokens` and right after call another function
  that changes the state before the future to get the search results completes
  it should not emit the searchError state when it completes with an error""",
    () async {
      const requestDuration = Duration(milliseconds: 1);
      const searchQuery = "dale";

      when(
        () => tokensRepository.searchToken(any(), any()),
      ).thenAnswer((_) => Future.delayed(requestDuration, () => throw "error"));

      expectLater(sut.stream, neverEmits(const TokenSelectorModalState.searchError(searchQuery)));
      sut.searchToken(searchQuery);
      await sut.fetchTokenList();

      await Future.delayed(requestDuration);

      sut.close();
    },
  );

  test(
    "When calling `searchTokens` and the repository returns success it should emit the searchSuccess state",
    () async {
      final searchResult = [TokenDto.fixture(), TokenDto.fixture()];
      when(() => tokensRepository.searchToken(any(), any())).thenAnswer((_) async => searchResult);

      await sut.searchToken("dale");

      expect(sut.state, TokenSelectorModalState.searchSuccess(searchResult));
    },
  );

  test(
    "When calling `searchTokens` and the repository throw an generic error, it should emit the searchError state",
    () async {
      const searchQuery = "dale";

      when(() => tokensRepository.searchToken(any(), any())).thenThrow("some error");

      await sut.searchToken(searchQuery);

      expect(sut.state, const TokenSelectorModalState.searchError(searchQuery));
    },
  );

  test(
    "When calling `searchTokens` and the repository returns a empty list, it should emit the search not found state",
    () async {
      const searchQuery = "dale";

      when(() => tokensRepository.searchToken(any(), any())).thenAnswer((_) async => []);

      await sut.searchToken(searchQuery);

      expect(sut.state, const TokenSelectorModalState.searchNotFound(searchQuery));
    },
  );

  test(
    """When calling `searchTokens` and the repository throw an error,
  but the error is because the dio request have been canceled, it should keep
  the state as the last one""",
    () async {
      const searchQuery = "dale";

      when(() => tokensRepository.searchToken(any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ""),
          type: DioExceptionType.cancel,
        ),
      );

      expectLater(sut.stream, neverEmits(const TokenSelectorModalState.searchError(searchQuery)));
      await sut.searchToken(searchQuery);

      expect(sut.state, const TokenSelectorModalState.searchLoading());
      await sut.close();
    },
  );

  test(
    "When calling `fetchTokenList` with 'forceRefresh' true, it should refetch the token list ignoring the cache",
    () async {
      await sut.fetchTokenList(forceRefresh: true);
      await sut.fetchTokenList(forceRefresh: true);
      await sut.fetchTokenList(forceRefresh: true);

      verify(() => tokensRepository.getTokenList(any())).called(3);
    },
  );

  test(
    "When callling 'searchToken' with a valid ethereum address, and the network is all networks, it should emit the search not found state",
    () async {
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      const address = "0x0000000000000000000000000000000000000000";
      await sut.searchToken(address);

      expect(sut.state, const TokenSelectorModalState.searchNotFound(address));
      verifyNever(() => tokensRepository.searchToken(any(), any()));
    },
  );

  test(
    """When calling 'searchToken' and all the tokens in the list returned does not have name and symbol,
  it should emit the search not found state""",
    () async {
      final returnedList = [
        TokenDto.fixture().copyWith(name: "", symbol: "", logoUrl: "", addresses: {}),
        TokenDto.fixture().copyWith(name: "", symbol: "", decimals: {}, logoUrl: "", addresses: {}),
      ];

      when(() => tokensRepository.searchToken(any(), any())).thenAnswer((_) async => returnedList);

      await sut.searchToken("dale");

      expect(sut.state, const TokenSelectorModalState.searchNotFound("dale"));
    },
  );

  test(
    """When calling 'searchToken' and one token in the list returned has symbol and name,
  it should emit the search sucesss state, without the tokens without name and symbol""",
    () async {
      final namedToken = TokenDto.fixture();
      final returnedList = [
        TokenDto.fixture().copyWith(name: "", symbol: "", logoUrl: "", addresses: {}),
        TokenDto.fixture().copyWith(name: "", symbol: "", logoUrl: "", addresses: {}),
        namedToken,
      ];

      when(() => tokensRepository.searchToken(any(), any())).thenAnswer((_) async => returnedList);

      await sut.searchToken("dale");

      expect(sut.state, TokenSelectorModalState.searchSuccess([namedToken]));
    },
  );
}
