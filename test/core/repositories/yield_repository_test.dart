import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';

import '../../mocks.dart';

void main() {
  late Dio dio;
  late YieldRepository sut;

  setUp(() {
    dio = DioMock();
    sut = YieldRepository(dio);
  });

  test("When calling `getYields` it should call the correct endpoint with the correct params", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = Networks.sepolia;
    const minTvlUsd = 1213;

    await sut.getYields(
      token0Address: token0Address,
      token1Address: token1Address,
      network: network,
      minTvlUsd: minTvlUsd,
    );

    verify(() => dio.get("/pools", queryParameters: {
          "token0": token0Address,
          "token1": token1Address,
          "network": network.name,
          "minTvlUsd": minTvlUsd
        })).called(1);
  });

  test("When calling `getYields` it should correctly parse the response", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.get(any(), queryParameters: any(named: "queryParameters"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = Networks.sepolia;

    final response = await sut.getYields(
      token0Address: token0Address,
      token1Address: token1Address,
      network: network,
      minTvlUsd: 0,
    );

    expect(response, yields);
  });
}
