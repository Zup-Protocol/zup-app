import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_core/zup_core.dart';

part 'exchanges_filter_dropdown_button_cubit.freezed.dart';
part 'exchanges_filter_dropdown_button_state.dart';

class ExchangesFilterDropdownButtonCubit extends Cubit<ExchangesFilterDropdownButtonState> with KeysMixin {
  ExchangesFilterDropdownButtonCubit(this._protocolRepository, this._zupSingletonCache)
      : super(const ExchangesFilterDropdownButtonState.initial());

  final ProtocolRepository _protocolRepository;
  final ZupSingletonCache _zupSingletonCache;

  List<ProtocolDto> _supportedProtocols = [];
  List<ProtocolDto> get protocols => _supportedProtocols;

  Future<void> getSupportedProtocols() async {
    try {
      emit(const ExchangesFilterDropdownButtonState.loading());

      _supportedProtocols = await _zupSingletonCache.run(
        () async => await _protocolRepository.getAllSupportedProtocols(),
        key: protocolsListKey,
      );

      _supportedProtocols.sort((a, b) => a.name.compareTo(b.name));

      emit(ExchangesFilterDropdownButtonState.success(protocols));
    } catch (e) {
      emit(const ExchangesFilterDropdownButtonState.error());
    }
  }
}
