/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/all.svg
  SvgGenImage get all => const SvgGenImage('assets/icons/all.svg');

  /// File path: assets/icons/arrow.2.squarepath.svg
  SvgGenImage get arrow2Squarepath => const SvgGenImage('assets/icons/arrow.2.squarepath.svg');

  /// File path: assets/icons/arrow.clockwise.svg
  SvgGenImage get arrowClockwise => const SvgGenImage('assets/icons/arrow.clockwise.svg');

  /// File path: assets/icons/arrow.up.right.svg
  SvgGenImage get arrowUpRight => const SvgGenImage('assets/icons/arrow.up.right.svg');

  /// File path: assets/icons/cable.connector.horizontal.svg
  SvgGenImage get cableConnectorHorizontal => const SvgGenImage('assets/icons/cable.connector.horizontal.svg');

  /// File path: assets/icons/network.slash.svg
  SvgGenImage get networkSlash => const SvgGenImage('assets/icons/network.slash.svg');

  /// File path: assets/icons/plus.diamond.svg
  SvgGenImage get plusDiamond => const SvgGenImage('assets/icons/plus.diamond.svg');

  /// File path: assets/icons/plus.svg
  SvgGenImage get plus => const SvgGenImage('assets/icons/plus.svg');

  /// File path: assets/icons/questionmark.svg
  SvgGenImage get questionmark => const SvgGenImage('assets/icons/questionmark.svg');

  /// File path: assets/icons/rectangle.connected.to.line.below.svg
  SvgGenImage get rectangleConnectedToLineBelow => const SvgGenImage('assets/icons/rectangle.connected.to.line.below.svg');

  /// File path: assets/icons/slash.circle.svg
  SvgGenImage get slashCircle => const SvgGenImage('assets/icons/slash.circle.svg');

  /// File path: assets/icons/square.and.line.vertical.and.square.filled.svg
  SvgGenImage get squareAndLineVerticalAndSquareFilled => const SvgGenImage('assets/icons/square.and.line.vertical.and.square.filled.svg');

  /// File path: assets/icons/switch.2.svg
  SvgGenImage get switch2 => const SvgGenImage('assets/icons/switch.2.svg');

  /// File path: assets/icons/tray.svg
  SvgGenImage get tray => const SvgGenImage('assets/icons/tray.svg');

  /// File path: assets/icons/wallet.bifold.svg
  SvgGenImage get walletBifold => const SvgGenImage('assets/icons/wallet.bifold.svg');

  /// File path: assets/icons/water.waves.svg
  SvgGenImage get waterWaves => const SvgGenImage('assets/icons/water.waves.svg');

  /// File path: assets/icons/zup_logo.svg
  SvgGenImage get zupLogo => const SvgGenImage('assets/icons/zup_logo.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
        all,
        arrow2Squarepath,
        arrowClockwise,
        arrowUpRight,
        cableConnectorHorizontal,
        networkSlash,
        plusDiamond,
        plus,
        questionmark,
        rectangleConnectedToLineBelow,
        slashCircle,
        squareAndLineVerticalAndSquareFilled,
        switch2,
        tray,
        walletBifold,
        waterWaves,
        zupLogo
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/zup_logotype.png
  AssetGenImage get zupLogotype => const AssetGenImage('assets/images/zup_logotype.png');

  /// List of all assets
  List<AssetGenImage> get values => [zupLogotype];
}

class $AssetsLogosGen {
  const $AssetsLogosGen();

  /// File path: assets/logos/arbitrum.svg
  SvgGenImage get arbitrum => const SvgGenImage('assets/logos/arbitrum.svg');

  /// File path: assets/logos/base.svg
  SvgGenImage get base => const SvgGenImage('assets/logos/base.svg');

  /// File path: assets/logos/ethereum.svg
  SvgGenImage get ethereum => const SvgGenImage('assets/logos/ethereum.svg');

  /// List of all assets
  List<SvgGenImage> get values => [arbitrum, base, ethereum];
}

class Assets {
  Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLogosGen logos = $AssetsLogosGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ?? (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
