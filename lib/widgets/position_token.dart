import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

class PositionToken extends StatelessWidget {
  PositionToken({super.key, required this.token});

  final TokenDto token;
  final zupCachedImage = inject<ZupCachedImage>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TokenAvatar(asset: token, size: 30),
        const SizedBox(width: 10),
        Text(
          token.symbol,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
