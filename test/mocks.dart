import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/zup_navigator.dart';

class AppCubitMock extends Mock implements AppCubit {}

class ZupNavigatorMock extends Mock implements ZupNavigator {}

class ListenableMock extends Mock implements Listenable {}

class WalletMock extends Mock implements Wallet {}

class SignerMock extends Mock implements Signer {}

T mockHttpImage<T>(T Function() on, {Uint8List? overrideImage}) {
  return mockNetworkImages(on, imageBytes: overrideImage);
}
