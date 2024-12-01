import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/zup_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Web3Kit.initialize();
  await setupInjections();

  if (kIsWeb) usePathUrlStrategy();

  runApp(ZupApp());

  await Wallet.shared.connectCachedWallet();
}
