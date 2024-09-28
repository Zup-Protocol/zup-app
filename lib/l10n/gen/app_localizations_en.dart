import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get connectYourWallet => 'Connect your wallet';

  @override
  String get connectMyWallet => 'Connect My Wallet';

  @override
  String get positionsPageNotConnectedDescription =>
      'Wallet not connected. Please connect your\nwallet to view your positions';

  @override
  String get positionsPageNoPositionsTitle =>
      'You don’t have any positions yet';

  @override
  String get positionsPageNoPositionsDescription =>
      'Hm… It looks like you don’t have any positions yet.\nWant to create one?';

  @override
  String get newPosition => 'New Position';

  @override
  String get createNewPosition => 'Create new position';

  @override
  String get positionCardMin => 'Min: ';

  @override
  String get positionCardMax => 'Max: ';

  @override
  String get positionCardLiquidity => 'Liquidity: ';

  @override
  String get positionCardUnclaimedFees => 'Unclaimed fees: ';

  @override
  String get positionCardViewMore => 'View more';

  @override
  String positionsPageNoPositionsInNetwork(String network) {
    return 'No positions in $network';
  }

  @override
  String positionsPageShowHideClosedPositions(String isHidden) {
    String _temp0 = intl.Intl.selectLogic(
      isHidden,
      {
        'true': 'Show',
        'false': 'Hide',
        'other': 'Show/Hide',
      },
    );
    return '$_temp0 closed positions';
  }

  @override
  String positionsPageNoPositionsInNetworkDescription(String network) {
    return 'It looks like you don’t have any positions in $network yet.\nGo ahead and create one to get started!';
  }

  @override
  String positionCardTokenPerToken(
      String token0Qtd, String token0Symbol, String token1Symbol) {
    return '$token0Qtd $token0Symbol per $token1Symbol';
  }

  @override
  String get positionsPageMyPositions => 'My Positions';

  @override
  String get positionsPageCantFindAPosition =>
      'Can’t find a position? Try switching the app’s network to \"All Networks\" or reload the page';

  @override
  String get somethingWhenWrong => 'Something went wrong';

  @override
  String get positionsPageErrorStateDescription =>
      'An error occurred while loading your positions.\nPlease try again. If the issue persists, feel free to contact us';

  @override
  String get positionStatusInRange => 'In Range';

  @override
  String get positionStatusOutOfRange => 'Out of Range';

  @override
  String get positionStatusClosed => 'Closed';

  @override
  String get unknown => 'Unknown';

  @override
  String get letsGiveItAnotherGo =>
      'Let’s give it another go, because why not?';
}
