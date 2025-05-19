import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/core.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this._wallet, this._cache) : super(const AppState.standard()) {
    _setupStreams();
    _isTestnetMode = _cache.getTestnetMode();

    if (_isTestnetMode) {
      updateAppNetwork(AppNetworks.sepolia);
      emit(AppState.testnetModeChanged(_isTestnetMode));
    }
  }

  final Wallet _wallet;
  final Cache _cache;

  AppNetworks _selectedNetwork = AppNetworks.allNetworks;
  bool _isTestnetMode = false;

  final StreamController<AppNetworks> _selectedNetworkStreamController = StreamController<AppNetworks>.broadcast();

  Stream<AppNetworks> get selectedNetworkStream => _selectedNetworkStreamController.stream;

  AppNetworks get selectedNetwork => _selectedNetwork;
  int get currentChainId => _selectedNetwork.chainId;
  bool get isTestnetMode => _isTestnetMode;

  void _setupStreams() {
    _wallet.signerStream.listen((signer) async {
      if (signer != null) _trySwitchWalletNetwork();
    });
  }

  Future<void> _trySwitchWalletNetwork() async {
    final walletNetwork = await _wallet.connectedNetwork;

    if (walletNetwork.hexChainId != _selectedNetwork.chainInfo.hexChainId) {
      await _wallet.switchOrAddNetwork(_selectedNetwork.chainInfo);
    }
  }

  void updateAppNetwork(AppNetworks newNetwork) async {
    if (newNetwork == _selectedNetwork) return;

    emit(AppState.networkChanged(newNetwork));

    _selectedNetwork = newNetwork;
    _selectedNetworkStreamController.add(_selectedNetwork);

    emit(const AppState.standard());
  }

  Future<void> toggleTestnetMode() async {
    _isTestnetMode = !_isTestnetMode;
    updateAppNetwork(isTestnetMode ? AppNetworks.sepolia : AppNetworks.allNetworks);
    await _cache.saveTestnetMode(isTestnetMode: _isTestnetMode);

    try {
      if (_wallet.signer != null) await _trySwitchWalletNetwork();
    } catch (e) {
      // do nothing
    }

    emit(AppState.testnetModeChanged(_isTestnetMode));
  }
}
