import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';

class ProtocolRepository {
  ProtocolRepository({required this.zupApiDio});

  final Dio zupApiDio;

  Future<List<ProtocolDto>> getAllSupportedProtocols() async {
    final protocolsResponse = await zupApiDio.get("/protocols").onError((_, __) async {
      return await zupApiDio.get("/protocols");
    });

    return (protocolsResponse.data as List)
        .map<ProtocolDto>(
          (protocol) => ProtocolDto.fromJson(protocol),
        )
        .toList();
  }
}
