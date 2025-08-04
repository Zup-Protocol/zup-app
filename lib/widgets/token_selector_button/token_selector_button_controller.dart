import 'dart:async';

import 'package:async/async.dart' show StreamGroup;
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';

class TokenSelectorButtonController {
  TokenDto? _selectedToken;
  TokenGroupDto? _selectedTokenGroup;

  final StreamController<TokenDto?> _selectedTokenStreamController = StreamController<TokenDto?>.broadcast();
  final StreamController<TokenGroupDto?> _selectedTokenGroupStreamController =
      StreamController<TokenGroupDto?>.broadcast();

  bool get hasSelection => _selectedToken != null || _selectedTokenGroup != null;

  TokenDto? get selectedToken => _selectedToken;
  TokenGroupDto? get selectedTokenGroup => _selectedTokenGroup;

  Stream<TokenDto?> get selectedTokenStream => _selectedTokenStreamController.stream;
  Stream<TokenGroupDto?> get selectedTokenGroupStream => _selectedTokenGroupStreamController.stream;
  Stream get selectionStream => StreamGroup.mergeBroadcast([selectedTokenStream, selectedTokenGroupStream]);

  void changeToken(TokenDto? newToken) {
    if (newToken == _selectedToken) return;

    _selectedToken = newToken;
    _selectedTokenGroup = null;

    _selectedTokenStreamController.add(_selectedToken);
    _selectedTokenGroupStreamController.add(null);
  }

  void changeTokenGroup(TokenGroupDto? newTokenGroup) {
    if (newTokenGroup == _selectedTokenGroup) return;

    _selectedToken = null;
    _selectedTokenGroup = newTokenGroup;

    _selectedTokenGroupStreamController.add(_selectedTokenGroup);
    _selectedTokenStreamController.add(null);
  }
}
