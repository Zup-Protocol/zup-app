import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_price_dto.freezed.dart';
part 'token_price_dto.g.dart';

@freezed
class TokenPriceDto with _$TokenPriceDto {
  @JsonSerializable(explicitToJson: true)
  factory TokenPriceDto({
    @Default(0) num usdPrice,
    @Default("") String address,
  }) = _TokenPriceDto;

  factory TokenPriceDto.fromJson(Map<String, dynamic> json) => _$TokenPriceDtoFromJson(json);

  factory TokenPriceDto.fixture() => TokenPriceDto(usdPrice: 1328.112);
}
