import 'package:freezed_annotation/freezed_annotation.dart';

part 'protocol_dto.freezed.dart';
part 'protocol_dto.g.dart';

@freezed
class ProtocolDto with _$ProtocolDto {
  const ProtocolDto._();

  @JsonSerializable(explicitToJson: true)
  const factory ProtocolDto({
    @Default("") String name,
    @Default("") String url,
    @Default("") @JsonKey(name: 'logo_url') String logoUrl,
  }) = _ProtocolDto;

  factory ProtocolDto.fromJson(Map<String, dynamic> json) => _$ProtocolDtoFromJson(json);

  factory ProtocolDto.fixture() => const ProtocolDto(
        name: "Uniswap",
        url: "https://app.uniswap.org/pool",
        logoUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
      );
}
