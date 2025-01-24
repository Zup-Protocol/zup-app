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
    @Default("") String logo,
    @Default("") String positionManager,
  }) = _ProtocolDto;

  factory ProtocolDto.fromJson(Map<String, dynamic> json) => _$ProtocolDtoFromJson(json);

  factory ProtocolDto.fixture() => const ProtocolDto(
        name: "Uniswap",
        url: "https://app.uniswap.org/pool",
        logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/app.uniswap.org.png",
        positionManager: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
      );
}
