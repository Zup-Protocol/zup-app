import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class ZupCachedImage {
  Widget build(String url, {double? height, double? width, double? radius}) => ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 0),
            border: Border.all(width: 0.5, color: ZupColors.gray5),
          ),
          child: CachedNetworkImage(
            imageUrl: url,
            height: height,
            width: width,
            errorWidget: (context, url, error) => Container(color: ZupColors.gray5),
          ),
        ),
      );
}
