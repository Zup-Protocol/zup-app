import 'package:flutter/material.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

class PositionToken extends StatelessWidget {
  PositionToken({super.key, required this.tokenSymbol, required this.tokenLogoUrl});

  final String tokenSymbol;
  final String tokenLogoUrl;

  final zupCachedImage = inject<ZupCachedImage>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        zupCachedImage.build(tokenLogoUrl, height: 30, width: 30, radius: 50),
        const SizedBox(width: 10),
        Text(
          tokenSymbol,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
