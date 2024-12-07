import 'package:url_launcher/url_launcher.dart';

class ZupLinks {
  static String get zupWebsite => "https://zupprotocol.xyz";
  static String get zupGithub => "https://github.com/Zup-Protocol";
  static String get zupTelegram => "https://t.me/zupprotocol";
  static String get zupTwitter => "https://x.com/zup_protocol";

  Future<void> launchZupWebsite() async => await launchUrl(Uri.parse(zupWebsite));
  Future<void> launchZupGithub() async => await launchUrl(Uri.parse(zupGithub));
  Future<void> launchZupTelegram() async => await launchUrl(Uri.parse(zupTelegram));
  Future<void> launchZupTwitter() async => await launchUrl(Uri.parse(zupTwitter));
}
