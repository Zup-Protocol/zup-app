import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/enums/app_theme_mode.dart';

part 'theme_mode_dto.freezed.dart';
part 'theme_mode_dto.g.dart';

@freezed
sealed class ThemeModeDto with _$ThemeModeDto {
  const ThemeModeDto._();

  @JsonSerializable(explicitToJson: true)
  factory ThemeModeDto({
    @Default(AppThemeMode.system)
    @JsonKey(name: 'theme_mode', unknownEnumValue: AppThemeMode.system)
    AppThemeMode themeMode,
  }) = _ThemeModeDto;

  factory ThemeModeDto.fromJson(Map<String, dynamic> json) => _$ThemeModeDtoFromJson(json);
}
