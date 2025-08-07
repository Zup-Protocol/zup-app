import 'package:flutter_test/flutter_test.dart';

class ExpectedMatcher extends Matcher {
  ExpectedMatcher({required this.expects});

  final Function(dynamic item) expects;

  @override
  Description describe(Description description) => description.add("dale");

  @override
  bool matches(item, Map matchState) {
    expects(item);

    return true;
  }
}

class ObjectParamMatcher extends Matcher {
  ObjectParamMatcher(this.matching);

  final bool Function(dynamic object) matching;

  @override
  Description describe(Description description) => description.add("dale");

  @override
  bool matches(item, Map matchState) {
    return matching(item);
  }
}
