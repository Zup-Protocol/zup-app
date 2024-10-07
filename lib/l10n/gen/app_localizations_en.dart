import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get connectYourWallet => 'Connect your wallet';

  @override
  String get tokenSelectorModalTitle => 'Select a token';

  @override
  String get tokenSelectorModalDescription =>
      'Pick a token from our list or search by symbol or address to build your ideal liquidity pool!';

  @override
  String get tokenSelectorModalSearchTitle => 'Search token or paste address';

  @override
  String get tokenSelectorModalErrorDescription =>
      'We hit a snag loading your token list. Give it another go, and if it keeps happening, feel free to reach us';

  @override
  String tokenSelectorModalSearchErrorDescription(String searchedTerm) {
    return 'We hit a snag while searching for a token matching $searchedTerm. Give it another go, and if it keeps happening, feel free to reach us';
  }

  @override
  String get noResultsFor => 'No results for';

  @override
  String get searchResults => 'Search results';

  @override
  String get popularTokens => 'Popular Tokens';

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
  String get selectToken => 'Select Token';

  @override
  String get tokenA => 'Token A';

  @override
  String get tokenB => 'Token B';

  @override
  String get createPageTitle => 'New Position';

  @override
  String get createPageShowMeTheMoney => 'Show me the money!';

  @override
  String get createPageDescription =>
      'Ready to dive in? First, pick the dynamic duo of tokens you want to team up in the pool. Just choose your pair right below and you’re set to make some magic!';

  @override
  String get letsGiveItAnotherGo =>
      'Let’s give it another go, because why not?';

  @override
  String get letsGiveItAnotherShot => 'Let’s give it another shot';
}
