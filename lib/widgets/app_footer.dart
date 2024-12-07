import 'package:flutter/material.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  ZupLinks get _zupLinks => inject<ZupLinks>();
  Widget _spacing() => const SizedBox(width: 20);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40).copyWith(top: 0),
      child: Column(
        children: [
          const Divider(color: ZupColors.gray5, thickness: 0.5),
          const SizedBox(height: 20),
          Row(
            children: [
              Assets.logos.zupGray.svg(height: 25),
              const SizedBox(width: 40),
              ZupLightButton(
                child: Text(S.of(context).appFooterTermsOfUse, style: const TextStyle(fontSize: 14)),
                onPressed: () {},
              ),
              _spacing(),
              ZupLightButton(
                child: Text(S.of(context).appFooterPrivacyPolicy, style: const TextStyle(fontSize: 14)),
                onPressed: () {},
              ),
              _spacing(),
              ZupLightButton(
                child: Text(S.of(context).appFooterDocs, style: const TextStyle(fontSize: 14)),
                onPressed: () {},
              ),
              _spacing(),
              ZupLightButton(
                child: Text(S.of(context).appFooterFAQ, style: const TextStyle(fontSize: 14)),
                onPressed: () {},
              ),
              _spacing(),
              ZupLightButton(
                child: Text(S.of(context).appFooterContactUs, style: const TextStyle(fontSize: 14)),
                onPressed: () {},
              ),
              const Spacer(),
              ZupLightButton(
                key: const Key("github-button"),
                child: Assets.logos.github.svg(height: 20),
                onPressed: () => _zupLinks.launchZupGithub(),
              ),
              _spacing(),
              ZupLightButton(
                key: const Key("twitter-button"),
                child: Assets.logos.x.svg(height: 20),
                onPressed: () => _zupLinks.launchZupTwitter(),
              ),
              _spacing(),
              ZupLightButton(
                key: const Key("telegram-button"),
                child: Assets.logos.telegram.svg(height: 22),
                onPressed: () => _zupLinks.launchZupTelegram(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
