import 'package:flutter/material.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

enum _AppFooterButton {
  github,
  twitter,
  telegram,
  termsOfUse,
  privacyPolicy,
  docs,
  faq,
  contactUs;

  Key get key => switch (this) {
    github => const Key("github-button"),
    twitter => const Key("twitter-button"),
    telegram => const Key("telegram-button"),
    termsOfUse => const Key("terms-of-use-button"),
    privacyPolicy => const Key("privacy-policy-button"),
    docs => const Key("docs-button"),
    faq => const Key("faq-button"),
    contactUs => const Key("contact-us-button"),
  };

  String title(BuildContext context) => switch (this) {
    _AppFooterButton.github => "",
    _AppFooterButton.twitter => "",
    _AppFooterButton.telegram => "",
    _AppFooterButton.termsOfUse => S.of(context).appFooterTermsOfUse,
    _AppFooterButton.privacyPolicy => S.of(context).privacyPolicy,
    _AppFooterButton.docs => S.of(context).appFooterDocs,
    _AppFooterButton.faq => S.of(context).appFooterFAQ,
    _AppFooterButton.contactUs => S.of(context).appFooterContactUs,
  };

  Widget? icon() => switch (this) {
    _AppFooterButton.github => Assets.logos.github.svg(
      height: 20,
      colorFilter: const ColorFilter.mode(ZupColors.gray4, BlendMode.srcIn),
    ),
    _AppFooterButton.twitter => Assets.logos.x.svg(
      height: 20,
      colorFilter: const ColorFilter.mode(ZupColors.gray4, BlendMode.srcIn),
    ),
    _AppFooterButton.telegram => Assets.logos.telegram.svg(
      height: 22,
      colorFilter: const ColorFilter.mode(ZupColors.gray4, BlendMode.srcIn),
    ),
    _ => null,
  };

