import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';

part 'positions_cubit.freezed.dart';
part 'positions_state.dart';

class PositionsCubit extends Cubit<PositionsState> {
  PositionsCubit(this._wallet, this._repository, this._appCubit, this._cache) : super(const PositionsState.initial()) {
    _setup();
  }

  final Wallet _wallet;
  final PositionsRepository _repository;
  final AppCubit _appCubit;
  final Cache _cache;

  bool _hidingClosedPositions = false;

  List<PositionDto>? _positionsCache;
  StreamSubscription<Signer?>? _signerStream;
  StreamSubscription<Networks>? _networkStream;

  bool get hidingClosedPositions => _hidingClosedPositions;
  List<PositionDto>? get positions => _positionsCache;

  Future<void> _setup() async {
    _wallet.signer == null ? emit(const PositionsState.notConnected()) : getUserPositions();
    _hidingClosedPositions = await _cache.getHidingClosedPositionsStatus();

    _setupStreams();
  }

  void _setupStreams() {
    _signerStream = _wallet.signerStream.listen((signer) {
      if (signer != null) return getUserPositions();

      _clear();
      emit(const PositionsState.notConnected());
    });

    _networkStream = _appCubit.selectedNetworkStream.listen((network) {
      if (_wallet.signer != null) filterUserPositions();
    });
  }

  void _clear() => _positionsCache = null;

  Future<void> _saveFiltersToCache() async {
    await _cache.saveHidingClosedPositionsStatus(status: _hidingClosedPositions);
  }

  void filterUserPositions({bool? hideClosedPositions}) async {
    emit(const PositionsState.loading());

    if (hideClosedPositions != null) _hidingClosedPositions = hideClosedPositions;
    _saveFiltersToCache();

    final List<PositionDto> positionsClone = List.from(_positionsCache ?? []);

    if (positionsClone.isEmpty) return emit(const PositionsState.noPositions());

    if (_hidingClosedPositions) {
      positionsClone.removeWhere((position) => position.status.isClosed);

      if (positionsClone.isEmpty) return emit(const PositionsState.noPositions());
    }

    if (!_appCubit.selectedNetwork.isAll) {
      positionsClone.removeWhere((position) => position.network != _appCubit.selectedNetwork);

      if (positionsClone.isEmpty) return emit(const PositionsState.noPositionsInNetwork());
    }

    emit(PositionsState.positions(positionsClone));
  }

  void getUserPositions() async {
    try {
      emit(const PositionsState.loading());
      _positionsCache = await _repository.fetchUserPositions();

      filterUserPositions();
    } catch (e) {
      emit(const PositionsState.error());
    }
  }

  @override
  Future<void> close() {
    _signerStream?.cancel();
    _networkStream?.cancel();
    return super.close();
  }
}
