import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/slippage.dart';

part 'deposit_settings_dto.freezed.dart';
part 'deposit_settings_dto.g.dart';

@freezed
class DepositSettingsDto with _$DepositSettingsDto {
  const DepositSettingsDto._();

  static const defaultMaxSlippage = 0.5;
  static const defaultDeadlineMinutes = 10;

  @JsonSerializable(explicitToJson: true)
  factory DepositSettingsDto({
    @Default(DepositSettingsDto.defaultMaxSlippage) @JsonKey(name: 'max_slippage') double maxSlippage,
    @Default(DepositSettingsDto.defaultDeadlineMinutes) @JsonKey(name: 'deadline_minutes') int deadlineMinutes,
  }) = _DepositSettingsDto;

  Slippage get slippage => Slippage.fromValue(maxSlippage);
  Duration get deadline => Duration(minutes: deadlineMinutes);

  factory DepositSettingsDto.fromJson(Map<String, dynamic> json) => _$DepositSettingsDtoFromJson(json);

  factory DepositSettingsDto.fixture() => DepositSettingsDto(
        maxSlippage: 122,
        deadlineMinutes: 40,
      );
}
