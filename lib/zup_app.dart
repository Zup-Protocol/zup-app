import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routefly/routefly.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/theme/theme.dart';

import 'zup_app.route.dart';

part 'zup_app.g.dart';

@Main("lib/app")
class ZupApp extends StatelessWidget {
  ZupApp({super.key});

  final navigatorKey = inject<GlobalKey<NavigatorState>>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Zup | Liquidity Pools Aggregator",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        S.delegate,
        Web3KitLocalizations.delegate,
      ],
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: ZupNavigatorPaths.initial.path,
        navigatorKey: navigatorKey,
        routeBuilder: (_, settings, child) {
          return PageRouteBuilder(
            settings: settings,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => child,
          );
        },
      ),
      theme: ZupTheme.lightTheme,
    );
  }
}
