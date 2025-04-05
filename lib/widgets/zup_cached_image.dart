import 'package:flutter/material.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class ZupCachedImage {
  String _parseImageUrl(String url) {
    if (url.startsWith("ipfs://")) {
      return url.replaceFirst("ipfs://", "https://ipfs.io/ipfs/");
    }

    return url;
  }

  Widget build(
    String url, {
    double? height,
    double? width,
    double? radius,
    ImageLoadingBuilder? loadingBuilder,
    ImageErrorWidgetBuilder? errorWidget,
  }) {
    return ClipRRect(
      key: Key(url),
      borderRadius: BorderRadius.circular(radius ?? 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 0),
          border: Border.all(width: 0.5, color: ZupColors.gray5),
        ),
        // cache not implemented yet because of web issue rendering images from other domains
        child: Image.network(
          _parseImageUrl(url),
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: errorWidget,
          loadingBuilder: loadingBuilder,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        ),
      ),
    );
  }
}
