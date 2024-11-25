import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  setUp(() {
    appCubit = AppCubitMock();
    tokensRepository = TokensRepositoryMock();

    sut = TokenSelectorModalCubit(tokensRepository, appCubit);

    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => TokenListDto.fixture());
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);
    when(() => tokensRepository.searchToken(any())).thenAnswer((_) async => []);
  });

  test(
      "Whe calling `loadData` and it has already been called in the same network, it should return the cached token list",
      () async {
    final tokenList = TokenListDto.fixture().copyWith(mostUsedTokens: []);

    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList);

    expectLater(
        sut.stream,
        emitsInOrder([
          const TokenSelectorModalState.loading(),
          TokenSelectorModalState.success(tokenList),
          const TokenSelectorModalState.searchLoading(),
          const TokenSelectorModalState.searchSuccess([]),

          // expected to emit the cached token list
          TokenSelectorModalState.success(tokenList),
        ]));

    await sut.loadData();

    // update the state to make it emit the cached token list again
    await sut.searchToken("");

    await sut.loadData();

    verify(() => tokensRepository.getTokenList()).called(1);
  });

  test(
      "When calling `loadData` and it has not already been called yet in the current network, it should get the tokens list again",
      () async {
    final tokenList1 = TokenListDto.fixture();
    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList1);
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);

    await sut.loadData();

    const tokenList2 = TokenListDto();
    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList2);
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.scrollSepolia);

    await sut.loadData();

    expect(sut.tokenList.hashCode, tokenList2.hashCode);
    verify(() => tokensRepository.getTokenList()).called(2);
  });

  test(
      "When calling `loadData` switching networks, and the current network has already been called, it should return the cached list ",
      () async {
    final tokenList1 = TokenListDto.fixture();
    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList1);
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);

    await sut.loadData();

    const tokenList2 = TokenListDto();
    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList2);
    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.scrollSepolia);

    await sut.loadData();

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);
    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList1);
    await sut.loadData();

    expect(sut.tokenList.hashCode, tokenList1.hashCode);
    verify(() => tokensRepository.getTokenList()).called(2);
  });

  test("""When calling `loadData` and right after calling 
  another function that will change the state before the
  future to get the list of tokens completes, it should
  not emit the state of loaded, but should update the
  cached list""", () async {
    const requestDuration = Duration(milliseconds: 1);
    final tokenList = TokenListDto.fixture();

    when(() => tokensRepository.getTokenList()).thenAnswer(
      (_) async => Future.delayed(requestDuration, () => tokenList),
    );

    expectLater(sut.stream, neverEmits(TokenSelectorModalState.success(tokenList)));

    sut.loadData();
    await sut.searchToken(""); // update the state before the future completes

    await Future.delayed(requestDuration);

    sut.close();
  });

  test("""When calling `loadData` and right after calling 
  another function that will change the state before the
  future to get the list of tokens completes, it should
  not emit the List loaded state, and if it completes with
  error, it should not update the cached list or emit error state""", () async {
    const requestDuration = Duration(milliseconds: 1);

    when(() => tokensRepository.getTokenList()).thenAnswer((_) => Future.delayed(requestDuration, () => throw "dale"));

    sut.loadData();
    await sut.searchToken(""); // update the state before the future completes

    await Future.delayed(requestDuration);

    expect(sut.state != const TokenSelectorModalState.error(), true);
  });

  test("when calling load data, and the repository throws an error, it should emit an error state", () async {
    when(() => tokensRepository.getTokenList()).thenThrow("dale");

    await sut.loadData();

    expect(sut.state, const TokenSelectorModalState.error());
  });

  test("when calling load data, and the repository returns success, it should emit the success state", () async {
    final tokenList = TokenListDto.fixture();

    when(() => tokensRepository.getTokenList()).thenAnswer((_) async => tokenList);

    await sut.loadData();

    expect(sut.state, TokenSelectorModalState.success(tokenList));
  });

  test("When calling `searchToken`  it should call the repository with the passed query", () async {
    const query = "dale";

    when(() => tokensRepository.searchToken(query)).thenAnswer((_) async => []);

    await sut.searchToken(query);

    verify(() => tokensRepository.searchToken(query)).called(1);
  });

  test("""When calling `searchTokens` and right after call another function
  that changes the state before the future to get the search results completes
  it should not emit the searchSuccess state when it completes""", () async {
    const requestDuration = Duration(milliseconds: 1);
    final futureResult = <TokenDto>[];

    when(() => tokensRepository.searchToken(any())).thenAnswer(
      (_) => Future.delayed(requestDuration, () => futureResult),
    );

    expectLater(sut.stream, neverEmits(TokenSelectorModalState.searchSuccess(futureResult)));
    sut.searchToken("dale");
    await sut.loadData();

    await Future.delayed(requestDuration);

    sut.close();
  });

  test("""When calling `searchTokens` and right after call another function
  that changes the state before the future to get the search results completes
  it should not emit the searchError state when it completes with an error""", () async {
    const requestDuration = Duration(milliseconds: 1);
    const searchQuery = "dale";

    when(() => tokensRepository.searchToken(any()))
        .thenAnswer((_) => Future.delayed(requestDuration, () => throw "error"));

    expectLater(sut.stream, neverEmits(const TokenSelectorModalState.searchError(searchQuery)));
    sut.searchToken(searchQuery);
    await sut.loadData();

    await Future.delayed(requestDuration);

    sut.close();
  });

  test("When calling `searchTokens` and the repository returns success it should emit the searchSuccess state",
      () async {
    final searchResult = [TokenDto.fixture(), TokenDto.fixture()];
    when(() => tokensRepository.searchToken(any())).thenAnswer((_) async => searchResult);

    await sut.searchToken("dale");

    expect(sut.state, TokenSelectorModalState.searchSuccess(searchResult));
  });

  test(
      "When calling `searchTokens` and the repository throw an error with 404, it should emit the searchNotFound state",
      () async {
    const searchQuery = "dale";

    when(() => tokensRepository.searchToken(any())).thenThrow(DioException(
      response: Response(statusCode: 404, requestOptions: RequestOptions(path: "")),
      requestOptions: RequestOptions(path: ""),
    ));

    await sut.searchToken(searchQuery);

    expect(sut.state, const TokenSelectorModalState.searchNotFound(searchQuery));
  });

  test("When calling `searchTokens` and the repository throw an generic error, it should emit the searchError state",
      () async {
    const searchQuery = "dale";

    when(() => tokensRepository.searchToken(any())).thenThrow("some error");

    await sut.searchToken(searchQuery);

    expect(sut.state, const TokenSelectorModalState.searchError(searchQuery));
  });
}
