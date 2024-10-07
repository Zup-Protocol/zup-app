import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/debouncer.dart';

void main() {
  test("When passing at least the time passed to debouncer, it should call the action/callback", () {
    bool debounced = false;
    const milliseconds = 500;

    fakeAsync((async) {
      Debouncer(milliseconds: milliseconds).run(() => debounced = true);

      async.elapse(const Duration(milliseconds: milliseconds));

      expect(debounced, true);
    });
  });

  test("When the timer did not pass at least the time passed to debouncer, it should not call the action/callback", () {
    bool debounced = false;
    const milliseconds = 500;

    fakeAsync((async) {
      Debouncer(milliseconds: milliseconds).run(() => debounced = true);

      async.elapse(const Duration(milliseconds: milliseconds - 100));

      expect(debounced, false);
    });
  });

  test("When the debouncer is invoked multiple times, it should only call the action/callback once", () {
    int debouncedTimes = 0;
    const milliseconds = 500;
    final sut = Debouncer(milliseconds: milliseconds);

    fakeAsync((async) {
      sut.run(() => debouncedTimes++);
      sut.run(() => debouncedTimes++);
      sut.run(() => debouncedTimes++);
      sut.run(() => debouncedTimes++);

      async.elapse(const Duration(milliseconds: milliseconds));

      expect(debouncedTimes, 1);
    });
  });

  test(
      "When the debouncer is invoked multiple times, but after the debounce time, it should call the action/callback multiple times",
      () {
    int debouncedTimes = 0;
    const milliseconds = 500;
    final sut = Debouncer(milliseconds: milliseconds);

    fakeAsync((async) {
      sut.run(() => debouncedTimes++);
      async.elapse(const Duration(milliseconds: milliseconds));
      sut.run(() => debouncedTimes++);
      async.elapse(const Duration(milliseconds: milliseconds));
      sut.run(() => debouncedTimes++);
      async.elapse(const Duration(milliseconds: milliseconds));
      sut.run(() => debouncedTimes++);
      async.elapse(const Duration(milliseconds: milliseconds));

      expect(debouncedTimes, 4);
    });
  });
}
