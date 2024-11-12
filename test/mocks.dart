import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_singleton_cache.dart';

class AppCubitMock extends Mock implements AppCubit {}

class ZupNavigatorMock extends Mock implements ZupNavigator {}

class ListenableMock extends Mock implements Listenable {}

class WalletMock extends Mock implements Wallet {}

class SignerMock extends Mock implements Signer {}

class PositionsRepositoryMock extends Mock implements PositionsRepository {}

class CacheMock extends Mock implements Cache {}

class ImageProviderMock extends Mock implements ImageProvider {}

class ZupCachedImageMock extends Mock implements ZupCachedImage {}

class SharedPreferencesWithCacheMock extends Mock implements SharedPreferencesWithCache {}

class TokensRepositoryMock extends Mock implements TokensRepository {}

class TokenSelectorModalCubitMock extends Mock implements TokenSelectorModalCubit {}

class DebouncerMock extends Mock implements Debouncer {}

class YieldRepositoryMock extends Mock implements YieldRepository {}

class ZupSingletonCacheMock extends Mock implements ZupSingletonCache {}

class UniswapV3PoolMock extends Mock implements UniswapV3Pool {}

class UniswapV3PoolImplMock extends Mock implements UniswapV3PoolImpl {}

class $AssetsLottiesGenMock extends Mock implements $AssetsLottiesGen {}

class BuildContextMock extends Mock implements BuildContext {}

class UrlLauncherPlatformCustomMock extends UrlLauncherPlatform {
  static String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(String url,
      {required bool useSafariVC,
      required bool useWebView,
      required bool enableJavaScript,
      required bool enableDomStorage,
      required bool universalLinksOnly,
      required Map<String, String> headers,
      String? webOnlyWindowName}) async {
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
  when(() => zupCachedImage.build(
        any(),
        height: any(named: "height"),
        width: any(named: "width"),
        radius: any(named: "radius"),
      )).thenReturn(const SizedBox(child: Text("IMAGE")));

  return zupCachedImage;
}
