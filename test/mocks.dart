import 'dart:typed_data';

import 'package:confetti/confetti.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/aerodrome_v3_pool.abi.g.dart';
import 'package:zup_app/abis/aerodrome_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/algebra/v1.2.1/pool.abi.g.dart' as algebra_1_2_1_pool;
import 'package:zup_app/abis/algebra/v1.2.1/position_manager.abi.g.dart' as algebra_1_2_1_position_manager;
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/pancake_swap_infinity_cl_pool_manager.abi.g.dart';
import 'package:zup_app/abis/pancake_swap_infinity_cl_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_permit2.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_state_view.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';
import 'package:zup_app/core/repositories/protocol_repository.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

class $AssetsLottiesGenMock extends Mock implements $AssetsLottiesGen {}

class AppCubitMock extends Mock implements AppCubit {}

class BuildContextMock extends Mock implements BuildContext {}

class CacheMock extends Mock implements Cache {}

class DebouncerMock extends Mock implements Debouncer {}

class DepositCubitMock extends Mock implements DepositCubit {}

class Erc20ImplMock extends Mock implements Erc20Impl {}

class Erc20Mock extends Mock implements Erc20 {}

class ImageProviderMock extends Mock implements ImageProvider {}

class ListenableMock extends Mock implements Listenable {}

class PositionsRepositoryMock extends Mock implements PositionsRepository {}

class SharedPreferencesWithCacheMock extends Mock implements SharedPreferencesWithCache {}

class SignerMock extends Mock implements Signer {}

class TokenSelectorModalCubitMock extends Mock implements TokenSelectorModalCubit {}

class TokensRepositoryMock extends Mock implements TokensRepository {}

class TransactionResponseMock extends Mock implements TransactionResponse {}

class UniswapV3PositionManagerImplMock extends Mock implements UniswapV3PositionManagerImpl {}

class EthereumAbiCoderMock extends Mock implements EthereumAbiCoder {}

class UniswapV3PositionManagerMock extends Mock implements UniswapV3PositionManager {}

class PoolServiceMock extends Mock implements PoolService {}

class UniswapPermit2Mock extends Mock implements UniswapPermit2 {}

class UniswapPermit2ImplMock extends Mock implements UniswapPermit2Impl {}

class UniswapV4StateViewMock extends Mock implements UniswapV4StateView {}

class UniswapV4StateViewImplMock extends Mock implements UniswapV4StateViewImpl {}

class UniswapV4PositionManagerMock extends Mock implements UniswapV4PositionManager {}

class UniswapV4PositionManagerImplMock extends Mock implements UniswapV4PositionManagerImpl {}

class PancakeSwapInfinityCLPoolManagerMock extends Mock implements PancakeSwapInfinityClPoolManager {}

class PancakeSwapInfinityCLPoolManagerImplMock extends Mock implements PancakeSwapInfinityClPoolManagerImpl {}

class PancakeSwapInfinityCLPositionManagerMock extends Mock implements PancakeSwapInfinityClPositionManager {}

class PancakeSwapInfinityCLPositionManagerImplMock extends Mock implements PancakeSwapInfinityClPositionManagerImpl {}

class UniswapV3PoolImplMock extends Mock implements UniswapV3PoolImpl {}

class Algebra121PositionManagerMock extends Mock implements algebra_1_2_1_position_manager.PositionManager {}

class Algebra121PositionManagerImplMock extends Mock implements algebra_1_2_1_position_manager.PositionManagerImpl {}

class Algebra121PoolMock extends Mock implements algebra_1_2_1_pool.Pool {}

class Algebra121PoolImplMock extends Mock implements algebra_1_2_1_pool.PoolImpl {}

class UniswapV3PoolMock extends Mock implements UniswapV3Pool {}

class WalletMock extends Mock implements Wallet {}

class YieldRepositoryMock extends Mock implements YieldRepository {}

class ZupCachedImageMock extends Mock implements ZupCachedImage {}

class ZupNavigatorMock extends Mock implements ZupNavigator {}

class ZupSingletonCacheMock extends Mock implements ZupSingletonCache {}

class PreviewDepositModalCubitMock extends Mock implements PreviewDepositModalCubit {}

class ZupLinksMock extends Mock implements ZupLinks {}

class DioMock extends Mock implements Dio {}

class ConfettiControllerMock extends Mock implements ConfettiController {}

class FirebaseAnalyticsMock extends Mock implements FirebaseAnalytics {}

class ZupHolderMock extends Mock implements ZupHolder {}

class ProtocolRepositoryMock extends Mock implements ProtocolRepository {}

class AerodromeV3PositionManagerMock extends Mock implements AerodromeV3PositionManager {}

class AerodromeV3PoolMock extends Mock implements AerodromeV3Pool {}

class AerodromeV3PoolImplMock extends Mock implements AerodromeV3PoolImpl {}

class AerodromeV3PositionManagerImplMock extends Mock implements AerodromeV3PositionManagerImpl {}

class ChangeNotifierMock extends Mock with ChangeNotifier {
  void notify() => notifyListeners();
}

class ZupAnalyticsMock extends Mock implements ZupAnalytics {}

class UrlLauncherPlatformCustomMock extends UrlLauncherPlatform {
  static String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    lastLaunchedUrl = url;

    return true;
  }
}

class ImageStreamCompleterMock extends Mock implements ImageStreamCompleter {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class ImageStreamMock extends Mock implements ImageStream {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

T mockHttpImage<T>(T Function() on, {Uint8List? overrideImage}) {
  return mockNetworkImages(on, imageBytes: overrideImage);
}

ZupCachedImage mockZupCachedImage() {
  final zupCachedImage = ZupCachedImageMock();
  final context = BuildContextMock();
  registerFallbackValue(context);

  when(
    () => zupCachedImage.build(
      any(),
      any(),
      height: any(named: "height"),
      width: any(named: "width"),
      radius: any(named: "radius"),
      errorWidget: any(named: "errorWidget"),
      placeholder: any(named: "placeholder"),
      backgroundColor: any(named: "backgroundColor"),
    ),
  ).thenReturn(const SizedBox(child: Text("IMAGE")));

  return zupCachedImage;
}
