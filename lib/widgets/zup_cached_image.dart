import 'package:cached_network_image/cached_network_image.dart';
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
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, Object)? errorWidget,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 0),
          border: Border.all(width: 0.5, color: ZupColors.gray5),
        ),
        child: CachedNetworkImage(
          imageUrl: _parseImageUrl(url),
          height: height,
          width: width,
          placeholder: placeholder,
          errorWidget: errorWidget ?? (context, url, error) => Container(color: ZupColors.gray5),
        ),
      ),
    );
  }
}
