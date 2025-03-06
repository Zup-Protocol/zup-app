import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/core.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this._wallet) : super(const AppState.standard()) {
    _setupStreams();
  }

  final Wallet _wallet;

  Networks _selectedNetwork = Networks.sepolia;
  final StreamController<Networks> _selectedNetworkStreamController = StreamController<Networks>.broadcast();

  Stream<Networks> get selectedNetworkStream => _selectedNetworkStreamController.stream;

  Networks get selectedNetwork => _selectedNetwork;

  void _setupStreams() {
    _wallet.signerStream.listen((signer) async {
      if (signer != null) _trySwitchNetwork();
    });
  }

  void _trySwitchNetwork() async {
    if (selectedNetwork.chainInfo != null) {
      final walletNetwork = await _wallet.connectedNetwork;

      if (walletNetwork.hexChainId != _selectedNetwork.chainInfo!.hexChainId) {
        _wallet.switchOrAddNetwork(_selectedNetwork.chainInfo!);
      }
    }
  }

  void updateAppNetwork(Networks newNetwork) async {
    if (newNetwork == _selectedNetwork) return;

    emit(AppState.networkChanged(newNetwork));

    _selectedNetwork = newNetwork;
    _selectedNetworkStreamController.add(_selectedNetwork);

    emit(const AppState.standard());
  }
}
