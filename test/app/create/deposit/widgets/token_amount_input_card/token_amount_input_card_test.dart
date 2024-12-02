import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_input_card/token_amount_input_card.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../../../../golden_config.dart';
import '../../../../../mocks.dart';

void main() {
  late Wallet wallet;
  late Signer signer;

  setUp(() {
    wallet = WalletMock();
    signer = SignerMock();

    inject.registerFactory<Wallet>(() => wallet);
    inject.registerFactory<ZupSingletonCache>(() => ZupSingletonCache.shared);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());

    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() async {
    await ZupSingletonCache.shared.clear();
    await inject.reset();
  });

  Future<DeviceBuilder> goldenBuilder({
    Key? key,
    TextEditingController? controller,
    Networks network = Networks.sepolia,
    Function(double)? onInput,
    TokenDto? token,
    String? disabledText,
  }) async =>
      await goldenDeviceBuilder(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 500,
                child: TokenAmountInputCard(
                  key: key,
                  controller: controller ?? TextEditingController(),
                  network: network,
                  onInput: (value) => onInput?.call(value),
                  token: token ?? TokenDto.fixture(),
                  disabledText: disabledText,
                ),
              ),
            ],
          ),
        ),
      );

  zGoldenTest("When there is not a connected wallet, it should not show the user balance",
      goldenFileName: "token_amount_card_not_connected", (tester) async {
    when(() => wallet.signer).thenReturn(null);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();
  });

  zGoldenTest(""""
  When an event that the signer changes is emitted,
  and the signer was null,
  it should get the balance of the new connected wallet 
  and display it
  """, goldenFileName: "token_amount_card_signer_changes", (tester) async {
    final signerStreamController = StreamController<Signer?>.broadcast();

    when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);
    when(() => wallet.signer).thenReturn(null);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    signerStreamController.add(signer);
    when(() => wallet.signer).thenReturn(signer);

    await tester.pumpAndSettle();

    verify(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).called(1);
  });

  zGoldenTest(""""
  When an event that the signer changes is emitted,
  and the signer was not null,
  it should get the balance of the new connected wallet 
  and display it
  """, goldenFileName: "token_amount_card_signer_changes_not_null", (tester) async {
    final signer1 = signer;
    final signer2 = SignerMock();

    final signerStreamController = StreamController<Signer?>.broadcast();

    when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);
    when(() => wallet.signer).thenReturn(signer1);
    when(() => signer2.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(43727653762.1));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    signerStreamController.add(signer2);
    when(() => wallet.signer).thenReturn(signer2);

    await tester.pumpAndSettle();
    verify(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).called(1);
  });

  zGoldenTest("""When there is a connected wallet,
  it should get the user balance and show it in a button""", goldenFileName: "token_amount_card_connected",
      (tester) async {
    when(() => wallet.signer).thenReturn(signer);

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("""When the disabled text param is passed,
  the card should be disabled and with the text passed
  """, goldenFileName: "token_amount_card_disabled", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(disabledText: "This card is disabled"));
  });

  zGoldenTest("When inputting something in the textfield, it should callback with the value", (tester) async {
    double expectedValue = 1.2;
    double? actualValue;
    await tester.pumpDeviceBuilder(await goldenBuilder(onInput: (typed) => actualValue = typed));

    await tester.enterText(find.byType(TextField), expectedValue.toString());
    await tester.pumpAndSettle();

    expect(actualValue, expectedValue);
  });

  zGoldenTest("When inputting a non-number in the textfield, it should not accept",
      goldenFileName: "token_amount_card_non_number", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byType(TextField), "abcdefgj");
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking in the user balance button, it should input the balance",
      goldenFileName: "token_amount_card_user_balance_click", (tester) async {
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(43727653762.1));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("user-balance-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking in the user balance button, it should callback with the balance", (tester) async {
    const expectedValue = 43727653762.1;
    double? actualValue;

    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(expectedValue));

    await tester.pumpDeviceBuilder(await goldenBuilder(onInput: (value) => actualValue = value));

    await tester.tap(find.byKey(const Key("user-balance-button")));
    await tester.pumpAndSettle();

    expect(actualValue, expectedValue);
  });

  zGoldenTest("When clicking in the refresh button, it should get the token amount again, ignoring the cache",
      goldenFileName: "token_amount_card_refresh", (tester) async {
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(43727653762.1));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12345.43));
    await tester.tap(find.byKey(const Key("refresh-balance-button")));

    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When updating the widget with a different token, it should update the token in the cubit and get the balance again",
    goldenFileName: "token_amount_card_update_token",
    (tester) async {
      const key = Key("token-amount-card");
      const newTokenAddress = "0xN3W_T0K3N";
      final newToken = TokenDto.fixture().copyWith(address: newTokenAddress, symbol: "NEW_TOKEN");

      await tester.pumpDeviceBuilder(await goldenBuilder(key: key));
      await tester.pumpDeviceBuilder(await goldenBuilder(key: key, token: newToken));

      verify(() => wallet.tokenBalance(newTokenAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
    },
  );

  zGoldenTest(
    """When there's a large number typed, it should not hard clip it in the left border,
    but instead do a soft clip with a gradient""",
    goldenFileName: "token_amount_card_large_number_left_border",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.enterText(find.byType(TextField), "1234567890123456789021762561752615261");
    },
  );

  zGoldenTest(
    """When there's a large number typed, it should not hard clip it in the right border,
    but instead do a soft clip with a gradient""",
    goldenFileName: "token_amount_card_large_number_right_border",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.enterText(find.byType(TextField), "1234567890123456789021762561752615261");
      await tester.drag(find.byType(TextField), const Offset(-1, 0));

      FocusManager.instance.primaryFocus?.unfocus();
    },
  );
}