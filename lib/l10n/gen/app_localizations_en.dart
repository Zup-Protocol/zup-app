import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get depositPageDepositSectionTitle => 'Deposit';

  @override
  String depositPageDepositSectionTokenNotNeeded(String tokenSymbol) {
    return '$tokenSymbol is not necessary for your selected range';
  }

  @override
  String get preview => 'Preview';

  @override
  String get depositPageInvalidRange => 'Invalid range';

  @override
  String get depositPageMinRangeOutOfRangeWarningText =>
      'You will not earn fees until the market price move up into your range';

  @override
  String get depositPageMaxRangeOutOfRangeWarningText =>
      'You will not earn fees until the market price move down into your range';

  @override
  String get depositPageInvalidRangeErrorText =>
      'Max range should be greater than min range';

  @override
  String get rangeSelectorMinRange => 'Min Range';

  @override
  String get rangeSelectorMaxRange => 'Max Range';

  @override
  String get loading => 'Loading...';

  @override
  String get depositPageLoadingStep1Title => 'Matching Tokens...';

  @override
  String get depositPageLoadingStep1Description =>
      'Pairing Token A and Token B to kick off the search for top yields!';

  @override
  String get depositPageLoadingStep2Title => 'Scanning the Pools...';

  @override
  String get depositPageLoadingStep2Description =>
      'Searching through the sea of pools for the best yields, hang tight!';

  @override
  String get depositPageLoadingStep3Title =>
      'Fetching the Best yields for you...';

  @override
  String get depositPageLoadingStep3Description =>
      'Got it! Just adding a touch of sparkle to your perfect match!';

  @override
  String get depositPageErrorStateTitle => 'Oops! Something went wrong!';

  @override
  String get depositPageErrorStateDescription =>
      'We ran into a issue while trying to find the best pool. Give it another shot, and if it keeps happening, don’t hesitate to reach out to us!';

  @override
  String get depositPageEmptyStateTitle => 'No Pools Found';

  @override
  String get depositPageEmptyStateDescription =>
      'Seems like that there are no pools on our supported protocols matching your selected tokens. Would you like to try another combination?';

  @override
  String get depositPageEmptyStateHelpButtonTitle => 'Try another combination';

  @override
  String get depositPageBackButtonTitle => 'Select Pair';

  @override
  String get depositPageTitle => 'Add liquidity';

  @override
  String get depositPageTimeFrameTooltipMessage =>
      'Select a time-frame that matches your goal with this pool: a quick win (Short term), a balanced approach (Medium term), or a long haul (Long term).';

  @override
  String get depositPageTimeFrameTooltipHelperButtonTitle => ' Learn more';

  @override
  String get depositPageTimeFrameTitle => 'Preferred time frame';

  @override
  String get depositPageNoYieldSelectedTitle => 'Pick a yield to deposit';

  @override
  String get depositPageNoYieldSelectedDescription =>
      'Pick any yield card above and dive into depositing your liquidity!';

  @override
  String get depositPageRangeSectionTitle => 'Select Range';

  @override
  String get depositPageRangeSectionFullRange => 'Full Range';

  @override
  String depositPageInvalidTokenAmount(String tokenSymbol) {
    return 'Enter a valid amount for $tokenSymbol';
  }

  @override
  String depositPageInsufficientTokenBalance(String tokenSymbol) {
    return 'Insufficient $tokenSymbol balance';
  }

  @override
  String depositPagePleaseEnterAmountForToken(String tokenSymbol) {
    return 'Please enter an amount for $tokenSymbol';
  }

  @override
  String get depositPageDeposit => 'Deposit';

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
  String get connectWallet => 'Connect Wallet';

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
  String get token0 => 'Token A';

  @override
  String get token1 => 'Token B';

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
