import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/zup_app.dart';

Future<void> main() async {
  await setupInjections();
  if (kIsWeb) usePathUrlStrategy();

  runApp(const ZupApp());
  SemanticsBinding.instance.ensureSemantics();
}
