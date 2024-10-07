import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';

void main() {
  late TokenSelectorButtonController sut;

  setUp(() {
    sut = TokenSelectorButtonController();
  });

  test("When passing the initialSelected token, it should set the variable", () {
    final initialSelectedToken = TokenDto.fixture();
    sut = TokenSelectorButtonController(initialSelectedToken: initialSelectedToken);

    expect(sut.selectedToken.hashCode, initialSelectedToken.hashCode);
  });

  test("When changing the selected token by calling the function, it should set the variable", () {
    final newSelectedToken = TokenDto.fixture();

    /// make sure that the already selected token is not the new one
    expect(sut.selectedToken, null);

    sut.changeToken(newSelectedToken);

    expect(sut.selectedToken.hashCode, newSelectedToken.hashCode);
  });

  test("When changing the selected token by calling the function, it should emit a event", () {
    final newSelectedToken = TokenDto.fixture();

    expectLater(sut.selectedTokenStream, emits(newSelectedToken));

    sut.changeToken(newSelectedToken);
  });

  test("When changing the selected token to null, it should emit a null event", () {
    expectLater(sut.selectedTokenStream, emits(null));

    sut.changeToken(null);
  });
}
