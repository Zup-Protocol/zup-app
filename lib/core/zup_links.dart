import 'package:url_launcher/url_launcher.dart';

class ZupLinks {
  static String get zupWebsite => "https://zupprotocol.xyz";
  static String get zupGithub => "https://github.com/Zup-Protocol";
  static String get zupTelegram => "https://t.me/zupprotocol";
  static String get zupTermsOfUse => "https://zupprotocol.gitbook.io/documentation/legal/terms-of-use";
  static String get zupPrivacyPolicy => "https://zupprotocol.gitbook.io/documentation/legal/privacy-policy";
  static String get zupTwitter => "https://x.com/zup_protocol";
  static String get zupDocs => "https://zupprotocol.gitbook.io/documentation";
  static String get zupFAQ => "https://zupprotocol.gitbook.io/documentation/general/faq";
  static String get zupContactUs => "https://zupprotocol.gitbook.io/documentation/other/contact-us";

  Future<void> launchZupWebsite() async => await launchUrl(Uri.parse(zupWebsite));
  Future<void> launchZupGithub() async => await launchUrl(Uri.parse(zupGithub));
  Future<void> launchZupTelegram() async => await launchUrl(Uri.parse(zupTelegram));
  Future<void> launchTermsOfUse() async => await launchUrl(Uri.parse(zupTermsOfUse));
  Future<void> launchPrivacyPolicy() async => await launchUrl(Uri.parse(zupPrivacyPolicy));
  Future<void> launchZupTwitter() async => await launchUrl(Uri.parse(zupTwitter));
  Future<void> launchZupDocs() async => await launchUrl(Uri.parse(zupDocs));
  Future<void> launchZupFAQ() async => await launchUrl(Uri.parse(zupFAQ));
  Future<void> launchZupContactUs() async => await launchUrl(Uri.parse(zupContactUs));
}
