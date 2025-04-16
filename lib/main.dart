import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/firebase_options.dart';
import 'package:zup_app/zup_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "env");
  await Web3Kit.initialize();
  await setupInjections();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  runApp(ZupApp());

  await Wallet.shared.connectCachedWallet();
}
