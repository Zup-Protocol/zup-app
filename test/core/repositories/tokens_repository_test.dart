import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_price_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';

import '../../mocks.dart';

void main() {
  late TokensRepository sut;
  late Dio dio;

  setUp(() {
    dio = DioMock();
    sut = TokensRepository(dio);
  });

  test("When calling `searchToken` it should call the correct endpoint", () async {
    const query = "dale";
    const network = AppNetworks.sepolia;

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"), cancelToken: any(named: "cancelToken")))
        .thenAnswer(
      (_) async => Response(
        data: [TokenDto.fixture().toJson()],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.searchToken(query, network);

    verify(() => dio.get(
          "/tokens/search",
          cancelToken: any(named: "cancelToken"),
          queryParameters: {
            "chainId": network.chainId,
            "query": query,
          },
        ));
  });

  test("When calling 'searchToken' and the network is all networks, it should not pass the chainId param", () async {
    const query = "dale";

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"), cancelToken: any(named: "cancelToken")))
        .thenAnswer(
      (_) async => Response(
        data: [TokenDto.fixture().toJson()],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.searchToken(query, AppNetworks.allNetworks);

    verify(() => dio.get(
          "/tokens/search",
          cancelToken: any(named: "cancelToken"),
          queryParameters: {
            "query": query,
          },
        ));
  });

  test("When calling `searchToken` it should correctly parse the response", () async {
    final tokens = [
      TokenDto.fixture(),
      TokenDto.fixture(),
      TokenDto.fixture(),
    ];

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"), cancelToken: any(named: "cancelToken")))
        .thenAnswer(
      (_) async => Response(
        data: [
          TokenDto.fixture().toJson(),
          TokenDto.fixture().toJson(),
          TokenDto.fixture().toJson(),
        ],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final response = await sut.searchToken("query", AppNetworks.sepolia);

    expect(response, tokens);
  });

  test("When calling `getPopularTokens` and the passed network is all networks, it should not pass the chainId param",
      () async {
    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: [TokenDto.fixture().toJson()],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.getPopularTokens(AppNetworks.allNetworks);

    verify(() => dio.get("/tokens/popular", queryParameters: {})).called(1);
  });

  test(
      "When calling `getPopularTokens` and the passed network is not all networks, it should not the correct chainId param",
      () async {
    const network = AppNetworks.scroll;

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: [TokenDto.fixture().toJson()],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.getPopularTokens(AppNetworks.scroll);

    verify(() => dio.get("/tokens/popular", queryParameters: {
          "chainId": network.chainId,
        })).called(1);
  });

  test("When calling `getTokenPrice` it should call the correct endpoint with correct params", () async {
    const address = "0x123";
    const network = AppNetworks.sepolia;

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: TokenPriceDto.fixture().toJson(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.getTokenPrice(address, network);

    verify(() => dio.get(
          "/tokens/price",
          queryParameters: {
            "address": address,
            "chainId": network.chainId,
          },
        )).called(1);
  });

  test("When calling `getTokenPrice` it should correctly parse the response", () async {
    const address = "0x123";
    const network = AppNetworks.sepolia;
    final tokenPriceDto = TokenPriceDto.fixture();

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: tokenPriceDto.toJson(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final response = await sut.getTokenPrice(address, network);

    expect(response, tokenPriceDto);
  });
}
