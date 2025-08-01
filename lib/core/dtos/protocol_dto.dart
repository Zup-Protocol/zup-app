import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/enums/protocol_id.dart';

part 'protocol_dto.freezed.dart';
part 'protocol_dto.g.dart';

String _readRawProtocolId(Map map, String key) => map['id'];

@freezed
sealed class ProtocolDto with _$ProtocolDto {
  const ProtocolDto._();

  @JsonSerializable(explicitToJson: true)
  const factory ProtocolDto({
    @Default("") @JsonKey(readValue: _readRawProtocolId) String rawId,
    @Default(ProtocolId.unknown) @JsonKey(unknownEnumValue: ProtocolId.unknown) ProtocolId id,
    @Default("") String name,
    @Default("") String url,
    @Default("") String logo,
  }) = _ProtocolDto;

  factory ProtocolDto.fromJson(Map<String, dynamic> json) => _$ProtocolDtoFromJson(json);

  factory ProtocolDto.fixture() => const ProtocolDto(
        rawId: "1",
        id: ProtocolId.unknown,
        name: "Uniswap",
        url: "https://app.uniswap.org/pool",
        logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
      );
}
