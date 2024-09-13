import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/routes.g.dart';
import 'package:zup_app/theme/theme.dart';

class ZupApp extends StatelessWidget {
  const ZupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: ZupNavigatorPaths.initial.routeName,
        routeBuilder: (_, settings, child) => PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => child,
        ),
      ),
      theme: ZupTheme.lightTheme,
    );
  }
}
