import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';
import 'package:zup_app/core/enums/app_environment.dart';

void main() {
  test(
    'When calling `logoUrl` in a token group, it should build the url from the zup api based on the environment',
    () {
      final tokenGroup = TokenGroupDto.fixture();

      expect(tokenGroup.logoUrl, '${AppEnvironment.current.apiUrl}/static/group-icons/${tokenGroup.id}.svg');
    },
  );
}