  Function() onTap(ZupLinks zupLinks) => switch (this) {
    _AppFooterButton.github => () {
      zupLinks.launchZupGithub();
    },
    _AppFooterButton.twitter => () {
      zupLinks.launchZupTwitter();
    },
    _AppFooterButton.telegram => () {
      zupLinks.launchZupTelegram();
    },
    _AppFooterButton.termsOfUse => () {
      zupLinks.launchTermsOfUse();
    },
    _AppFooterButton.privacyPolicy => () {
      zupLinks.launchPrivacyPolicy();
    },
    _AppFooterButton.docs => () {
      zupLinks.launchZupDocs();
    },
    _AppFooterButton.faq => () {
      zupLinks.launchZupFAQ();
    },
    _AppFooterButton.contactUs => () {
      zupLinks.launchZupContactUs();
    },
  };
}

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> with DeviceInfoMixin {
  ZupLinks get _zupLinks => inject<ZupLinks>();

  Widget _spacing() => const SizedBox(width: 20, height: 5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: context.brightness.isDark ? ZupColors.black4 : ZupColors.gray5, thickness: 0.5),
          const SizedBox(height: 20),
          isMobileSize(context) ? _buildMobileFooter() : _buildDesktopFooter(),
        ],
      ),
    );
  }

  Widget _buildMobileFooter() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Assets.logos.zupGray.svg(height: 30),
          const Spacer(),
          GestureDetector(
            key: _AppFooterButton.github.key,
            onTap: _AppFooterButton.github.onTap(_zupLinks),
            child: _AppFooterButton.github.icon(),
          ),
          _spacing(),
          GestureDetector(
            key: _AppFooterButton.twitter.key,
            onTap: _AppFooterButton.twitter.onTap(_zupLinks),
            child: _AppFooterButton.twitter.icon(),
          ),
          _spacing(),
          GestureDetector(
            key: _AppFooterButton.telegram.key,
            onTap: _AppFooterButton.telegram.onTap(_zupLinks),
            child: _AppFooterButton.telegram.icon(),
          ),
        ],
      ),
      const SizedBox(height: 40),
      Wrap(
        runSpacing: 10,
        spacing: 20,
        children: [
          GestureDetector(
            key: _AppFooterButton.termsOfUse.key,
            onTap: _AppFooterButton.termsOfUse.onTap(_zupLinks),
            child: Text(
              _AppFooterButton.termsOfUse.title(context),
              style: const TextStyle(fontSize: 14, color: ZupColors.gray),
            ),
          ),
          GestureDetector(
            key: _AppFooterButton.privacyPolicy.key,
            onTap: _AppFooterButton.privacyPolicy.onTap(_zupLinks),
            child: Text(
              _AppFooterButton.privacyPolicy.title(context),
              style: const TextStyle(fontSize: 14, color: ZupColors.gray),
            ),
          ),
          GestureDetector(
            key: _AppFooterButton.docs.key,
            onTap: _AppFooterButton.docs.onTap(_zupLinks),
            child: Text(
              _AppFooterButton.docs.title(context),
              style: const TextStyle(fontSize: 14, color: ZupColors.gray),
            ),
          ),
          GestureDetector(
            key: _AppFooterButton.faq.key,
            onTap: _AppFooterButton.faq.onTap(_zupLinks),
            child: Text(
              _AppFooterButton.faq.title(context),
              style: const TextStyle(fontSize: 14, color: ZupColors.gray),
            ),
          ),
          GestureDetector(
            key: _AppFooterButton.contactUs.key,
            onTap: _AppFooterButton.contactUs.onTap(_zupLinks),
            child: Text(
              _AppFooterButton.contactUs.title(context),
              style: const TextStyle(fontSize: 14, color: ZupColors.gray),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _buildDesktopFooter() => Row(
    children: [
      Opacity(opacity: 0.5, child: Assets.logos.zupGray.svg(height: 18)),
      const SizedBox(width: 40),
      ZupLightButton(
        key: _AppFooterButton.termsOfUse.key,
        onPressed: _AppFooterButton.termsOfUse.onTap(_zupLinks),
        child: Text(_AppFooterButton.termsOfUse.title(context), style: const TextStyle(fontSize: 14)),
      ),
      _spacing(),
      ZupLightButton(
        key: _AppFooterButton.privacyPolicy.key,
        onPressed: _AppFooterButton.privacyPolicy.onTap(_zupLinks),
        child: Text(_AppFooterButton.privacyPolicy.title(context), style: const TextStyle(fontSize: 14)),
      ),
      _spacing(),
      ZupLightButton(
        key: _AppFooterButton.docs.key,
        onPressed: _AppFooterButton.docs.onTap(_zupLinks),
        child: Text(_AppFooterButton.docs.title(context), style: const TextStyle(fontSize: 14)),
      ),
      _spacing(),
      ZupLightButton(
        key: _AppFooterButton.faq.key,
        onPressed: _AppFooterButton.faq.onTap(_zupLinks),
        child: Text(_AppFooterButton.faq.title(context), style: const TextStyle(fontSize: 14)),
      ),
      _spacing(),
      ZupLightButton(
        key: _AppFooterButton.contactUs.key,
        onPressed: _AppFooterButton.contactUs.onTap(_zupLinks),
        child: Text(_AppFooterButton.contactUs.title(context), style: const TextStyle(fontSize: 14)),
      ),
      const Spacer(),
      ZupLightButton(
        key: _AppFooterButton.github.key,
        onPressed: _AppFooterButton.github.onTap(_zupLinks),
        child: _AppFooterButton.github.icon() ?? const SizedBox.shrink(),
      ),
      _spacing(),
      ZupLightButton(
        key: _AppFooterButton.twitter.key,
        onPressed: _AppFooterButton.twitter.onTap(_zupLinks),
        child: _AppFooterButton.twitter.icon() ?? const SizedBox.shrink(),
      ),
      _spacing(),
      ZupLightButton(
        key: _AppFooterButton.telegram.key,
        onPressed: _AppFooterButton.telegram.onTap(_zupLinks),
        child: _AppFooterButton.telegram.icon() ?? const SizedBox.shrink(),
      ),
    ],
  );
}
