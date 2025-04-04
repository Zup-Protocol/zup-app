import 'package:zup_app/core/enums/zup_navigator_paths.dart';

extension RouteVerifierExtension on String {
  bool get isNewPosition => ZupNavigatorPaths.newPosition.path == this;
}
