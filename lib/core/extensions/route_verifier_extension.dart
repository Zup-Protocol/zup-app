import 'package:zup_app/core/zup_navigator.dart';

extension RouteVerifierExtension on String {
  bool get isMyPositions => ZupNavigatorPaths.myPositions.routeName == this;
  bool get isNewPosition => ZupNavigatorPaths.newPosition.routeName == this;
}
