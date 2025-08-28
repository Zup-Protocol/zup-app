import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/app_bottom_navigation_bar.dart';
import 'package:zup_app/widgets/app_cookies_consent_widget.dart';
import 'package:zup_app/widgets/app_footer.dart';
import 'package:zup_app/widgets/app_header/app_header.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with DeviceInfoMixin {
  bool get shouldShowBottomNavigationBar => isTabletSize(context);

  final double appBarHeight = 85;
  final cache = inject<Cache>();
  final appCubit = inject<AppCubit>();

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
              child: SelectionArea(child: AppCookieConsentWidget(onAccept: () => overlayEntry.remove())),
            ),
          );
        },
      );

      if (cache.getCookiesConsentStatus() == null) Overlay.of(context).insert(overlayEntry);

      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          backgroundColor: ZupColors.orange6,
          padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
          dividerColor: Colors.transparent,
          content: const Text(
            "⚠️ 24h Yields on Base Network are temporarily unavailable, we’re on it! 🚧 7d, 30d, and 90d Yields are still running fine.",
            style: TextStyle(color: ZupColors.orange),
          ),
          actions: [
            ZupIconButton(
              iconColor: ZupColors.orange,
              backgroundColor: ZupColors.orange5,
              icon: const Icon(Icons.close),
              onPressed: (context) => ScaffoldMessenger.of(context).clearMaterialBanners(),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: ZupThemeColors.background.themed(context.brightness),
        bottomNavigationBar: shouldShowBottomNavigationBar ? const AppBottomNavigationBar() : null,
        extendBody: shouldShowBottomNavigationBar,
        body: CustomScrollView(
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
            const SliverFillRemaining(hasScrollBody: false, child: RouterOutlet(key: Key("screen"))),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: shouldShowBottomNavigationBar ? AppBottomNavigationBar.height : 0),
                child: const AppFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
