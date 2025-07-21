import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';

import '../../mocks.dart';

void main() {
  late Dio zupApiDio;
  late ProtocolRepository sut;

  setUp(() {
    zupApiDio = DioMock();
    sut = ProtocolRepository(zupApiDio: zupApiDio);
  });

  test("When calling `getAllSupportedProtocols` it should call the correct endpoint", () async {
    when(() => zupApiDio.get(any())).thenAnswer(
      (_) async => Response(
        data: [ProtocolDto.fixture().toJson()],
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    await sut.getAllSupportedProtocols();

    verify(() => zupApiDio.get("/protocols")).called(1);
  });

  test("When calling `getAllSupportedProtocols` it should return a list of protocols", () async {
    final protocols = [
      ProtocolDto.fixture().copyWith(rawId: "1", name: "LULU", logo: "LALA.png", url: "LALA.com"),
      ProtocolDto.fixture().copyWith(rawId: "2", name: "LALA", logo: "LULU.png", url: "LULU.com"),
    ];

    when(() => zupApiDio.get(any())).thenAnswer(
      (_) async => Response(
        data: protocols.map((protocol) => protocol.toJson()..["id"] = protocol.rawId.toString()).toList(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    final result = await sut.getAllSupportedProtocols();

    expect(result, protocols);
  });
}
