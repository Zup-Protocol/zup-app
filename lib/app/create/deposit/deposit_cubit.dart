import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_core/zup_core.dart';

part 'deposit_cubit.freezed.dart';
part 'deposit_state.dart';

class DepositCubit extends Cubit<DepositState> with KeysMixin {
  DepositCubit(
    this._yieldRepository,
    this._zupSingletonCache,
    this._wallet,
    this._uniswapV3Pool,
  ) : super(const DepositState.initial());

  final YieldRepository _yieldRepository;
  final ZupSingletonCache _zupSingletonCache;
  final Wallet _wallet;
  final UniswapV3Pool _uniswapV3Pool;

  Future<void> getBestPools({required String token0Address, required String token1Address}) async {
    try {
      emit(const DepositState.loading());
      final yields = await _yieldRepository.getYields(token0Address: token0Address, token1Address: token1Address);

      if (yields.isEmpty) return emit(const DepositState.noYields());

      emit(DepositState.success(yields));
    } catch (e) {
      emit(const DepositState.error());
    }
  }

  Future<double> getWalletTokenAmount(String tokenAddress, {required Networks network}) async {
    if (_wallet.signer == null) return 0.0;

    final walletAddress = await _wallet.signer!.address;

    return await _zupSingletonCache.run(
      () async {
        try {
          return await _wallet.tokenBalance(tokenAddress, rpcUrl: network.rpcUrl);
        } catch (_) {
          return 0.0;
        }
      },
      key: userTokenBalanceCacheKey(
        tokenAddress: tokenAddress,
        userAddress: walletAddress,
      ),
      expiration: const Duration(minutes: 10),
    );
  }

  Future<BigInt> getPoolTick(Networks poolNetwork, String poolAddress) async {
    return await _zupSingletonCache.run(
      () async {
        try {
          final pool = _uniswapV3Pool.fromRpcProvider(contractAddress: poolAddress, rpcUrl: poolNetwork.rpcUrl ?? "");
          final slot0 = await pool.slot0();

          return slot0.tick;
        } catch (_) {
          return BigInt.zero;
        }
      },
      key: poolTickCacheKey(network: poolNetwork, poolAddress: poolAddress),
      expiration: const Duration(minutes: 1),
    );
  }
}
