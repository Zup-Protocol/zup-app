import 'dart:async';

import 'package:zup_app/core/dtos/token_dto.dart';

class TokenSelectorButtonController {
  TokenSelectorButtonController({TokenDto? initialSelectedToken}) {
    _selectedToken = initialSelectedToken;
  }

  TokenDto? _selectedToken;
  final StreamController<TokenDto?> _selectedTokenStreamController = StreamController<TokenDto?>.broadcast();

  TokenDto? get selectedToken => _selectedToken;
  Stream<TokenDto?> get selectedTokenStream => _selectedTokenStreamController.stream;

  void changeToken(TokenDto? newToken) {
    _selectedToken = newToken;

    _selectedTokenStreamController.add(_selectedToken);
  }
}
