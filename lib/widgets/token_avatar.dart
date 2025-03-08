import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_colors.dart';

class TokenAvatar extends StatelessWidget {
  TokenAvatar({super.key, required this.asset, this.size = 30});

  final TokenDto asset;
  final double size;

  final zupCachedImage = inject<ZupCachedImage>();

  @override
  Widget build(BuildContext context) {
    return asset.logoUrl.isEmpty
        ? SizedBox(
            height: size,
            width: size,
            child: FittedBox(
              child: CircleAvatar(
                backgroundColor: ZupColors.brand7,
                foregroundColor: ZupColors.brand,
                child: Text(asset.name.isNotEmpty ? asset.name[0] : ""),
              ),
            ),
          )
        : zupCachedImage.build(asset.logoUrl, height: size, width: size, radius: 50);
  }
}
