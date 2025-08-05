import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class _AppBottomNavigationBarItem {
  _AppBottomNavigationBarItem({
    required this.label,
    required this.icon,
    required this.path,
    required this.navigateCallback,
  });

  final String label;
  final Widget icon;
  final String path;
  final Future Function()? navigateCallback;
}

class AppBottomNavigationBar extends StatefulWidget {
  const AppBottomNavigationBar({super.key});

  static double height = 80;

  @override
  State<AppBottomNavigationBar> createState() => _AppBottomNavigationBarState();
}

class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  final ZupNavigator _navigator = inject<ZupNavigator>();

  int _currentIndex = 0;
  Function() onRouteChange = () {};

  late List<_AppBottomNavigationBarItem> items = [
    _AppBottomNavigationBarItem(
      label: S.of(context).appBottomNavigationBarNewPosition,
      path: ZupNavigatorPaths.newPosition.path,
      icon: Assets.icons.plus.svg(
        colorFilter: ColorFilter.mode(
          ZupThemeColors.disabledButtonBackground.themed(context.brightness),
          BlendMode.srcIn,
        ),
        height: 16,
      ),
      navigateCallback: () => _navigator.navigateToNewPosition(),
    ),
    _AppBottomNavigationBarItem(
      label: S.of(context).appBottomNavigationBarMyPositions,
      path: "",
      icon: Assets.icons.waterWaves.svg(
        colorFilter: ColorFilter.mode(
          ZupThemeColors.disabledButtonBackground.themed(context.brightness),
          BlendMode.srcIn,
        ),
        height: 16,
      ),
      navigateCallback: null,
    ),
  ];

  @override
  void initState() {
    onRouteChange = () {
      if (mounted) {
        setState(
          () => _currentIndex = items.indexOf(
            items.firstWhereOrNull((item) => item.path == _navigator.currentRoute) ?? items.first,
          ),
        );
      }
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      onRouteChange();
    });

    _navigator.listenable.addListener(() => onRouteChange());
    super.initState();
  }

  @override
  void dispose() {
    _navigator.listenable.removeListener(onRouteChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppBottomNavigationBar.height,
      child: Stack(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: ZupThemeColors.background.themed(context.brightness).withValues(alpha: 0.85)),
            ),
          ),
          Column(
            children: [
              Divider(color: ZupThemeColors.borderOnBackground.themed(context.brightness), thickness: 0.5, height: 1),
              SizedBox(
                height: AppBottomNavigationBar.height - 1,
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  selectedItemColor: ZupColors.brand,
                  unselectedItemColor: ZupThemeColors.disabledButtonBackground.themed(context.brightness),
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 2.1),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, height: 2.1),
                  elevation: 0,
                  onTap: (index) {
                    items[index].navigateCallback?.call().then((_) {
                      setState(() => _currentIndex = index);
                    });
                  },
                  currentIndex: _currentIndex,
                  items: items
                      .map(
                        (item) => BottomNavigationBarItem(
                          key: Key(item.path),
                          activeIcon: ColorFiltered(
                            colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                            child: item.icon,
                          ),
                          icon: item.icon,
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
