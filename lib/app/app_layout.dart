import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/app_header/app_header.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final double appBarHeight = 85;

  final ScrollController appScrollController = inject<ScrollController>(
    instanceName: InjectInstanceNames.appScrollController,
  );

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ScrollbarTheme(
          data: const ScrollbarThemeData(mainAxisMargin: 10, crossAxisMargin: 3, thickness: WidgetStatePropertyAll(5)),
          child: CustomScrollView(
            controller: appScrollController,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                clipBehavior: Clip.none,
                forceMaterialTransparency: true,
                pinned: true,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 15),
                  child: AppHeader(height: appBarHeight),
                ),
                toolbarHeight: appBarHeight,
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: RouterOutlet(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
