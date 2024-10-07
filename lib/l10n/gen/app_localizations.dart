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

  /// No description provided for @tokenSelectorModalErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We hit a snag loading your token list. Give it another go, and if it keeps happening, feel free to reach us'**
  String get tokenSelectorModalErrorDescription;

  /// No description provided for @tokenSelectorModalSearchErrorDescription.
  ///
  /// In en, this message translates to:
  /// **'We hit a snag while searching for a token matching {searchedTerm}. Give it another go, and if it keeps happening, feel free to reach us'**
  String tokenSelectorModalSearchErrorDescription(String searchedTerm);

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
  String positionsPageNoPositionsInNetwork(String network);

  /// Dynamically shows 'Hide' or 'Show' based on the isHidden boolean.
  ///
  /// In en, this message translates to:
  /// **'{isHidden, select, true {Show} false {Hide} other {Show/Hide}} closed positions'**
  String positionsPageShowHideClosedPositions(String isHidden);

  /// No description provided for @positionsPageNoPositionsInNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'It looks like you don’t have any positions in {network} yet.\nGo ahead and create one to get started!'**
  String positionsPageNoPositionsInNetworkDescription(String network);

  /// No description provided for @positionCardTokenPerToken.
  ///
  /// In en, this message translates to:
  /// **'{token0Qtd} {token0Symbol} per {token1Symbol}'**
  String positionCardTokenPerToken(
      String token0Qtd, String token0Symbol, String token1Symbol);

  /// No description provided for @positionsPageMyPositions.
  ///
  /// In en, this message translates to:
  /// **'My Positions'**
  String get positionsPageMyPositions;

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

  /// No description provided for @tokenA.
  ///
  /// In en, this message translates to:
  /// **'Token A'**
  String get tokenA;

  /// No description provided for @tokenB.
  ///
  /// In en, this message translates to:
  /// **'Token B'**
  String get tokenB;

  /// No description provided for @createPageTitle.
  ///
  /// In en, this message translates to:
  /// **'New Position'**
  String get createPageTitle;

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
      'that was used.');
}
