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
    Widget? placeholder,
    ImageErrorWidgetBuilder? errorWidget,
  }) {
    return Container(
      key: ValueKey(url),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
        border: Border.all(width: 0.5, color: ZupColors.gray5),
      ),
      // cache not implemented yet because of web issue rendering images from other domains (https://github.com/Baseflow/flutter_cached_network_image/issues/972)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: Image.network(
          _parseImageUrl(url),
          height: height,
          width: width,

          fit: BoxFit.cover,
          errorBuilder: errorWidget,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame == null) return placeholder ?? ZupCircularLoadingIndicator(size: height ?? 20);
            return child;
          },
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        ),
      ),
    );
  }
}
