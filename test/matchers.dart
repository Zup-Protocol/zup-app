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
