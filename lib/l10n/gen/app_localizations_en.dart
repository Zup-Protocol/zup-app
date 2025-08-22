// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String yieldCardNetworkTooltipDescription({required String network}) {
    return 'This pool is at $network';
  }

  @override
  String get twentyFourHours => '24h';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get week => 'Week';

  @override
  String get weekCompact => '7d';

  @override
  String get appFooterTermsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get appFooterContactUs => 'Contact Us';

  @override
  String get appCookiesConsentWidgetDescription =>
      'We use cookies to ensure that we give you the best experience on our app. By continuing to use Zup Protocol, you agree to our';

  @override
  String get appFooterDocs => 'Docs';

  @override
  String get appFooterFAQ => 'FAQ';

  @override
  String get understood => 'Understood';

  @override
  String depositPageShowingOnlyPoolsWithMoreThan({
    required String minLiquidity,
  }) {
    return 'Showing only liquidity pools with more than $minLiquidity.';
  }

  @override
  String get depositPageShowingAllPools => 'Showing all liquidity pools.';

  @override
  String get depositPageSearchAllPools => 'Search all pools?';

  @override
  String depositPageSearchOnlyForPoolsWithMorethan({
    required String minLiquidity,
  }) {
    return 'Search only for pools with more than $minLiquidity?';
  }

  @override
  String get depositPageTrySearchAllPools => 'Try search all pools?';

  @override
  String depositPageMinLiquiditySearchAlert({required String minLiquidity}) {
    return 'You’ve set the search to only show pools with more than $minLiquidity.';
  }

  @override
  String get slippageExplanation =>
      'Slippage protects you by reverting the transaction if the price changes unfavorably beyond the percentage. This is necessary to prevent losses while adding liquidity';

  @override
  String get month => 'Month';

  @override
  String get minutes => 'Minutes';

  @override
  String get depositSettingsDropdownChildHighSlippageWarningText =>
      'High slippage can lead to Front Running and losses. Be careful! ';

  @override
  String get whatsThisQuestionText => 'What\'s this?';

  @override
  String get depositSettingsDropdownChildTransactionDeadlineExplanation =>
      'Your transaction will be reverted if it is pending for more than this amount of time';

  @override
  String get depositSettingsDropdownTransactionDeadline =>
      'Transaction Deadline';

  @override
  String depositPagePercentSlippage({required String valuePercent}) {
    return '$valuePercent Slippage';
  }

  @override
  String get threeMonths => '3 Months';

  @override
  String get twentyFourHoursCompact => '24h';

  @override
  String get monthCompact => '30d';

  @override
  String get threeMonthsCompact => '90d';

  @override
  String get depositSettingsDropdownChildMaxSlippage => 'Max Slippage';

  @override
  String get depositPageDepositSectionTitle => 'Deposit';

  @override
  String get previewDepositModalWaitingTransaction => 'Waiting Transaction';

  @override
  String previewDepositModalApprovingToken({required String tokenSymbol}) {
    return 'Approving $tokenSymbol';
  }

  @override
  String previewDepositModalDepositingIntoPool({
    required String baseTokenSymbol,
    required String quoteTokenSymbol,
  }) {
    return 'Depositing into $baseTokenSymbol/$quoteTokenSymbol pool';
  }

  @override
  String previewDepositModalApproveToken({required String tokenSymbol}) {
    return 'Approve $tokenSymbol';
  }

  @override
  String get previewDepositModalDeposit => 'Deposit';

  @override
  String get previewDepositModalError => 'Error';

  @override
  String get previewDepositModalCurrentPrice => 'Current Price';

  @override
  String depositPageDepositSectionTokenNotNeeded({
    required String tokenSymbol,
  }) {
    return '$tokenSymbol is not necessary for your selected range';
  }

  @override
  String get preview => 'Preview';

  @override
  String get previewDepositModalTitle => 'Preview Deposit';

  @override
  String get previewDepositModalWaitingTransactionSnackBarMessage =>
      'Waiting transaction to be confirmed. ';

  @override
  String previewDepositModalApproveSuccessSnackBarMessage({
    required String tokenSymbol,
  }) {
    return '$tokenSymbol approved successfully. ';
  }

  @override
  String get previewDepositModalMyPosition => 'My Position';

  @override
  String get previewDepositModalOutOfRange => 'Out of Range';

  @override
  String get previewDepositModalInRange => 'In Range';

  @override
  String get previewDepositModalProtocol => 'Protocol';

  @override
  String get previewDepositModalNetwork => 'Network';

  @override
  String get previewDepositModalYearlyYield => 'Yearly Yield';

  @override
  String get previewDepositModalTransactionErrorSnackBarMessage =>
      'Transaction Failed. Please try again, if the problem persists, ';

  @override
  String get previewDepositModalTransactionErrorSnackBarHelperButtonTitle =>
      'Contact us';

  @override
  String previewDepositModalDepositSuccessSnackBarMessage({
    required String baseTokenSymbol,
    required String quoteTokenSymbol,
    required String protocol,
  }) {
    return 'Successfully Deposited into the $baseTokenSymbol/$quoteTokenSymbol Pool at $protocol. ';
  }

  @override
  String yieldCardTimeFrameBest({required String timeFrame}) {
    return '$timeFrame best';
  }

  @override
  String yieldCardThisPoolIsAtNetwork({required String network}) {
    return 'This pool is at $network';
  }

  @override
  String get yieldCardYearlyYield => 'Yearly Yield';

  @override
  String yieldCardVisitProtocol({required String protocolName}) {
    return 'Visit $protocolName';
  }

  @override
  String get yieldCardAverageYieldYearly => 'Average Yearly Yield';

  @override
  String get previewDepositModalDepositSuccessSnackBarHelperButtonTitle =>
      'View Transaction';

  @override
  String get previewDepositModalApproveSuccessSnackBarHelperButtonTitle =>
      'View Transaction';

  @override
  String get previewDepositModalWaitingTransactionSnackBarHelperButtonTitle =>
      'View on Explorer';

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
  String get previewDepositModalMinPrice => 'Min Price';

  @override
  String get previewDepositModalMaxPrice => 'Max Price';

  @override
  String get rangeSelectorMinRange => 'Min Range';

  @override
  String get rangeSelectorMaxRange => 'Max Range';

  @override
  String get loading => 'Loading...';

  @override
  String get exchangesFilterDropdownButtonDropdownClearAll => 'Clear All';

  @override
  String get exchangesFilterDropdownButtonDropdownSelectAll => 'Select All';

  @override
  String get exchangesFilterDropdownButtonDropdownSearchHint =>
      'Search by name';

  @override
  String get exchangesFilterDropdownButtonDropdownNotFoundStateTitle =>
      'Not found';

  @override
  String get exchangesFilterDropdownButtonDropdownNotFoundStateDescription =>
      'No supported exchanges found with this name';

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
  String get createPageSelectTokensStageTokenA => 'Token A';

  @override
  String get createPageSelectTokensStageTokenB => 'Token B';

  @override
  String get createPageSelectTokensStageSearchSettings => 'Search Settings';

  @override
  String get depositPageLoadingStep1Title => 'Matching Tokens...';

  @override
  String get depositPageLoadingStep1Description =>
      'Pairing Token A and Token B to kick off the search for top yields!';

  @override
  String get depositPageLoadingStep2Title => 'Pair hunting…';

  @override
  String get depositPageLoadingStep2Description =>
      'Searching through more than a thousand pool combos… so you don\'t have to';

  @override
  String get depositPageLoadingStep3Title => 'Yield optimizer at work…';

  @override
  String get depositPageLoadingStep3Description =>
      'Scanning pools, calculating returns, and filtering the noise';

  @override
  String get depositPageBestYieldsIn => 'Best Yields in';

  @override
  String get depositPageLoadingStep4Title =>
      'Organizing the best pools for you…';

  @override
  String get depositPageLoadingStep4Description =>
      'Hang tight, we\'re filtering and organizing the best pools for you';

  @override
  String get depositPageErrorStateTitle => 'Oops! Something went wrong!';

  @override
  String get depositPageErrorStateDescription =>
      'We ran into a issue while trying to find the best pool. Give it another shot, and if it keeps happening, don’t hesitate to reach out to us!';

  @override
  String get depositPageEmptyStateTitle => 'No Pools Found';

  @override
  String get depositPageEmptyStateDescription =>
      'Seems like that there are no pools matching your defined settings at the moment. Would you like to either change your settings or try another combination?';

  @override
  String get depositPageEmptyStateHelpButtonTitle => 'Go Back to New Position';

  @override
  String get depositPageBackButtonTitle => 'Select Pair';

  @override
  String get depositPageTitle => 'Add liquidity';

  @override
  String get depositPageTimeFrameTooltipMessage =>
      'Each time frame shows yields based on past performance. Shorter terms (24h, 7d) reflect recent trends and may suit short-term strategies. Longer terms (30d, 90d) offer a broader performance view for long-term decisions.';

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
  String depositPageInvalidTokenAmount({required String tokenSymbol}) {
    return 'Enter a valid amount for $tokenSymbol';
  }

  @override
  String depositPageInsufficientTokenBalance({required String tokenSymbol}) {
    return 'Insufficient $tokenSymbol balance';
  }

  @override
  String depositPagePleaseEnterAmountForToken({required String tokenSymbol}) {
    return 'Please enter an amount for $tokenSymbol';
  }

  @override
  String get depositPageDeposit => 'Deposit';

  @override
  String get connectYourWallet => 'Connect your wallet';

  @override
  String get tokenSelectorModalTitle => 'Select a token';

  @override
  String get tokenSelectorModalTokenGroups => 'Token Groups';

  @override
  String get tokenSelectorModalTokenGroupsTooltipMessage =>
      'Token groups let you search pools using multiple tokens in one go. Think of them like batch queries, want all USD stablecoins? Pick the group and we\'ll surface every relevant pool. You can also match groups against single tokens or other groups to discover deep liquidity.';

  @override
  String get tokenSelectorModalDescription =>
      'Pick a token from our list or search by symbol or address to build your ideal liquidity pool!';

  @override
  String get tokenSelectorModalSearchTitle => 'Search token or paste address';

  @override
  String get tokenSelectorModalSearchTitleAllNetworks =>
      'Search token by symbol or name';

  @override
  String get tokenSelectorModalSearchAlertForAllNetworks =>
      'When ‘All Networks’ is selected, you can only search by name or symbol. To search by address as well, please select a specific network';

  @override
  String get tokenSelectorModalErrorDescription =>
      'We hit a snag loading your token list. Give it another go, and if it keeps happening, feel free to reach us';

  @override
  String tokenSelectorModalSearchErrorDescription({
    required String searchedTerm,
  }) {
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
  String positionsPageNoPositionsInNetwork({required String network}) {
    return 'No positions in $network';
  }

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
  String positionsPageNoPositionsInNetworkDescription({
    required String network,
  }) {
    return 'It looks like you don’t have any positions in $network yet.\nGo ahead and create one to get started!';
  }

  @override
  String positionCardTokenPerToken({
    required String token0Qtd,
    required String token0Symbol,
    required String token1Symbol,
  }) {
    return '$token0Qtd $token0Symbol per $token1Symbol';
  }

  @override
  String get positionsPageMyPositions => 'My Positions';

  @override
  String get appHeaderMyPositions => 'My Positions (Soon)';

  @override
  String get appHeaderNewPosition => 'New Position';

  @override
  String get appBottomNavigationBarMyPositions => 'My Positions (Soon)';

  @override
  String get appBottomNavigationBarNewPosition => 'New Position';

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
  String get depositSuccessModalTitle => 'Deposit Successful!';

  @override
  String get depositSuccessModalDescriptionPart1 =>
      'You have successfully deposited into';

  @override
  String get depositSuccessModalDescriptionPart2 => 'Pool at';

  @override
  String get depositSuccessModalDescriptionPart3 => 'on';

  @override
  String previewDepositModalCubitDepositingSnackBarMessage({
    required String token0Symbol,
    required String token1Symbol,
  }) {
    return 'Depositing into $token0Symbol/$token1Symbol Pool...';
  }

  @override
  String get previewDepositModalCubitApprovingSnackBarMessage => 'Approving...';

  @override
  String previewDepositModalCubitApprovedSnackBarMessage({
    required String tokenSymbol,
  }) {
    return 'Successfully approved $tokenSymbol';
  }

  @override
  String depositSuccessModalViewPositionOnDEX({required String dexName}) {
    return 'View Position on $dexName';
  }

  @override
  String get close => 'Close';

  @override
  String depositPageDepositWithNativeToken({required String tokenSymbol}) {
    return 'Deposit with Native $tokenSymbol';
  }

  @override
  String get createPageSettingsDropdownMinimumLiquidity =>
      'Minimum Pool Liquidity';

  @override
  String get createPageSettingsDropdownAllowedPoolTypes => 'Allowed Pool Types';

  @override
  String get createPageSettingsDropdownAllowedPoolTypesDescription =>
      'Filter the types of liquidity pools to include in your search';

  @override
  String get createPageSettingsDropdownMinimumLiquidityExplanation =>
      'Filter pools by minimum liquidity. We’ll exclude pools with less liquidity than specified, as low Liquidity can lead to misleading yields. This helps you find more reliable opportunities';

  @override
  String get createPageSettingsDropdownMiniumLiquidityLowWarning =>
      'Low minimum TVL can lead to misleading yields.';

  @override
  String get appSettingsDropdownTestnetMode => 'Testnet Mode';

  @override
  String get previewDepositModalSlippageCheckErrorMessage =>
      'Slippage Check! Please try increasing your slippage for this transaction';

  @override
  String get createPageTitle => 'New Position';

  @override
  String get tvl => 'TVL';

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
