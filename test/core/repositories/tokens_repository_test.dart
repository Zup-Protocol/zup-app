import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
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

  test("When calling `getTokenList` it should call the correct endpoint", () async {
    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: TokenListDto.fixture().toJson(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.getTokenList(Networks.sepolia);

    verify(() => dio.get(
          "/tokens",
          queryParameters: {
            "network": Networks.sepolia.name,
          },
        ));
  });

  test("When calling `getTokenList` it should correctly parse the response", () async {
    final tokens = TokenListDto.fixture();

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: tokens.toJson(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final response = await sut.getTokenList(Networks.sepolia);

    expect(response, tokens);
  });

  test("When calling `searchToken` it should call the correct endpoint", () async {
    const query = "dale";
    const network = Networks.sepolia;

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
            "network": network.name,
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

    final response = await sut.searchToken("query", Networks.sepolia);

    expect(response, tokens);
  });
}
