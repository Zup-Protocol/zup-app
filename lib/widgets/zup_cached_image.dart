import 'package:flutter/material.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class ZupCachedImage {
  String _parseImageUrl(String url) {
    if (url.startsWith("ipfs://")) {
      return url.replaceFirst("ipfs://", "https://ipfs.io/ipfs/");
    }

    return url;
  }

  Widget build(
    BuildContext context,
    String url, {
    double? height,
    double? width,
    double? radius,
    Widget? placeholder,
    Color? backgroundColor,
    ImageErrorWidgetBuilder? errorWidget,
  }) {
    return Container(
      key: ValueKey(url),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
        border: Border.all(width: 0.5, color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
      ),
      // cache not implemented yet because of web issue rendering images from other domains (https://github.com/Baseflow/flutter_cached_network_image/issues/972)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: Container(
          color: backgroundColor,
          child: Image.network(
            _parseImageUrl(url),
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: errorWidget,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (frame == null) {
                return Container(
                  color: ZupThemeColors.background.themed(context.brightness),
                  child: placeholder ?? ZupCircularLoadingIndicator(size: height ?? 20),
                );
              }
              return child;
            },
            webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          ),
        ),
      ),
    );
  }
}
