import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @yieldCardNetworkTooltipDescription.
  ///
  /// In en, this message translates to:
  /// **'This pool is at {network}'**
  String yieldCardNetworkTooltipDescription({required String network});

  /// No description provided for @twentyFourHours.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get twentyFourHours;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @weekCompact.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get weekCompact;

  /// No description provided for @appFooterTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get appFooterTermsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @appFooterContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get appFooterContactUs;

  /// No description provided for @appCookiesConsentWidgetDescription.
  ///
  /// In en, this message translates to:
  /// **'We use cookies to ensure that we give you the best experience on our app. By continuing to use Zup Protocol, you agree to our'**
  String get appCookiesConsentWidgetDescription;

  /// No description provided for @appFooterDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get appFooterDocs;

  /// No description provided for @appFooterFAQ.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get appFooterFAQ;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @depositPageShowingOnlyPoolsWithMoreThan.
  ///
  /// In en, this message translates to:
  /// **'Showing only liquidity pools with more than {minLiquidity}.'**
  String depositPageShowingOnlyPoolsWithMoreThan({
    required String minLiquidity,
  });

  /// No description provided for @depositPageShowingAllPools.
  ///
  /// In en, this message translates to:
  /// **'Showing all liquidity pools.'**
  String get depositPageShowingAllPools;

  /// No description provided for @depositPageSearchAllPools.
  ///
  /// In en, this message translates to:
  /// **'Search all pools?'**
  String get depositPageSearchAllPools;

  /// No description provided for @depositPageSearchOnlyForPoolsWithMorethan.
  ///
  /// In en, this message translates to:
  /// **'Search only for pools with more than {minLiquidity}?'**
  String depositPageSearchOnlyForPoolsWithMorethan({
    required String minLiquidity,
  });

  /// No description provided for @depositPageTrySearchAllPools.
  ///
  /// In en, this message translates to:
  /// **'Try search all pools?'**
  String get depositPageTrySearchAllPools;

  /// No description provided for @depositPageMinLiquiditySearchAlert.
  ///
  /// In en, this message translates to:
  /// **'You’ve set the search to only show pools with more than {minLiquidity}.'**
  String depositPageMinLiquiditySearchAlert({required String minLiquidity});

  /// No description provided for @slippageExplanation.
  ///
  /// In en, this message translates to:
  /// **'Slippage protects you by reverting the transaction if the price changes unfavorably beyond the percentage. This is necessary to prevent losses while adding liquidity'**
  String get slippageExplanation;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @depositSettingsDropdownChildHighSlippageWarningText.
  ///
  /// In en, this message translates to:
  /// **'High slippage can lead to Front Running and losses. Be careful! '**
  String get depositSettingsDropdownChildHighSlippageWarningText;

  /// No description provided for @whatsThisQuestionText.
  ///
  /// In en, this message translates to:
  /// **'What\'s this?'**
  String get whatsThisQuestionText;

  /// No description provided for @depositSettingsDropdownChildTransactionDeadlineExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your transaction will be reverted if it is pending for more than this amount of time'**
  String get depositSettingsDropdownChildTransactionDeadlineExplanation;

  /// No description provided for @depositSettingsDropdownTransactionDeadline.
  ///
  /// In en, this message translates to:
  /// **'Transaction Deadline'**
  String get depositSettingsDropdownTransactionDeadline;

  /// No description provided for @depositPagePercentSlippage.
  ///
  /// In en, this message translates to:
  /// **'{valuePercent} Slippage'**
  String depositPagePercentSlippage({required String valuePercent});

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @twentyFourHoursCompact.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get twentyFourHoursCompact;

  /// No description provided for @monthCompact.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get monthCompact;

  /// No description provided for @threeMonthsCompact.
  ///
  /// In en, this message translates to:
  /// **'90d'**
  String get threeMonthsCompact;

  /// No description provided for @depositSettingsDropdownChildMaxSlippage.
  ///
  /// In en, this message translates to:
  /// **'Max Slippage'**
  String get depositSettingsDropdownChildMaxSlippage;

  /// No description provided for @depositPageDepositSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositPageDepositSectionTitle;

  /// No description provided for @previewDepositModalWaitingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Waiting Transaction'**
  String get previewDepositModalWaitingTransaction;

  /// No description provided for @previewDepositModalApprovingToken.
  ///
  /// In en, this message translates to:
  /// **'Approving {tokenSymbol}'**
  String previewDepositModalApprovingToken({required String tokenSymbol});

  /// No description provided for @previewDepositModalDepositingIntoPool.
  ///
  /// In en, this message translates to:
  /// **'Depositing into {baseTokenSymbol}/{quoteTokenSymbol} pool'**
  String previewDepositModalDepositingIntoPool({
    required String baseTokenSymbol,
    required String quoteTokenSymbol,
  });

  /// No description provided for @previewDepositModalApproveToken.
  ///
  /// In en, this message translates to:
  /// **'Approve {tokenSymbol}'**
  String previewDepositModalApproveToken({required String tokenSymbol});

  /// No description provided for @previewDepositModalDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get previewDepositModalDeposit;

  /// No description provided for @previewDepositModalError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get previewDepositModalError;

  /// No description provided for @previewDepositModalCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get previewDepositModalCurrentPrice;

  /// No description provided for @depositPageDepositSectionTokenNotNeeded.
  ///
  /// In en, this message translates to:
  /// **'{tokenSymbol} is not necessary for your selected range'**
  String depositPageDepositSectionTokenNotNeeded({required String tokenSymbol});

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewDepositModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview Deposit'**
  String get previewDepositModalTitle;

  /// No description provided for @previewDepositModalWaitingTransactionSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Waiting transaction to be confirmed. '**
  String get previewDepositModalWaitingTransactionSnackBarMessage;

  /// No description provided for @previewDepositModalApproveSuccessSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'{tokenSymbol} approved successfully. '**
  String previewDepositModalApproveSuccessSnackBarMessage({
    required String tokenSymbol,
  });

  /// No description provided for @previewDepositModalMyPosition.
  ///
  /// In en, this message translates to:
  /// **'My Position'**
  String get previewDepositModalMyPosition;

  /// No description provided for @previewDepositModalOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Out of Range'**
  String get previewDepositModalOutOfRange;

  /// No description provided for @previewDepositModalInRange.
  ///
  /// In en, this message translates to:
  /// **'In Range'**
  String get previewDepositModalInRange;

  /// No description provided for @previewDepositModalProtocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get previewDepositModalProtocol;

  /// No description provided for @previewDepositModalNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get previewDepositModalNetwork;

  /// No description provided for @previewDepositModalYearlyYield.
  ///
  /// In en, this message translates to:
  /// **'Yearly Yield'**
  String get previewDepositModalYearlyYield;

  /// No description provided for @previewDepositModalTransactionErrorSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Transaction Failed. Please try again, if the problem persists, '**
  String get previewDepositModalTransactionErrorSnackBarMessage;

  /// No description provided for @previewDepositModalTransactionErrorSnackBarHelperButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get previewDepositModalTransactionErrorSnackBarHelperButtonTitle;

  /// No description provided for @previewDepositModalDepositSuccessSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully Deposited into the {baseTokenSymbol}/{quoteTokenSymbol} Pool at {protocol}. '**
  String previewDepositModalDepositSuccessSnackBarMessage({
    required String baseTokenSymbol,
    required String quoteTokenSymbol,
    required String protocol,
  });

  /// No description provided for @yieldCardTimeFrameBest.
  ///
  /// In en, this message translates to:
  /// **'{timeFrame} best'**
  String yieldCardTimeFrameBest({required String timeFrame});

  /// No description provided for @yieldCardThisPoolIsAtNetwork.
  ///
  /// In en, this message translates to:
  /// **'This pool is at {network}'**
  String yieldCardThisPoolIsAtNetwork({required String network});

  /// No description provided for @yieldCardYearlyYield.
  ///
  /// In en, this message translates to:
  /// **'Yearly Yield'**
  String get yieldCardYearlyYield;

  /// No description provided for @yieldCardVisitProtocol.
  ///
  /// In en, this message translates to:
  /// **'Visit {protocolName}'**
  String yieldCardVisitProtocol({required String protocolName});

  /// No description provided for @yieldCardAverageYieldYearly.
  ///
  /// In en, this message translates to:
  /// **'Average Yearly Yield'**
  String get yieldCardAverageYieldYearly;

  /// No description provided for @previewDepositModalDepositSuccessSnackBarHelperButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'View Transaction'**
  String get previewDepositModalDepositSuccessSnackBarHelperButtonTitle;

  /// No description provided for @previewDepositModalApproveSuccessSnackBarHelperButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'View Transaction'**
  String get previewDepositModalApproveSuccessSnackBarHelperButtonTitle;

  /// No description provided for @previewDepositModalWaitingTransactionSnackBarHelperButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'View on Explorer'**
  String get previewDepositModalWaitingTransactionSnackBarHelperButtonTitle;

  /// No description provided for @depositPageInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Invalid range'**
  String get depositPageInvalidRange;

  /// No description provided for @depositPageMinRangeOutOfRangeWarningText.
  ///
  /// In en, this message translates to:
  /// **'You will not earn fees until the market price move up into your range'**
  String get depositPageMinRangeOutOfRangeWarningText;

  /// No description provided for @depositPageMaxRangeOutOfRangeWarningText.
  ///
  /// In en, this message translates to:
  /// **'You will not earn fees until the market price move down into your range'**
  String get depositPageMaxRangeOutOfRangeWarningText;

  /// No description provided for @depositPageInvalidRangeErrorText.
  ///
  /// In en, this message translates to:
  /// **'Max range should be greater than min range'**
  String get depositPageInvalidRangeErrorText;

  /// No description provided for @previewDepositModalMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Min Price'**
  String get previewDepositModalMinPrice;

  /// No description provided for @previewDepositModalMaxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max Price'**
  String get previewDepositModalMaxPrice;

  /// No description provided for @rangeSelectorMinRange.
  ///
  /// In en, this message translates to:
  /// **'Min Range'**
  String get rangeSelectorMinRange;

  /// No description provided for @rangeSelectorMaxRange.
  ///
  /// In en, this message translates to:
  /// **'Max Range'**
  String get rangeSelectorMaxRange;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @exchangesFilterDropdownButtonDropdownClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get exchangesFilterDropdownButtonDropdownClearAll;

  /// No description provided for @exchangesFilterDropdownButtonDropdownSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get exchangesFilterDropdownButtonDropdownSelectAll;

  /// No description provided for @exchangesFilterDropdownButtonDropdownSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get exchangesFilterDropdownButtonDropdownSearchHint;

  /// No description provided for @exchangesFilterDropdownButtonDropdownNotFoundStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get exchangesFilterDropdownButtonDropdownNotFoundStateTitle;

  /// No description provided for @exchangesFilterDropdownButtonDropdownNotFoundStateDescription.
  ///
  /// In en, this message translates to:
  /// **'No supported exchanges found with this name'**
  String get exchangesFilterDropdownButtonDropdownNotFoundStateDescription;

  /// No description provided for @exchangesFilterDropdownButtonErrorSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Uh-oh! Something went wrong loading the exchanges. Please try refreshing the page.'**
  String get exchangesFilterDropdownButtonErrorSnackBarMessage;

  /// No description provided for @exchangesFilterDropdownButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Exchanges'**
  String get exchangesFilterDropdownButtonTitle;

  /// No description provided for @exchangesFilterDropdownButtonTitleNumered.
  ///
  /// In en, this message translates to:
  /// **'Exchanges ({exchangesCount})'**
  String exchangesFilterDropdownButtonTitleNumered({
    required String exchangesCount,
  });

  /// No description provided for @createPageSelectTokensStageTokenA.
  ///
  /// In en, this message translates to:
  /// **'Token A'**
  String get createPageSelectTokensStageTokenA;

  /// No description provided for @createPageSelectTokensStageTokenB.
  ///
  /// In en, this message translates to:
  /// **'Token B'**
  String get createPageSelectTokensStageTokenB;

  /// No description provided for @createPageSelectTokensStageSearchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search Settings'**
  String get createPageSelectTokensStageSearchSettings;

  /// No description provided for @depositPageLoadingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Matching Tokens...'**
  String get depositPageLoadingStep1Title;

  /// No description provided for @depositPageLoadingStep1Description.
  ///
  /// In en, this message translates to:
  /// **'Pairing Token A and Token B to kick off the search for top yields!'**
  String get depositPageLoadingStep1Description;

  /// No description provided for @depositPageLoadingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Pair hunting…'**
  String get depositPageLoadingStep2Title;

  /// No description provided for @depositPageLoadingStep2Description.
  ///
  /// In en, this message translates to:
  /// **'Searching through more than a thousand pool combos… so you don\'t have to'**
  String get depositPageLoadingStep2Description;

  /// No description provided for @depositPageLoadingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Yield optimizer at work…'**
  String get depositPageLoadingStep3Title;

  /// No description provided for @depositPageLoadingStep3Description.
  ///
  /// In en, this message translates to:
  /// **'Scanning pools, calculating returns, and filtering the noise'**
  String get depositPageLoadingStep3Description;

  /// No description provided for @depositPageBestYieldsIn.
  ///
  /// In en, this message translates to:
  /// **'Best Yields in'**
  String get depositPageBestYieldsIn;

  /// No description provided for @depositPageLoadingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Organizing the best pools for you…'**
  String get depositPageLoadingStep4Title;

  /// No description provided for @depositPageLoadingStep4Description.
  ///
  /// In en, this message translates to:
  /// **'Hang tight, we\'re filtering and organizing the best pools for you'**
  String get depositPageLoadingStep4Description;

  /// No description provided for @depositPageErrorStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong!'**
  String get depositPageErrorStateTitle;

  /// No description provided for @depositPageErrorStateDescription.
  ///
  /// In en, this message translates to:
  /// **'We ran into a issue while trying to find the best pool. Give it another shot, and if it keeps happening, don’t hesitate to reach out to us!'**
  String get depositPageErrorStateDescription;

  /// No description provided for @depositPageEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No Pools Found'**
  String get depositPageEmptyStateTitle;

  /// No description provided for @depositPageEmptyStateDescription.
  ///
  /// In en, this message translates to:
  /// **'Seems like that there are no pools matching your defined settings at the moment. Would you like to either change your settings or try another combination?'**
  String get depositPageEmptyStateDescription;

  /// No description provided for @depositPageEmptyStateHelpButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Go Back to New Position'**
  String get depositPageEmptyStateHelpButtonTitle;

  /// No description provided for @depositPageBackButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Pair'**
  String get depositPageBackButtonTitle;

  /// No description provided for @depositPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add liquidity'**
  String get depositPageTitle;

  /// No description provided for @depositPageTimeFrameTooltipMessage.
  ///
  /// In en, this message translates to:
  /// **'Each time frame shows yields based on past performance. Shorter terms (24h, 7d) reflect recent trends and may suit short-term strategies. Longer terms (30d, 90d) offer a broader performance view for long-term decisions.'**
  String get depositPageTimeFrameTooltipMessage;

  /// No description provided for @depositPageTimeFrameTooltipHelperButtonTitle.
  ///
  /// In en, this message translates to:
  /// **' Learn more'**
  String get depositPageTimeFrameTooltipHelperButtonTitle;

  /// No description provided for @depositPageTimeFrameTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred time frame'**
  String get depositPageTimeFrameTitle;

  /// No description provided for @depositPageNoYieldSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a yield to deposit'**
  String get depositPageNoYieldSelectedTitle;

  /// No description provided for @depositPageNoYieldSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick any yield card above and dive into depositing your liquidity!'**
  String get depositPageNoYieldSelectedDescription;

  /// No description provided for @depositPageRangeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Range'**
  String get depositPageRangeSectionTitle;

  /// No description provided for @depositPageRangeSectionFullRange.
  ///
  /// In en, this message translates to:
  /// **'Full Range'**
  String get depositPageRangeSectionFullRange;

  /// No description provided for @depositPageInvalidTokenAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount for {tokenSymbol}'**
  String depositPageInvalidTokenAmount({required String tokenSymbol});

  /// No description provided for @depositPageInsufficientTokenBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient {tokenSymbol} balance'**
  String depositPageInsufficientTokenBalance({required String tokenSymbol});

  /// No description provided for @depositPagePleaseEnterAmountForToken.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount for {tokenSymbol}'**
  String depositPagePleaseEnterAmountForToken({required String tokenSymbol});

  /// No description provided for @depositPageDeposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositPageDeposit;

  /// No description provided for @connectYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect your wallet'**
  String get connectYourWallet;

  /// No description provided for @tokenSelectorModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a token'**
  String get tokenSelectorModalTitle;

  /// No description provided for @tokenSelectorModalTokenGroups.
  ///
  /// In en, this message translates to:
  /// **'Token Groups'**
  String get tokenSelectorModalTokenGroups;

  /// No description provided for @tokenSelectorModalTokenGroupsTooltipMessage.
  ///
  /// In en, this message translates to:
  /// **'Token groups let you search pools using multiple tokens in one go. Think of them like batch queries, want all USD stablecoins? Pick the group and we\'ll surface every relevant pool. You can also match groups against single tokens or other groups to discover deep liquidity.'**
  String get tokenSelectorModalTokenGroupsTooltipMessage;

  /// No description provided for @tokenSelectorModalDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a token from our list or search by symbol or address to build your ideal liquidity pool!'**
  String get tokenSelectorModalDescription;

  /// No description provided for @tokenSelectorModalSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search token or paste address'**
  String get tokenSelectorModalSearchTitle;

  /// No description provided for @tokenSelectorModalSearchTitleAllNetworks.
  ///
  /// In en, this message translates to:
  /// **'Search token by symbol or name'**
  String get tokenSelectorModalSearchTitleAllNetworks;

  /// No description provided for @tokenSelectorModalSearchAlertForAllNetworks.
  ///
  /// In en, this message translates to:
  /// **'When ‘All Networks’ is selected, you can only search by name or symbol. To search by address as well, please select a specific network'**
  String get tokenSelectorModalSearchAlertForAllNetworks;

  /// No description provided for @tokenSelectorModalErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We hit a snag loading your token list. Give it another go, and if it keeps happening, feel free to reach us'**
  String get tokenSelectorModalErrorDescription;

  /// No description provided for @tokenSelectorModalSearchErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We hit a snag while searching for a token matching {searchedTerm}. Give it another go, and if it keeps happening, feel free to reach us'**
  String tokenSelectorModalSearchErrorDescription({
    required String searchedTerm,
  });

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for'**
  String get noResultsFor;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @popularTokens.
  ///
  /// In en, this message translates to:
  /// **'Popular Tokens'**
  String get popularTokens;

  /// No description provided for @connectMyWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect My Wallet'**
  String get connectMyWallet;

  /// No description provided for @connectWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect Wallet'**
  String get connectWallet;

  /// No description provided for @positionsPageNotConnectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Wallet not connected. Please connect your\nwallet to view your positions'**
  String get positionsPageNotConnectedDescription;

  /// No description provided for @positionsPageNoPositionsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any positions yet'**
  String get positionsPageNoPositionsTitle;

  /// No description provided for @positionsPageNoPositionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Hm… It looks like you don’t have any positions yet.\nWant to create one?'**
  String get positionsPageNoPositionsDescription;

  /// No description provided for @newPosition.
  ///
  /// In en, this message translates to:
  /// **'New Position'**
  String get newPosition;

  /// No description provided for @createNewPosition.
  ///
  /// In en, this message translates to:
  /// **'Create new position'**
  String get createNewPosition;

  /// No description provided for @positionCardMin.
  ///
  /// In en, this message translates to:
  /// **'Min: '**
  String get positionCardMin;

  /// No description provided for @positionCardMax.
  ///
  /// In en, this message translates to:
  /// **'Max: '**
  String get positionCardMax;

  /// No description provided for @positionCardLiquidity.
  ///
  /// In en, this message translates to:
  /// **'Liquidity: '**
  String get positionCardLiquidity;

  /// No description provided for @positionCardUnclaimedFees.
  ///
  /// In en, this message translates to:
  /// **'Unclaimed fees: '**
  String get positionCardUnclaimedFees;

  /// No description provided for @positionCardViewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get positionCardViewMore;

  /// No description provided for @positionsPageNoPositionsInNetwork.
  ///
  /// In en, this message translates to:
  /// **'No positions in {network}'**
  String positionsPageNoPositionsInNetwork({required String network});

  /// Dynamically shows 'Hide' or 'Show' based on the isHidden boolean.
  ///
  /// In en, this message translates to:
  /// **'{isHidden, select, true {Show} false {Hide} other {Show/Hide}} closed positions'**
  String positionsPageShowHideClosedPositions({required String isHidden});

  /// No description provided for @positionsPageNoPositionsInNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'It looks like you don’t have any positions in {network} yet.\nGo ahead and create one to get started!'**
  String positionsPageNoPositionsInNetworkDescription({
    required String network,
  });

  /// No description provided for @positionCardTokenPerToken.
  ///
  /// In en, this message translates to:
  /// **'{token0Qtd} {token0Symbol} per {token1Symbol}'**
  String positionCardTokenPerToken({
    required String token0Qtd,
    required String token0Symbol,
    required String token1Symbol,
  });

  /// No description provided for @positionsPageMyPositions.
  ///
  /// In en, this message translates to:
  /// **'My Positions'**
  String get positionsPageMyPositions;

  /// No description provided for @appHeaderMyPositions.
  ///
  /// In en, this message translates to:
  /// **'My Positions (Soon)'**
  String get appHeaderMyPositions;

  /// No description provided for @appHeaderNewPosition.
  ///
  /// In en, this message translates to:
  /// **'New Position'**
  String get appHeaderNewPosition;

  /// No description provided for @appBottomNavigationBarMyPositions.
  ///
  /// In en, this message translates to:
  /// **'My Positions (Soon)'**
  String get appBottomNavigationBarMyPositions;

  /// No description provided for @appBottomNavigationBarNewPosition.
  ///
  /// In en, this message translates to:
  /// **'New Position'**
  String get appBottomNavigationBarNewPosition;

  /// No description provided for @positionsPageCantFindAPosition.
  ///
  /// In en, this message translates to:
  /// **'Can’t find a position? Try switching the app’s network to \"All Networks\" or reload the page'**
  String get positionsPageCantFindAPosition;

  /// No description provided for @somethingWhenWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWhenWrong;

  /// No description provided for @positionsPageErrorStateDescription.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading your positions.\nPlease try again. If the issue persists, feel free to contact us'**
  String get positionsPageErrorStateDescription;

  /// No description provided for @positionStatusInRange.
  ///
  /// In en, this message translates to:
  /// **'In Range'**
  String get positionStatusInRange;

  /// No description provided for @positionStatusOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Out of Range'**
  String get positionStatusOutOfRange;

  /// No description provided for @positionStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get positionStatusClosed;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @selectToken.
  ///
  /// In en, this message translates to:
  /// **'Select Token'**
  String get selectToken;

  /// No description provided for @token0.
  ///
  /// In en, this message translates to:
  /// **'Token A'**
  String get token0;

  /// No description provided for @token1.
  ///
  /// In en, this message translates to:
  /// **'Token B'**
  String get token1;

  /// No description provided for @depositSuccessModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Successful!'**
  String get depositSuccessModalTitle;

  /// No description provided for @depositSuccessModalDescriptionPart1.
  ///
  /// In en, this message translates to:
  /// **'You have successfully deposited into'**
  String get depositSuccessModalDescriptionPart1;

  /// No description provided for @depositSuccessModalDescriptionPart2.
  ///
  /// In en, this message translates to:
  /// **'Pool at'**
  String get depositSuccessModalDescriptionPart2;

  /// No description provided for @depositSuccessModalDescriptionPart3.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get depositSuccessModalDescriptionPart3;

  /// No description provided for @previewDepositModalCubitDepositingSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Depositing into {token0Symbol}/{token1Symbol} Pool...'**
  String previewDepositModalCubitDepositingSnackBarMessage({
    required String token0Symbol,
    required String token1Symbol,
  });

  /// No description provided for @previewDepositModalCubitApprovingSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Approving...'**
  String get previewDepositModalCubitApprovingSnackBarMessage;

  /// No description provided for @previewDepositModalCubitApprovedSnackBarMessage.
  ///
  /// In en, this message translates to:
  /// **'Successfully approved {tokenSymbol}'**
  String previewDepositModalCubitApprovedSnackBarMessage({
    required String tokenSymbol,
  });

  /// No description provided for @depositSuccessModalViewPositionOnDEX.
  ///
  /// In en, this message translates to:
  /// **'View Position on {dexName}'**
  String depositSuccessModalViewPositionOnDEX({required String dexName});

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @depositPageDepositWithNativeToken.
  ///
  /// In en, this message translates to:
  /// **'Deposit with Native {tokenSymbol}'**
  String depositPageDepositWithNativeToken({required String tokenSymbol});

  /// No description provided for @createPageSettingsDropdownMinimumLiquidity.
  ///
  /// In en, this message translates to:
  /// **'Minimum Pool Liquidity'**
  String get createPageSettingsDropdownMinimumLiquidity;

  /// No description provided for @createPageSettingsDropdownAllowedPoolTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed Pool Types'**
  String get createPageSettingsDropdownAllowedPoolTypes;

  /// No description provided for @createPageSettingsDropdownAllowedPoolTypesDescription.
  ///
  /// In en, this message translates to:
  /// **'Filter the types of liquidity pools to include in your search'**
  String get createPageSettingsDropdownAllowedPoolTypesDescription;

  /// No description provided for @createPageSettingsDropdownMinimumLiquidityExplanation.
  ///
  /// In en, this message translates to:
  /// **'Filter pools by minimum liquidity. We’ll exclude pools with less liquidity than specified, as low Liquidity can lead to misleading yields. This helps you find more reliable opportunities'**
  String get createPageSettingsDropdownMinimumLiquidityExplanation;

  /// No description provided for @createPageSettingsDropdownMiniumLiquidityLowWarning.
  ///
  /// In en, this message translates to:
  /// **'Low minimum TVL can lead to misleading yields.'**
  String get createPageSettingsDropdownMiniumLiquidityLowWarning;

  /// No description provided for @appSettingsDropdownTestnetMode.
  ///
  /// In en, this message translates to:
  /// **'Testnet Mode'**
  String get appSettingsDropdownTestnetMode;

  /// No description provided for @previewDepositModalSlippageCheckErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Slippage Check! Please try increasing your slippage for this transaction'**
  String get previewDepositModalSlippageCheckErrorMessage;

  /// No description provided for @previewDepositModalAutoSlippageCheckErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Strong market movement! Slippage exceeded. Try again or adjust tolerance.'**
  String get previewDepositModalAutoSlippageCheckErrorMessage;

  /// No description provided for @createPageTitle.
  ///
  /// In en, this message translates to:
  /// **'New Position'**
  String get createPageTitle;

  /// No description provided for @tvl.
  ///
  /// In en, this message translates to:
  /// **'TVL'**
  String get tvl;

  /// No description provided for @createPageShowMeTheMoney.
  ///
  /// In en, this message translates to:
  /// **'Show me the money!'**
  String get createPageShowMeTheMoney;

  /// No description provided for @createPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Ready to dive in? First, pick the dynamic duo of tokens you want to team up in the pool. Just choose your pair right below and you’re set to make some magic!'**
  String get createPageDescription;

  /// No description provided for @letsGiveItAnotherGo.
  ///
  /// In en, this message translates to:
  /// **'Let’s give it another go, because why not?'**
  String get letsGiveItAnotherGo;

  /// No description provided for @letsGiveItAnotherShot.
  ///
  /// In en, this message translates to:
  /// **'Let’s give it another shot'**
  String get letsGiveItAnotherShot;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
