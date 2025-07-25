import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/app_bottom_navigation_bar.dart';
import 'package:zup_app/widgets/app_cookies_consent_widget.dart';
import 'package:zup_app/widgets/app_footer.dart';
import 'package:zup_app/widgets/app_header/app_header.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with DeviceInfoMixin {
  bool get shouldShowBottomNavigationBar => isTabletSize(context);

  final double appBarHeight = 85;
  final cache = inject<Cache>();

  final ScrollController appScrollController = inject<ScrollController>(
    instanceName: InjectInstanceNames.appScrollController,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          return Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectionArea(
                child: AppCookieConsentWidget(
                  onAccept: () => overlayEntry.remove(),
                ),
              ),
            ),
          );
        },
      );

      if (cache.getCookiesConsentStatus() == null) Overlay.of(context).insert(overlayEntry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: shouldShowBottomNavigationBar ? const AppBottomNavigationBar() : null,
        extendBody: shouldShowBottomNavigationBar,
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
                title: AppHeader(height: appBarHeight),
                toolbarHeight: appBarHeight,
              ),
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - appBarHeight),
                  child: const RouterOutlet(
                    key: Key("screen"),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: shouldShowBottomNavigationBar ? AppBottomNavigationBar.height : 0,
                  ),
                  child: const AppFooter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
