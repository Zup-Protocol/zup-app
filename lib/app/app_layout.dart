import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/widgets/app_header/app_header.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final double appBarHeight = 85;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ScrollbarTheme(
          data: const ScrollbarThemeData(mainAxisMargin: 10, crossAxisMargin: 3),
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            scrollBehavior: const MaterialScrollBehavior(),
            slivers: [
              SliverAppBar(
                clipBehavior: Clip.none,
                forceMaterialTransparency: true,
                pinned: true,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AppHeader(height: appBarHeight),
                ),
                toolbarHeight: appBarHeight,
              ),
              const SliverToBoxAdapter(child: RouterOutlet()),
            ],
          ),
        ),
      ),
    );
  }
}
