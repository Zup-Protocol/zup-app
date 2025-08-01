import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';

void main() {
  late TokenSelectorButtonController sut;

  setUp(() {
    sut = TokenSelectorButtonController();
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
    sut.changeToken(TokenDto.fixture());

    expectLater(sut.selectedTokenStream, emits(null));
    sut.changeToken(null);
  });

  test("When there is a selected group, and a call to 'changeToken' is made, it should remove the selected group", () {
    sut.changeTokenGroup(TokenGroupDto.fixture());
    sut.changeToken(TokenDto.fixture());

    expect(sut.selectedTokenGroup, null);
  });

  test("When there is a selected group, and a call to 'changeToken' is made, it should emit null selected group", () {
    sut.changeTokenGroup(TokenGroupDto.fixture());

    expectLater(sut.selectedTokenGroupStream, emits(null));
    sut.changeToken(TokenDto.fixture());
  });

  test("When calling 'changeTokenGroup' with a previous selected token, it should remove the selected token", () {
    sut.changeToken(TokenDto.fixture());
    sut.changeTokenGroup(TokenGroupDto.fixture());

    expect(sut.selectedToken, null);
  });

  test("When calling 'changeTokenGroup' with a previous selected token, it should emit null selected token", () {
    sut.changeToken(TokenDto.fixture());

    expectLater(sut.selectedTokenStream, emits(null));
    sut.changeTokenGroup(TokenGroupDto.fixture());
  });

  test("When calling 'changeTokenGroup' with a new token group, it should emit the new token group", () {
    final newTokenGroup = TokenGroupDto.fixture();

    expectLater(sut.selectedTokenGroupStream, emits(newTokenGroup));
    sut.changeTokenGroup(newTokenGroup);
  });

  test("When calling 'changeTokenGroup' with a new token group, it should set the new token group", () {
    final newTokenGroup = TokenGroupDto.fixture();

    sut.changeTokenGroup(newTokenGroup);
    expect(sut.selectedTokenGroup.hashCode, newTokenGroup.hashCode);
  });
}
