import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zup_app/core/zup_links.dart';

import '../mocks.dart';

void main() {
  setUp(() {
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();
  });

  test(
    "`zupWebsite` should return the correct link",
    () => expect(ZupLinks.zupWebsite, "https://zupprotocol.xyz"),
  );

  test(
    "`zupGithub` should return the correct link",
    () => expect(ZupLinks.zupGithub, "https://github.com/Zup-Protocol"),
  );

  test(
    "`zupTelegram` should return the correct link",
    () => expect(ZupLinks.zupTelegram, "https://t.me/zupprotocol"),
  );

  test(
    "`zupTwitter` should return the correct link",
    () => expect(ZupLinks.zupTwitter, "https://x.com/zup_protocol"),
  );

  test("`zupDocs` should return the correct link for the protocol documentation website", () {
    expect(ZupLinks.zupDocs, "https://zupprotocol.gitbook.io/documentation");
  });

  test("`zupFAQ` should return the correct link for the protocol FAQ", () {
    expect(ZupLinks.zupFAQ, "https://zupprotocol.gitbook.io/documentation/general/faq");
  });

  test("`zupContactUs` should return the correct link for the protocol contact us", () {
    expect(ZupLinks.zupContactUs, "https://zupprotocol.gitbook.io/documentation/other/contact-us");
  });

  test("`launchZupWebsite` should launch the correct link", () {
    ZupLinks().launchZupWebsite();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupWebsite);
  });

  test("`launchZupGithub` should launch the correct link", () {
    ZupLinks().launchZupGithub();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupGithub);
  });

  test("`launchZupTelegram` should launch the correct link", () {
    ZupLinks().launchZupTelegram();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupTelegram);
  });

  test("`launchZupTwitter` should launch the correct link", () {
    ZupLinks().launchZupTwitter();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupTwitter);
  });

  test("`launchZupDocs` should launch the correct link", () {
    ZupLinks().launchZupDocs();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupDocs);
  });

  test("`launchTermsOfUse` should launch the correct link", () {
    ZupLinks().launchTermsOfUse();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupTermsOfUse);
  });

  test("`launchPrivacyPolicy` should launch the correct link", () {
    ZupLinks().launchPrivacyPolicy();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupPrivacyPolicy);
  });

  test("`launchZupFAQ` should launch the correct link", () {
    ZupLinks().launchZupFAQ();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupFAQ);
  });

  test("`launchZupContactUs` should launch the correct link", () {
    ZupLinks().launchZupContactUs();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, ZupLinks.zupContactUs);
  });
}
