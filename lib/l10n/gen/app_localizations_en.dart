// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appBottomNavigationBarMyPositions => 'My Positions (Soon)';

  @override
  String get appBottomNavigationBarNewPosition => 'New Position';

  @override
  String get appCookiesConsentWidgetDescription =>
      'We use cookies to ensure that we give you the best experience on our app. By continuing to use Zup Protocol, you agree to our';

  @override
  String get appFooterContactUs => 'Contact Us';

  @override
  String get appFooterDocs => 'Docs';

  @override
  String get appFooterFAQ => 'FAQ';

  @override
  String get appFooterTermsOfUse => 'Terms of Use';

  @override
  String get appHeaderMyPositions => 'My Positions (Soon)';

  @override
  String get appHeaderNewPosition => 'New Position';

  @override
  String get appSettingsDropdownTestnetMode => 'Testnet Mode';

  @override
  String get close => 'Close';

  @override
  String get connectMyWallet => 'Connect My Wallet';

  @override
  String get connectWallet => 'Connect Wallet';

  @override
  String get connectYourWallet => 'Connect your wallet';

  @override
  String get createNewPosition => 'Create new position';

  @override
  String get createPageDescription =>
      'Ready to dive in? First, pick the dynamic duo of tokens you want to team up in the pool. Just choose your pair right below and you’re set to make some magic!';

  @override
  String get createPageSelectTokensStageSearchSettings => 'Search Settings';

  @override
  String get createPageSelectTokensStageTokenA => 'Token A';

  @override
  String get createPageSelectTokensStageTokenB => 'Token B';

  @override
  String get createPageSettingsDropdownAllowedPoolTypes => 'Allowed Pool Types';

  @override
  String get createPageSettingsDropdownAllowedPoolTypesDescription =>
      'Filter the types of liquidity pools to include in your search';

  @override
  String get createPageSettingsDropdownMinimumLiquidity =>
      'Minimum Pool Liquidity';

  @override
  String get createPageSettingsDropdownMinimumLiquidityExplanation =>
      'Filter pools by minimum liquidity. We’ll exclude pools with less liquidity than specified, as low Liquidity can lead to misleading yields. This helps you find more reliable opportunities';

  @override
  String get createPageSettingsDropdownMiniumLiquidityLowWarning =>
      'Low minimum TVL can lead to misleading yields.';

  @override
  String get createPageShowMeTheMoney => 'Show me the money!';

  @override
  String get createPageTitle => 'New Position';

  @override
  String get dark => 'Dark';

  @override
  String get depositSettingsDropdownChildHighSlippageWarningText =>
      'High slippage can lead to Front Running and losses. Be careful! ';

  @override
  String get depositSettingsDropdownChildMaxSlippage => 'Max Slippage';

  @override
  String get depositSettingsDropdownChildTransactionDeadlineExplanation =>
      'Your transaction will be reverted if it is pending for more than this amount of time';

  @override
  String get depositSettingsDropdownTransactionDeadline =>
      'Transaction Deadline';

  @override
  String get depositSuccessModalDescriptionPart1 =>
      'You have successfully deposited into';

  @override
  String get depositSuccessModalDescriptionPart2 => 'Pool at';

  @override
  String get depositSuccessModalDescriptionPart3 => 'on';

  @override
  String get depositSuccessModalTitle => 'Deposit Successful!';

  @override
  String depositSuccessModalViewPositionOnDEX({required String dexName}) {
    return 'View Position on $dexName';
  }

  @override
  String get exchangesFilterDropdownButtonDropdownClearAll => 'Clear All';

  @override
  String get exchangesFilterDropdownButtonDropdownNotFoundStateDescription =>
      'No supported exchanges found with this name';

  @override
  String get exchangesFilterDropdownButtonDropdownNotFoundStateTitle =>
      'Not found';

  @override
  String get exchangesFilterDropdownButtonDropdownSearchHint =>
      'Search by name';

  @override
  String get exchangesFilterDropdownButtonDropdownSelectAll => 'Select All';

  @override
  String get exchangesFilterDropdownButtonErrorSnackBarMessage =>
      'Uh-oh! Something went wrong loading the exchanges. Please try refreshing the page.';

  @override
  String get exchangesFilterDropdownButtonTitle => 'Exchanges';

  @override
  String exchangesFilterDropdownButtonTitleNumered({
    required String exchangesCount,
  }) {
    return 'Exchanges ($exchangesCount)';
  }

  @override
  String get letsGiveItAnotherShot => 'Let\'s give it another shot';

  @override
  String get light => 'Light';

  @override
  String get loading => 'Loading...';

  @override
  String get minutes => 'Minutes';

  @override
  String get month => 'Month';

  @override
  String get monthCompact => '30d';

  @override
  String get newPosition => 'New Position';

  @override
  String get noResultsFor => 'No results for';

  @override
  String get popularTokens => 'Popular Tokens';

  @override
  String get positionCardLiquidity => 'Liquidity: ';

  @override
  String get positionCardMax => 'Max: ';

  @override
  String get positionCardMin => 'Min: ';

  @override
  String positionCardTokenPerToken({
    required String token0Qtd,
    required String token0Symbol,
    required String token1Symbol,
  }) {
    return '$token0Qtd $token0Symbol per $token1Symbol';
  }

  @override
  String get positionCardUnclaimedFees => 'Unclaimed fees: ';

  @override
  String get positionCardViewMore => 'View more';

  @override
  String get positionStatusClosed => 'Closed';

  @override
  String get positionStatusInRange => 'In Range';

  @override
  String get positionStatusOutOfRange => 'Out of Range';

  @override
  String get positionsPageCantFindAPosition =>
      'Can’t find a position? Try switching the app’s network to \"All Networks\" or reload the page';

  @override
  String get positionsPageErrorStateDescription =>
      'An error occurred while loading your positions.\nPlease try again. If the issue persists, feel free to contact us';

  @override
  String get positionsPageMyPositions => 'My Positions';

  @override
  String get positionsPageNoPositionsDescription =>
      'Hm… It looks like you don’t have any positions yet.\nWant to create one?';

  @override
  String positionsPageNoPositionsInNetwork({required String network}) {
    return 'No positions in $network';
  }

  @override
  String positionsPageNoPositionsInNetworkDescription({
    required String network,
  }) {
    return 'It looks like you don’t have any positions in $network yet.\nGo ahead and create one to get started!';
  }

  @override
  String get positionsPageNoPositionsTitle =>
      'You don’t have any positions yet';

  @override
  String get positionsPageNotConnectedDescription =>
      'Wallet not connected. Please connect your\nwallet to view your positions';

  @override
  String positionsPageShowHideClosedPositions({required String isHidden}) {
    String _temp0 = intl.Intl.selectLogic(isHidden, {
      'true': 'Show',
      'false': 'Hide',
      'other': 'Show/Hide',
    });
    return '$_temp0 closed positions';
  }

  @override
  String get preview => 'Preview';

  @override
  String get previewDepositModalApproveSuccessSnackBarHelperButtonTitle =>
      'View Transaction';

  @override
  String previewDepositModalApproveSuccessSnackBarMessage({
    required String tokenSymbol,
  }) {
    return '$tokenSymbol approved successfully. ';
  }

  @override
  String previewDepositModalApproveToken({required String tokenSymbol}) {
    return 'Approve $tokenSymbol';
  }

  @override
  String previewDepositModalApprovingToken({required String tokenSymbol}) {
    return 'Approving $tokenSymbol';
  }

  @override
  String get previewDepositModalAutoSlippageCheckErrorMessage =>
      'Strong market movement! Slippage exceeded. Try again or adjust tolerance.';

  @override
  String previewDepositModalCubitApprovedSnackBarMessage({
    required String tokenSymbol,
  }) {
    return 'Successfully approved $tokenSymbol';
  }

  @override
  String get previewDepositModalCubitApprovingSnackBarMessage => 'Approving...';

  @override
  String previewDepositModalCubitDepositingSnackBarMessage({
    required String token0Symbol,
    required String token1Symbol,
  }) {
    return 'Depositing into $token0Symbol/$token1Symbol Pool...';
  }

  @override
  String get previewDepositModalCurrentPrice => 'Current Price';

  @override
  String get previewDepositModalDeposit => 'Deposit';

  @override
  String get previewDepositModalDepositSuccessSnackBarHelperButtonTitle =>
      'View Transaction';

  @override
  String previewDepositModalDepositSuccessSnackBarMessage({
    required String baseTokenSymbol,
    required String quoteTokenSymbol,
    required String protocol,
  }) {
    return 'Successfully Deposited into the $baseTokenSymbol/$quoteTokenSymbol Pool at $protocol. ';
  }

  @override
  String previewDepositModalDepositingIntoPool({
    required String baseTokenSymbol,
    required String quoteTokenSymbol,
  }) {
    return 'Depositing into $baseTokenSymbol/$quoteTokenSymbol pool';
  }

  @override
  String get previewDepositModalError => 'Error';

  @override
  String get previewDepositModalInRange => 'In Range';

  @override
  String get previewDepositModalMaxPrice => 'Max Price';

  @override
  String get previewDepositModalMinPrice => 'Min Price';

  @override
  String get previewDepositModalMyPosition => 'My Position';

  @override
  String get previewDepositModalNetwork => 'Network';

  @override
  String get previewDepositModalOutOfRange => 'Out of Range';

  @override
  String get previewDepositModalProtocol => 'Protocol';

  @override
  String get previewDepositModalSlippageCheckErrorMessage =>
      'Slippage Check! Please try increasing your slippage for this transaction';

  @override
  String get previewDepositModalTitle => 'Preview Deposit';

  @override
  String get previewDepositModalTransactionErrorSnackBarHelperButtonTitle =>
      'Contact us';

  @override
  String get previewDepositModalTransactionErrorSnackBarMessage =>
      'Transaction Failed. Please try again, if the problem persists, ';

  @override
  String get previewDepositModalWaitingTransaction => 'Waiting Transaction';

  @override
  String get previewDepositModalWaitingTransactionSnackBarHelperButtonTitle =>
      'View on Explorer';

  @override
  String get previewDepositModalWaitingTransactionSnackBarMessage =>
      'Waiting transaction to be confirmed. ';

  @override
  String get previewDepositModalYearlyYield => 'Yearly Yield';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get rangeSelectorMaxRange => 'Max Range';

  @override
  String get rangeSelectorMinRange => 'Min Range';

  @override
  String get searchResults => 'Search results';

  @override
  String get selectToken => 'Select Token';

  @override
  String get slippageExplanation =>
      'Slippage protects you by reverting the transaction if the price changes unfavorably beyond the percentage. This is necessary to prevent losses while adding liquidity';

  @override
  String get somethingWhenWrong => 'Something went wrong';

  @override
  String get system => 'System';

  @override
  String get threeMonths => '3 Months';

  @override
  String get threeMonthsCompact => '90d';

  @override
  String get token0 => 'Token A';

  @override
  String get token1 => 'Token B';

  @override
  String get tokenSelectorModalDescription =>
      'Pick a token from our list or search by symbol or address to build your ideal liquidity pool!';

  @override
  String get tokenSelectorModalErrorDescription =>
      'We hit a snag loading your token list. Give it another go, and if it keeps happening, feel free to reach us';

  @override
  String get tokenSelectorModalSearchAlertForAllNetworks =>
      'When ‘All Networks’ is selected, you can only search by name or symbol. To search by address as well, please select a specific network';

  @override
  String tokenSelectorModalSearchErrorDescription({
    required String searchedTerm,
  }) {
    return 'We hit a snag while searching for a token matching $searchedTerm. Give it another go, and if it keeps happening, feel free to reach us';
  }

  @override
  String get tokenSelectorModalSearchTitle => 'Search token or paste address';

  @override
  String get tokenSelectorModalSearchTitleAllNetworks =>
      'Search token by symbol or name';

  @override
  String get tokenSelectorModalTitle => 'Select a token';

  @override
  String get tokenSelectorModalTokenGroups => 'Token Groups';

  @override
  String get tokenSelectorModalTokenGroupsTooltipMessage =>
      'Token groups let you search pools using multiple tokens in one go. Think of them like batch queries, want all USD stablecoins? Pick the group and we\'ll surface every relevant pool. You can also match groups against single tokens or other groups to discover deep liquidity.';

  @override
  String get tvl => 'TVL';

  @override
  String get twentyFourHours => '24h';

  @override
  String get twentyFourHoursCompact => '24h';

  @override
  String get understood => 'Understood';

  @override
  String get unknown => 'Unknown';

  @override
  String get week => 'Week';

  @override
  String get weekCompact => '7d';

  @override
  String get whatsThisQuestionText => 'What\'s this?';

  @override
  String get yieldCardAverageYieldYearly => 'Average Yearly Yield';

  @override
  String get yieldCardDeposit => 'Deposit';

  @override
  String yieldCardThisPoolIsAtNetwork({required String network}) {
    return 'This pool is at $network';
  }

  @override
  String yieldCardTimeFrameBest({required String timeFrame}) {
    return '$timeFrame best';
  }

  @override
  String yieldCardVisitProtocol({required String protocolName}) {
    return 'Visit $protocolName';
  }

  @override
  String get yieldCardYearlyYield => 'Yearly Yield';

  @override
  String get yieldsPageEmptyStateDescription =>
      'Seems like that there are no pools matching your defined settings at the moment. Would you like to either change your settings or try another combination?';

  @override
  String get yieldsPageEmptyStateHelperButtonTitle => 'Go Back to New Position';

  @override
  String yieldsPageEmptyStateMinTVLAlert({required String tvlUSD}) {
    return 'Searched only for liquidity pools with more than $tvlUSD TVL';
  }

  @override
  String get yieldCardYieldExplanation =>
      'Estimated yearly yield derived from the fees distributed to the liquidity providers.';

  @override
  String yieldCardTimeframeYield({required String timeframe}) {
    return '$timeframe Yield';
  }

  @override
  String yieldsPageDisplayingPoolsWithMinTvlAlert({required String tvlUSD}) {
    return 'Displaying only liquidity pools with more than $tvlUSD TVL.';
  }

  @override
  String yieldsPageApplyTvlFilterButtonTitle({required String tvlUSD}) {
    return 'Show only pools with more than $tvlUSD TVL.';
  }

  @override
  String get yieldsPageDisplayingAllPoolsAlert =>
      'Displaying all liquidity pools.';

  @override
  String get yieldsPageTimeframeExplanation =>
      'Each time frame shows yields based on past performance. Shorter windows (24h, 7d) highlight recent trends for quick moves. Longer windows (30d, 90d) provide a broader view for mid to long-term decisions';

  @override
  String get yieldsPageTimeframeSelectorTitle => 'Best yields in';

  @override
  String get yieldsPageTitle => 'Choose a pool for you';

  @override
  String get yieldsPageDescription =>
      'Select the yield that most suits your needs and deposit to start earning';

  @override
  String get yieldsPageBackButtonTitle => 'Select Pair';

  @override
  String get yieldsPageEmptyStateTitle => 'No Pools Found';

  @override
  String get yieldsPageErrorStateDescription =>
      'We ran into a issue while trying to find the best pool. Give it another shot, and if it keeps happening, don’t hesitate to reach out to us!';

  @override
  String get yieldsPageErrorStateTitle => 'Oops! Something went wrong!';

  @override
  String get yieldsPageLoadingStep1Description =>
      'Pairing Token A and Token B to kick off the search for top yields!';

  @override
  String get yieldsPageLoadingStep1Title => 'Matching Tokens...';

  @override
  String get yieldsPageLoadingStep2Description =>
      'Searching through more than a thousand pool combos… so you don\'t have to';

  @override
  String get yieldsPageLoadingStep3Description =>
      'Scanning pools, calculating returns, and filtering the noise';

  @override
  String get yieldsPageLoadingStep3Title => 'Yield optimizer at work…';

  @override
  String get yieldsPageLoadingStep4Description =>
      'Hang tight, we\'re filtering and organizing the best pools for you';

  @override
  String get yieldsPageLoadingStep4Title =>
      'Organizing the best pools for you…';

  @override
  String get yieldsPageSearchAllPools => 'Search all pools';

  @override
  String get yieldsPageLoadingStep2Title => 'Pair hunting…';
}
