import 'package:flutter/material.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class AppCookieConsentWidget extends StatelessWidget {
  AppCookieConsentWidget({super.key, required this.onAccept});

  final void Function() onAccept;

  final zupLinks = inject<ZupLinks>();
  final cache = inject<Cache>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ZupThemeColors.background.themed(context.brightness),
        border: Border.all(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
        borderRadius: BorderRadius.circular(12),
      ),
      width: 300,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: S.of(context).appCookiesConsentWidgetDescription,
                    style: const TextStyle(color: ZupColors.gray, fontSize: 14),
                  ),
                  const TextSpan(text: " "),
                  WidgetSpan(
                    child: SizedBox(
                      height: 17,
                      child: TextButton(
                        key: const Key("privacy-policy-button"),
                        onPressed: () {
                          zupLinks.launchPrivacyPolicy();
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          splashFactory: NoSplash.splashFactory,
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        child: Text(
                          S.of(context).privacyPolicy,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                            color: ZupColors.brand,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ZupPrimaryButton(
              key: const Key("accept-cookies-button"),
              height: 40,
              title: S.of(context).understood,
              hoverElevation: 0,
              backgroundColor: ZupColors.brand.withValues(alpha: 0.1),
              foregroundColor: ZupColors.brand,
              hoverColor: ZupColors.brand.withValues(alpha: 0.1),
              onPressed: (buttonContext) {
                onAccept();
                cache.saveCookiesConsentStatus(status: true);
              },
              alignCenter: true,
              width: double.maxFinite,
            ),
          ],
        ),
      ),
    );
  }
}
