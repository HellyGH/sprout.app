import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bg'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Watch your money grow.'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get navGoals;

  /// No description provided for @navYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navYou;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get commonKeep;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get commonNew;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authFieldName;

  /// No description provided for @authFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authFieldEmail;

  /// No description provided for @authFieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authFieldPassword;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get authNameRequired;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look quite right — try again 🌱'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password needs at least 6 characters'**
  String get authPasswordTooShort;

  /// No description provided for @authEmailLooksOff.
  ///
  /// In en, this message translates to:
  /// **'Email looks off'**
  String get authEmailLooksOff;

  /// No description provided for @authPasswordRuleSignup.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordRuleSignup;

  /// No description provided for @authAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email'**
  String get authAccountExists;

  /// No description provided for @authNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching account — check your details'**
  String get authNoMatch;

  /// No description provided for @onbWelcomeGreetingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Hey there,'**
  String get onbWelcomeGreetingGeneric;

  /// No description provided for @onbWelcomeGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Hey {name},'**
  String onbWelcomeGreetingNamed(String name);

  /// No description provided for @onbWelcomeIntro.
  ///
  /// In en, this message translates to:
  /// **'I\'m Sprout.'**
  String get onbWelcomeIntro;

  /// No description provided for @onbWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s grow your money — together.'**
  String get onbWelcomeSubtitle;

  /// No description provided for @onbLetsGrow.
  ///
  /// In en, this message translates to:
  /// **'Let\'s grow 🌱'**
  String get onbLetsGrow;

  /// No description provided for @onbBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your monthly budget'**
  String get onbBudgetTitle;

  /// No description provided for @onbBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry — you can change this anytime.'**
  String get onbBudgetSubtitle;

  /// No description provided for @onbBudgetCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get onbBudgetCurrency;

  /// No description provided for @onbBudgetPerDay.
  ///
  /// In en, this message translates to:
  /// **'That\'s about {amount}/day.'**
  String onbBudgetPerDay(String amount);

  /// No description provided for @onbGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What are you saving for?'**
  String get onbGoalTitle;

  /// No description provided for @onbGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one to start. You can add more later.'**
  String get onbGoalSubtitle;

  /// No description provided for @onbGoalPresetTokyo.
  ///
  /// In en, this message translates to:
  /// **'Tokyo trip'**
  String get onbGoalPresetTokyo;

  /// No description provided for @onbGoalPresetMacbook.
  ///
  /// In en, this message translates to:
  /// **'MacBook'**
  String get onbGoalPresetMacbook;

  /// No description provided for @onbGoalPresetEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get onbGoalPresetEmergency;

  /// No description provided for @onbGoalPresetConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert'**
  String get onbGoalPresetConcert;

  /// No description provided for @onbGoalCreateOwn.
  ///
  /// In en, this message translates to:
  /// **'Or create your own'**
  String get onbGoalCreateOwn;

  /// No description provided for @onbGoalCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom goal'**
  String get onbGoalCustom;

  /// No description provided for @onbGoalNameField.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get onbGoalNameField;

  /// No description provided for @onbGoalTargetField.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get onbGoalTargetField;

  /// No description provided for @onbGoalDeadlineHint.
  ///
  /// In en, this message translates to:
  /// **'Deadline (optional)'**
  String get onbGoalDeadlineHint;

  /// No description provided for @onbQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick personality check'**
  String get onbQuizTitle;

  /// No description provided for @onbQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps me tone-tune nudges. No wrong answers.'**
  String get onbQuizSubtitle;

  /// No description provided for @onbQuizResult.
  ///
  /// In en, this message translates to:
  /// **'You\'re a {type} — got it. I\'ll keep that in mind.'**
  String onbQuizResult(String type);

  /// No description provided for @personalitySaver.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get personalitySaver;

  /// No description provided for @personalityTreater.
  ///
  /// In en, this message translates to:
  /// **'Treater'**
  String get personalityTreater;

  /// No description provided for @personalityGoalChaser.
  ///
  /// In en, this message translates to:
  /// **'Goal-chaser'**
  String get personalityGoalChaser;

  /// No description provided for @personalityImpulse.
  ///
  /// In en, this message translates to:
  /// **'Impulse'**
  String get personalityImpulse;

  /// No description provided for @onbQuizQ1.
  ///
  /// In en, this message translates to:
  /// **'A €40 hoodie catches your eye. You…'**
  String get onbQuizQ1;

  /// No description provided for @onbQuizQ1Saver.
  ///
  /// In en, this message translates to:
  /// **'Walk on — saving for something better'**
  String get onbQuizQ1Saver;

  /// No description provided for @onbQuizQ1Treater.
  ///
  /// In en, this message translates to:
  /// **'Buy it. You earned it.'**
  String get onbQuizQ1Treater;

  /// No description provided for @onbQuizQ1GoalChaser.
  ///
  /// In en, this message translates to:
  /// **'Add it to a \'maybe\' list, decide tomorrow'**
  String get onbQuizQ1GoalChaser;

  /// No description provided for @onbQuizQ1Impulse.
  ///
  /// In en, this message translates to:
  /// **'It\'s already in your cart 😅'**
  String get onbQuizQ1Impulse;

  /// No description provided for @onbQuizQ2.
  ///
  /// In en, this message translates to:
  /// **'Friday night?'**
  String get onbQuizQ2;

  /// No description provided for @onbQuizQ2Saver.
  ///
  /// In en, this message translates to:
  /// **'Cozy in — popcorn + film'**
  String get onbQuizQ2Saver;

  /// No description provided for @onbQuizQ2Treater.
  ///
  /// In en, this message translates to:
  /// **'Dinner out with mates'**
  String get onbQuizQ2Treater;

  /// No description provided for @onbQuizQ2GoalChaser.
  ///
  /// In en, this message translates to:
  /// **'Free event with friends'**
  String get onbQuizQ2GoalChaser;

  /// No description provided for @onbQuizQ2Impulse.
  ///
  /// In en, this message translates to:
  /// **'See where the night takes you'**
  String get onbQuizQ2Impulse;

  /// No description provided for @onbQuizQ3.
  ///
  /// In en, this message translates to:
  /// **'Your favourite app pings: 50% off!'**
  String get onbQuizQ3;

  /// No description provided for @onbQuizQ3Saver.
  ///
  /// In en, this message translates to:
  /// **'Mute it'**
  String get onbQuizQ3Saver;

  /// No description provided for @onbQuizQ3Treater.
  ///
  /// In en, this message translates to:
  /// **'Browse, probably buy'**
  String get onbQuizQ3Treater;

  /// No description provided for @onbQuizQ3GoalChaser.
  ///
  /// In en, this message translates to:
  /// **'Buy only what you\'d planned'**
  String get onbQuizQ3GoalChaser;

  /// No description provided for @onbQuizQ3Impulse.
  ///
  /// In en, this message translates to:
  /// **'Open it immediately'**
  String get onbQuizQ3Impulse;

  /// No description provided for @onbQuizQ4.
  ///
  /// In en, this message translates to:
  /// **'How often do you check your balance?'**
  String get onbQuizQ4;

  /// No description provided for @onbQuizQ4Daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get onbQuizQ4Daily;

  /// No description provided for @onbQuizQ4Weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get onbQuizQ4Weekly;

  /// No description provided for @onbQuizQ4Monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get onbQuizQ4Monthly;

  /// No description provided for @onbQuizQ4Decline.
  ///
  /// In en, this message translates to:
  /// **'Only when the card declines 😬'**
  String get onbQuizQ4Decline;

  /// No description provided for @onbQuizQ5.
  ///
  /// In en, this message translates to:
  /// **'An unexpected €100 lands in your account.'**
  String get onbQuizQ5;

  /// No description provided for @onbQuizQ5Saver.
  ///
  /// In en, this message translates to:
  /// **'Straight to savings'**
  String get onbQuizQ5Saver;

  /// No description provided for @onbQuizQ5Treater.
  ///
  /// In en, this message translates to:
  /// **'Treat yourself'**
  String get onbQuizQ5Treater;

  /// No description provided for @onbQuizQ5GoalChaser.
  ///
  /// In en, this message translates to:
  /// **'Boost a goal'**
  String get onbQuizQ5GoalChaser;

  /// No description provided for @onbQuizQ5Impulse.
  ///
  /// In en, this message translates to:
  /// **'It\'s gone by Tuesday'**
  String get onbQuizQ5Impulse;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get homeWelcomeBack;

  /// No description provided for @homeFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get homeFriend;

  /// No description provided for @homeNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications…'**
  String get homeNoNotifications;

  /// No description provided for @homeSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get homeSpending;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeNoCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get homeNoCategoriesTitle;

  /// No description provided for @homeNoCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'Add one in the You tab to start tracking 🌱'**
  String get homeNoCategoriesBody;

  /// No description provided for @homeMarkNoSpend.
  ///
  /// In en, this message translates to:
  /// **'Mark today as no-spend'**
  String get homeMarkNoSpend;

  /// No description provided for @homeLogSpend.
  ///
  /// In en, this message translates to:
  /// **'+ Log a spend'**
  String get homeLogSpend;

  /// No description provided for @homeRemainingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Remaining this month'**
  String get homeRemainingThisMonth;

  /// No description provided for @homeTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get homeTopUp;

  /// No description provided for @homeOfMonthly.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String homeOfMonthly(String amount);

  /// No description provided for @homeSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get homeSelectCurrency;

  /// No description provided for @categoryOfCap.
  ///
  /// In en, this message translates to:
  /// **'of {cap}'**
  String categoryOfCap(String cap);

  /// No description provided for @statsTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get statsTotalSpent;

  /// No description provided for @statsTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get statsTotalExpenses;

  /// No description provided for @statsLast90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get statsLast90Days;

  /// No description provided for @statsHeatmapLess.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get statsHeatmapLess;

  /// No description provided for @statsHeatmapMore.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get statsHeatmapMore;

  /// No description provided for @statsLogsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} log} other{{count} logs}}'**
  String statsLogsCount(int count);

  /// No description provided for @statsDaySummary.
  ///
  /// In en, this message translates to:
  /// **'{amount} across {logs}'**
  String statsDaySummary(String amount, String logs);

  /// No description provided for @statsNoSpendDay.
  ///
  /// In en, this message translates to:
  /// **'No-spend day 🌱'**
  String get statsNoSpendDay;

  /// No description provided for @whatIfTitle.
  ///
  /// In en, this message translates to:
  /// **'What if?'**
  String get whatIfTitle;

  /// No description provided for @whatIfEmpty.
  ///
  /// In en, this message translates to:
  /// **'Set a goal first and Sprout will show how cutting back speeds you up 🌱'**
  String get whatIfEmpty;

  /// No description provided for @whatIfCutByPercent.
  ///
  /// In en, this message translates to:
  /// **'Cut {category} by {percent}% →'**
  String whatIfCutByPercent(String category, int percent);

  /// No description provided for @whatIfSave.
  ///
  /// In en, this message translates to:
  /// **'save '**
  String get whatIfSave;

  /// No description provided for @whatIfPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{amount}/mo'**
  String whatIfPerMonth(String amount);

  /// No description provided for @whatIfReach.
  ///
  /// In en, this message translates to:
  /// **' — reach '**
  String get whatIfReach;

  /// No description provided for @whatIfIn.
  ///
  /// In en, this message translates to:
  /// **' in '**
  String get whatIfIn;

  /// No description provided for @whatIfWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, one{{weeks} week} other{{weeks} weeks}}'**
  String whatIfWeeks(int weeks);

  /// No description provided for @whatIfNoTick.
  ///
  /// In en, this message translates to:
  /// **'. Increase the cut to start ticking down ⏳'**
  String get whatIfNoTick;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sept'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @monthLongJan.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthLongJan;

  /// No description provided for @monthLongFeb.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthLongFeb;

  /// No description provided for @monthLongMar.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthLongMar;

  /// No description provided for @monthLongApr.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthLongApr;

  /// No description provided for @monthLongMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthLongMay;

  /// No description provided for @monthLongJun.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthLongJun;

  /// No description provided for @monthLongJul.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthLongJul;

  /// No description provided for @monthLongAug.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthLongAug;

  /// No description provided for @monthLongSep.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthLongSep;

  /// No description provided for @monthLongOct.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthLongOct;

  /// No description provided for @monthLongNov.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthLongNov;

  /// No description provided for @monthLongDec.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthLongDec;

  /// No description provided for @goalDefaultSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get goalDefaultSavings;

  /// No description provided for @goalDefaultInvest.
  ///
  /// In en, this message translates to:
  /// **'Invest'**
  String get goalDefaultInvest;

  /// No description provided for @goalsHeader.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsHeader;

  /// No description provided for @goalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track what you\'re saving for. Sprout grows with you.'**
  String get goalsSubtitle;

  /// No description provided for @goalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get goalsEmptyTitle;

  /// No description provided for @goalsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Pick something you\'re saving for — even a small one. Sprout will grow alongside.'**
  String get goalsEmptyBody;

  /// No description provided for @goalsAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add a goal'**
  String get goalsAddCta;

  /// No description provided for @goalSetAside.
  ///
  /// In en, this message translates to:
  /// **'Set aside'**
  String get goalSetAside;

  /// No description provided for @goalComplete.
  ///
  /// In en, this message translates to:
  /// **'Goal complete 🎉'**
  String get goalComplete;

  /// No description provided for @goalYouDidIt.
  ///
  /// In en, this message translates to:
  /// **'🎉 You did it!'**
  String get goalYouDidIt;

  /// No description provided for @goalOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String goalOfTarget(String target);

  /// No description provided for @goalToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String goalToGo(String amount);

  /// No description provided for @goalPaceWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, one{~{weeks} week at this rate} other{~{weeks} weeks at this rate}}'**
  String goalPaceWeeks(int weeks);

  /// No description provided for @goalDeadlinePast.
  ///
  /// In en, this message translates to:
  /// **'past deadline'**
  String get goalDeadlinePast;

  /// No description provided for @goalDeadlineToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get goalDeadlineToday;

  /// No description provided for @goalDeadlineDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day left} other{{days} days left}}'**
  String goalDeadlineDaysLeft(int days);

  /// No description provided for @goalDeadlineWeeksLeft.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, one{{weeks} week left} other{{weeks} weeks left}}'**
  String goalDeadlineWeeksLeft(int weeks);

  /// No description provided for @goalDetailHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get goalDetailHistory;

  /// No description provided for @goalDetailContribCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} contribution} other{{count} contributions}}'**
  String goalDetailContribCount(int count);

  /// No description provided for @goalDetailFirstSetAside.
  ///
  /// In en, this message translates to:
  /// **'Set aside your first €5 — Sprout\'s waiting 🌱'**
  String get goalDetailFirstSetAside;

  /// No description provided for @goalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get goalNotFound;

  /// No description provided for @goalSheetNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get goalSheetNewTitle;

  /// No description provided for @goalSheetEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get goalSheetEditTitle;

  /// No description provided for @goalSheetNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalSheetNameField;

  /// No description provided for @goalSheetDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this goal?'**
  String get goalSheetDeleteConfirmTitle;

  /// No description provided for @goalSheetDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Sprout will lose track of \'{name}\'. Set-aside history will go too.'**
  String goalSheetDeleteConfirmBody(String name);

  /// No description provided for @goalSheetNoDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get goalSheetNoDeadline;

  /// No description provided for @goalSheetAddGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get goalSheetAddGoal;

  /// No description provided for @setAsideTitle.
  ///
  /// In en, this message translates to:
  /// **'Set aside for {goal}'**
  String setAsideTitle(String goal);

  /// No description provided for @setAsideToGo.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String setAsideToGo(String amount);

  /// No description provided for @setAsideButtonAmount.
  ///
  /// In en, this message translates to:
  /// **'Set aside {amount} 🌱'**
  String setAsideButtonAmount(String amount);

  /// No description provided for @milestoneComplete.
  ///
  /// In en, this message translates to:
  /// **'Goal complete! 🎉'**
  String get milestoneComplete;

  /// No description provided for @milestonePercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% there!'**
  String milestonePercent(int percent);

  /// No description provided for @milestoneCompleteSub.
  ///
  /// In en, this message translates to:
  /// **'You hit your {goal} goal 🌱'**
  String milestoneCompleteSub(String goal);

  /// No description provided for @milestoneKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going on {goal}'**
  String milestoneKeepGoing(String goal);

  /// No description provided for @youMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get youMonthlyBudget;

  /// No description provided for @youSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get youSpentThisMonth;

  /// No description provided for @youTopUpThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+{amount} extra this month'**
  String youTopUpThisMonth(String amount);

  /// No description provided for @youTopUpAction.
  ///
  /// In en, this message translates to:
  /// **'Top up this month'**
  String get youTopUpAction;

  /// No description provided for @editBudgetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'this becomes your budget from now on 🌱'**
  String get editBudgetSubtitle;

  /// No description provided for @topUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up {month}'**
  String topUpTitle(String month);

  /// No description provided for @topUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'a one-off boost, just for this month 🌱'**
  String get topUpSubtitle;

  /// No description provided for @topUpButton.
  ///
  /// In en, this message translates to:
  /// **'add {amount}'**
  String topUpButton(String amount);

  /// No description provided for @youStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String youStreakLabel(int count);

  /// No description provided for @youStreakLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest: {count, plural, one{{count} day} other{{count} days}}'**
  String youStreakLongest(int count);

  /// No description provided for @youStreakStart.
  ///
  /// In en, this message translates to:
  /// **'Log a spend or mark a no-spend day to start.'**
  String get youStreakStart;

  /// No description provided for @youTalkedOutOf.
  ///
  /// In en, this message translates to:
  /// **'Talked yourself out of'**
  String get youTalkedOutOf;

  /// No description provided for @youCooldownTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooldown timer'**
  String get youCooldownTitle;

  /// No description provided for @youCooldownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'30s breath before any big spend'**
  String get youCooldownSubtitle;

  /// No description provided for @youCooldownTriggerAbove.
  ///
  /// In en, this message translates to:
  /// **'Trigger above'**
  String get youCooldownTriggerAbove;

  /// No description provided for @youAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get youAddCategory;

  /// No description provided for @youLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get youLogOut;

  /// No description provided for @youRoundUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Round-up savings'**
  String get youRoundUpTitle;

  /// No description provided for @youRoundUpNoGoal.
  ///
  /// In en, this message translates to:
  /// **'Add a goal first — round-ups need a destination 🌱'**
  String get youRoundUpNoGoal;

  /// No description provided for @youRoundUpActive.
  ///
  /// In en, this message translates to:
  /// **'Each spend rounds up; spare change → {goal}'**
  String youRoundUpActive(String goal);

  /// No description provided for @youRecurringHeader.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get youRecurringHeader;

  /// No description provided for @youRecurringAutoMonth.
  ///
  /// In en, this message translates to:
  /// **'Auto-logs each month'**
  String get youRecurringAutoMonth;

  /// No description provided for @youRecurringCategoryAutoMonth.
  ///
  /// In en, this message translates to:
  /// **'{category} · auto-logs each month'**
  String youRecurringCategoryAutoMonth(String category);

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @appearanceAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get appearanceAccent;

  /// No description provided for @appearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appearanceLanguage;

  /// No description provided for @appearanceLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get appearanceLanguageEnglish;

  /// No description provided for @appearanceLanguageBulgarian.
  ///
  /// In en, this message translates to:
  /// **'Български'**
  String get appearanceLanguageBulgarian;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @accentSproutPurple.
  ///
  /// In en, this message translates to:
  /// **'Sprout purple'**
  String get accentSproutPurple;

  /// No description provided for @accentBrandBlue.
  ///
  /// In en, this message translates to:
  /// **'Brand blue'**
  String get accentBrandBlue;

  /// No description provided for @accentSproutGreen.
  ///
  /// In en, this message translates to:
  /// **'Sprout green'**
  String get accentSproutGreen;

  /// No description provided for @accentCoral.
  ///
  /// In en, this message translates to:
  /// **'Coral'**
  String get accentCoral;

  /// No description provided for @accentHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get accentHoney;

  /// No description provided for @accentLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get accentLavender;

  /// No description provided for @achievementsHeader.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsHeader;

  /// No description provided for @achFirstSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'First {amount} saved'**
  String achFirstSavedLabel(String amount);

  /// No description provided for @achFirstSavedDesc.
  ///
  /// In en, this message translates to:
  /// **'Across all goals.'**
  String get achFirstSavedDesc;

  /// No description provided for @achStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get achStreakLabel;

  /// No description provided for @achStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'A week of staying on it.'**
  String get achStreakDesc;

  /// No description provided for @achCooldownsLabel.
  ///
  /// In en, this message translates to:
  /// **'10 cooldowns won'**
  String get achCooldownsLabel;

  /// No description provided for @achCooldownsDesc.
  ///
  /// In en, this message translates to:
  /// **'You talked yourself out of ten spends.'**
  String get achCooldownsDesc;

  /// No description provided for @achGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'First goal hit'**
  String get achGoalLabel;

  /// No description provided for @achGoalDesc.
  ///
  /// In en, this message translates to:
  /// **'You crossed the finish line.'**
  String get achGoalDesc;

  /// No description provided for @addTxLogSpend.
  ///
  /// In en, this message translates to:
  /// **'Log a spend'**
  String get addTxLogSpend;

  /// No description provided for @addTxEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get addTxEditTitle;

  /// No description provided for @addTxCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addTxCategory;

  /// No description provided for @addTxNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get addTxNoteHint;

  /// No description provided for @addTxMoodPrompt.
  ///
  /// In en, this message translates to:
  /// **'How did this feel?'**
  String get addTxMoodPrompt;

  /// No description provided for @addTxRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Repeat monthly?'**
  String get addTxRepeatMonthly;

  /// No description provided for @addTxSubmitNew.
  ///
  /// In en, this message translates to:
  /// **'Log spend'**
  String get addTxSubmitNew;

  /// No description provided for @addTxLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged ✓'**
  String get addTxLogged;

  /// No description provided for @cooldownTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a breath.'**
  String get cooldownTitle;

  /// No description provided for @cooldownPrompt.
  ///
  /// In en, this message translates to:
  /// **'Still want this {amount} spend?'**
  String cooldownPrompt(String amount);

  /// No description provided for @cooldownYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, log it'**
  String get cooldownYes;

  /// No description provided for @cooldownNo.
  ///
  /// In en, this message translates to:
  /// **'Nope, saved {amount} 🌱'**
  String cooldownNo(String amount);

  /// No description provided for @categoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryNotFound;

  /// No description provided for @categoryDetailTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get categoryDetailTransactions;

  /// No description provided for @categoryDetailTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String categoryDetailTotalCount(int count);

  /// No description provided for @categoryDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet — log a spend to fill it in 🌱'**
  String get categoryDetailEmpty;

  /// No description provided for @categoryDetailSpentOfCap.
  ///
  /// In en, this message translates to:
  /// **'/ {cap} this month'**
  String categoryDetailSpentOfCap(String cap);

  /// No description provided for @categoryDetailLast30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get categoryDetailLast30;

  /// No description provided for @categoryDetailAdjustCap.
  ///
  /// In en, this message translates to:
  /// **'Adjust cap'**
  String get categoryDetailAdjustCap;

  /// No description provided for @categoryDetailDeleteTxTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get categoryDetailDeleteTxTitle;

  /// No description provided for @categoryDetailDeleteTxNote.
  ///
  /// In en, this message translates to:
  /// **'\"{note}\" — {amount}'**
  String categoryDetailDeleteTxNote(String note, String amount);

  /// No description provided for @categoryDetailDeleteTxNoNote.
  ///
  /// In en, this message translates to:
  /// **'{amount}'**
  String categoryDetailDeleteTxNoNote(String amount);

  /// No description provided for @adjustCapTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust {name} cap'**
  String adjustCapTitle(String name);

  /// No description provided for @adjustCapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to spend on this each month?'**
  String get adjustCapSubtitle;

  /// No description provided for @addCategoryNew.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get addCategoryNew;

  /// No description provided for @addCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addCategoryName;

  /// No description provided for @addCategoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get addCategoryIcon;

  /// No description provided for @addCategoryColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get addCategoryColor;

  /// No description provided for @addCategoryMonthlyCap.
  ///
  /// In en, this message translates to:
  /// **'Monthly cap'**
  String get addCategoryMonthlyCap;

  /// No description provided for @categoryDefaultFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryDefaultFood;

  /// No description provided for @categoryDefaultCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get categoryDefaultCoffee;

  /// No description provided for @categoryDefaultTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryDefaultTransport;

  /// No description provided for @categoryDefaultFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get categoryDefaultFun;

  /// No description provided for @categoryDefaultShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryDefaultShopping;

  /// No description provided for @categoryDefaultOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryDefaultOther;

  /// No description provided for @sparklineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No spending in this category yet 🌱'**
  String get sparklineEmpty;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{{days} day ago} other{{days} days ago}}'**
  String dateDaysAgo(int days);

  /// No description provided for @nudgeNoSpend.
  ///
  /// In en, this message translates to:
  /// **'No-spend day so far — nice ⚡️'**
  String get nudgeNoSpend;

  /// No description provided for @nudgeAheadOfPace.
  ///
  /// In en, this message translates to:
  /// **'🌱 {amount} ahead of pace — keep going.'**
  String nudgeAheadOfPace(String amount);

  /// No description provided for @nudgeTreatDay.
  ///
  /// In en, this message translates to:
  /// **'Today was a treat day, no big deal. Tomorrow we go again.'**
  String get nudgeTreatDay;

  /// No description provided for @insightWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Last week 📅'**
  String get insightWeeklyTitle;

  /// No description provided for @insightWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} transaction} other{{count} transactions}}, {total} total. Top: {topCategory} ({topAmount}). {goalLine}{streak}-day streak alive 🔥'**
  String insightWeeklyBody(
    int count,
    String total,
    String topCategory,
    String topAmount,
    String goalLine,
    int streak,
  );

  /// No description provided for @insightWeeklyGoalLine.
  ///
  /// In en, this message translates to:
  /// **'Goal {name}: +{amount}. '**
  String insightWeeklyGoalLine(String name, String amount);

  /// No description provided for @insightLatteTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee adds up'**
  String get insightLatteTitle;

  /// No description provided for @insightLatteBody.
  ///
  /// In en, this message translates to:
  /// **'You spent {month} on coffee this month. Sustained = {year}/year ☕️'**
  String insightLatteBody(String month, String year);

  /// No description provided for @insightLatteAction.
  ///
  /// In en, this message translates to:
  /// **'Try a what-if?'**
  String get insightLatteAction;

  /// No description provided for @insightMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood matters'**
  String get insightMoodTitle;

  /// No description provided for @insightMoodBody.
  ///
  /// In en, this message translates to:
  /// **'On low-mood days you spend {ratio}× more than on good ones. A 24-hour rule might help next time 🌱'**
  String insightMoodBody(String ratio);

  /// No description provided for @navTogether.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get navTogether;

  /// No description provided for @partnerSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner plan'**
  String get partnerSectionTitle;

  /// No description provided for @partnerSoloPrompt.
  ///
  /// In en, this message translates to:
  /// **'link up to plan shared money — your own stuff stays yours 🌱'**
  String get partnerSoloPrompt;

  /// No description provided for @partnerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'partner\'s email'**
  String get partnerEmailHint;

  /// No description provided for @partnerInviteCta.
  ///
  /// In en, this message translates to:
  /// **'invite partner'**
  String get partnerInviteCta;

  /// No description provided for @partnerInviteSentLabel.
  ///
  /// In en, this message translates to:
  /// **'invite sent to {email}'**
  String partnerInviteSentLabel(String email);

  /// No description provided for @partnerUndo.
  ///
  /// In en, this message translates to:
  /// **'undo'**
  String get partnerUndo;

  /// No description provided for @partnerPendingOutbound.
  ///
  /// In en, this message translates to:
  /// **'waiting on {email} to accept'**
  String partnerPendingOutbound(String email);

  /// No description provided for @partnerCancelInvite.
  ///
  /// In en, this message translates to:
  /// **'cancel invite'**
  String get partnerCancelInvite;

  /// No description provided for @partnerInviteReceived.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to grow money with you. join?'**
  String partnerInviteReceived(String name);

  /// No description provided for @partnerAcceptYes.
  ///
  /// In en, this message translates to:
  /// **'yes, let\'s'**
  String get partnerAcceptYes;

  /// No description provided for @partnerAcceptNo.
  ///
  /// In en, this message translates to:
  /// **'not now'**
  String get partnerAcceptNo;

  /// No description provided for @partnerLinkedSince.
  ///
  /// In en, this message translates to:
  /// **'linked with {name} since {date}'**
  String partnerLinkedSince(String name, String date);

  /// No description provided for @partnerUnlink.
  ///
  /// In en, this message translates to:
  /// **'unlink'**
  String get partnerUnlink;

  /// No description provided for @partnerInviteOnItsWay.
  ///
  /// In en, this message translates to:
  /// **'sprout\'s on its way to {email} 🌱'**
  String partnerInviteOnItsWay(String email);

  /// No description provided for @partnerInviteAccepted.
  ///
  /// In en, this message translates to:
  /// **'you two are now growing together. nice.'**
  String get partnerInviteAccepted;

  /// No description provided for @partnerInviteDeclined.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s sitting this one out for now.'**
  String partnerInviteDeclined(String name);

  /// No description provided for @partnerInviteCancelled.
  ///
  /// In en, this message translates to:
  /// **'invite pulled back. no worries.'**
  String get partnerInviteCancelled;

  /// No description provided for @partnerSharedCategoryHigh.
  ///
  /// In en, this message translates to:
  /// **'shared {category}\'s tracking high this month — worth a chat.'**
  String partnerSharedCategoryHigh(String category);

  /// No description provided for @partnerSharedMilestone.
  ///
  /// In en, this message translates to:
  /// **'you both did this. {goal} is {pct}% there ✨'**
  String partnerSharedMilestone(String goal, int pct);

  /// No description provided for @partnerSharedGoalComplete.
  ///
  /// In en, this message translates to:
  /// **'you grew {goal} all the way. proud of you both 🌳'**
  String partnerSharedGoalComplete(String goal);

  /// No description provided for @partnerPotDeposit.
  ///
  /// In en, this message translates to:
  /// **'{amount} dropped into the pot. it\'s growing.'**
  String partnerPotDeposit(String amount);

  /// No description provided for @partnerUnlinkConfirm.
  ///
  /// In en, this message translates to:
  /// **'sure? you\'ll keep your own stuff, just stop sharing totals.'**
  String get partnerUnlinkConfirm;

  /// No description provided for @partnerUnlinkDone.
  ///
  /// In en, this message translates to:
  /// **'unlinked. your sprout still has your back.'**
  String get partnerUnlinkDone;

  /// No description provided for @partnerErrAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'you\'re already partnered up 🌱'**
  String get partnerErrAlreadyLinked;

  /// No description provided for @partnerErrTargetLinked.
  ///
  /// In en, this message translates to:
  /// **'that person\'s already partnered with someone else'**
  String get partnerErrTargetLinked;

  /// No description provided for @partnerErrEmailUnknown.
  ///
  /// In en, this message translates to:
  /// **'no sprout account for that email — invite them to sign up first'**
  String get partnerErrEmailUnknown;

  /// No description provided for @partnerErrInviteExpired.
  ///
  /// In en, this message translates to:
  /// **'this invite expired — ask them to send a fresh one'**
  String get partnerErrInviteExpired;

  /// No description provided for @partnerErrNotSharedPot.
  ///
  /// In en, this message translates to:
  /// **'that goal isn\'t a shared pot'**
  String get partnerErrNotSharedPot;

  /// No description provided for @partnerErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'something went sideways — give it another go'**
  String get partnerErrGeneric;

  /// No description provided for @togetherSoloTitle.
  ///
  /// In en, this message translates to:
  /// **'grow money together'**
  String get togetherSoloTitle;

  /// No description provided for @togetherSoloBody.
  ///
  /// In en, this message translates to:
  /// **'plan a trip, a home, a rainy-day fund — together, while your own money stays private.'**
  String get togetherSoloBody;

  /// No description provided for @togetherSoloCta.
  ///
  /// In en, this message translates to:
  /// **'link a partner'**
  String get togetherSoloCta;

  /// No description provided for @togetherHeader.
  ///
  /// In en, this message translates to:
  /// **'you & {name}'**
  String togetherHeader(String name);

  /// No description provided for @togetherSharedGoals.
  ///
  /// In en, this message translates to:
  /// **'shared goals'**
  String get togetherSharedGoals;

  /// No description provided for @togetherSharedTxThisMonth.
  ///
  /// In en, this message translates to:
  /// **'shared this month'**
  String get togetherSharedTxThisMonth;

  /// No description provided for @togetherSharedCategories.
  ///
  /// In en, this message translates to:
  /// **'shared categories'**
  String get togetherSharedCategories;

  /// No description provided for @togetherNoSharedGoals.
  ///
  /// In en, this message translates to:
  /// **'no shared goals yet — start one below 🌱'**
  String get togetherNoSharedGoals;

  /// No description provided for @togetherNoSharedTx.
  ///
  /// In en, this message translates to:
  /// **'no shared spends logged this month yet'**
  String get togetherNoSharedTx;

  /// No description provided for @togetherNoSharedCategories.
  ///
  /// In en, this message translates to:
  /// **'nothing shared yet — toggle a category to share its total'**
  String get togetherNoSharedCategories;

  /// No description provided for @togetherWeeklyRecap.
  ///
  /// In en, this message translates to:
  /// **'this week you both saved {amount} toward {goal}'**
  String togetherWeeklyRecap(String amount, String goal);

  /// No description provided for @togetherRatesAsOf.
  ///
  /// In en, this message translates to:
  /// **'rates as of {date}'**
  String togetherRatesAsOf(String date);

  /// No description provided for @togetherSeeAllGoals.
  ///
  /// In en, this message translates to:
  /// **'see all goals'**
  String get togetherSeeAllGoals;

  /// No description provided for @togetherNewSharedGoal.
  ///
  /// In en, this message translates to:
  /// **'new shared goal'**
  String get togetherNewSharedGoal;

  /// No description provided for @togetherManageShared.
  ///
  /// In en, this message translates to:
  /// **'manage what you share'**
  String get togetherManageShared;

  /// No description provided for @togetherFromPartner.
  ///
  /// In en, this message translates to:
  /// **'from {name}'**
  String togetherFromPartner(String name);

  /// No description provided for @togetherFromYou.
  ///
  /// In en, this message translates to:
  /// **'shared by you'**
  String get togetherFromYou;

  /// No description provided for @sharedCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'share categories'**
  String get sharedCategoriesTitle;

  /// No description provided for @sharedCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'pick which of your categories your partner sees the monthly total for — never the individual buys 🌱'**
  String get sharedCategoriesSubtitle;

  /// No description provided for @sharedCategoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'you don\'t have any categories yet'**
  String get sharedCategoriesEmpty;

  /// No description provided for @goalsTogetherSection.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get goalsTogetherSection;

  /// No description provided for @goalFundingSplit.
  ///
  /// In en, this message translates to:
  /// **'split'**
  String get goalFundingSplit;

  /// No description provided for @goalFundingPot.
  ///
  /// In en, this message translates to:
  /// **'shared pot'**
  String get goalFundingPot;

  /// No description provided for @sharedGoalPotBalance.
  ///
  /// In en, this message translates to:
  /// **'pot balance'**
  String get sharedGoalPotBalance;

  /// No description provided for @sharedGoalDeposit.
  ///
  /// In en, this message translates to:
  /// **'deposit'**
  String get sharedGoalDeposit;

  /// No description provided for @sharedGoalDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'drop into the pot'**
  String get sharedGoalDepositTitle;

  /// No description provided for @sharedGoalContributions.
  ///
  /// In en, this message translates to:
  /// **'contributions'**
  String get sharedGoalContributions;

  /// No description provided for @sharedGoalDepositFrom.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get sharedGoalDepositFrom;

  /// No description provided for @sharedGoalCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'new shared goal'**
  String get sharedGoalCreateTitle;

  /// No description provided for @sharedGoalFundingQuestion.
  ///
  /// In en, this message translates to:
  /// **'how do you want to fund it?'**
  String get sharedGoalFundingQuestion;

  /// No description provided for @sharedGoalModePotDesc.
  ///
  /// In en, this message translates to:
  /// **'one shared pot you both top up'**
  String get sharedGoalModePotDesc;

  /// No description provided for @sharedGoalModeSplitDesc.
  ///
  /// In en, this message translates to:
  /// **'each chips in from your own money'**
  String get sharedGoalModeSplitDesc;

  /// No description provided for @sharedGoalYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get sharedGoalYou;

  /// No description provided for @addTxShareWithPartner.
  ///
  /// In en, this message translates to:
  /// **'share with partner'**
  String get addTxShareWithPartner;

  /// No description provided for @addTxPaidBy.
  ///
  /// In en, this message translates to:
  /// **'paid by'**
  String get addTxPaidBy;

  /// No description provided for @addTxPaidByMe.
  ///
  /// In en, this message translates to:
  /// **'me'**
  String get addTxPaidByMe;

  /// No description provided for @addTxPartnerSees.
  ///
  /// In en, this message translates to:
  /// **'your partner sees {amount} of this in their total'**
  String addTxPartnerSees(String amount);

  /// No description provided for @addTxSplitLabel.
  ///
  /// In en, this message translates to:
  /// **'split'**
  String get addTxSplitLabel;

  /// No description provided for @categoryShareToggle.
  ///
  /// In en, this message translates to:
  /// **'share total with partner'**
  String get categoryShareToggle;

  /// No description provided for @categoryShareHelper.
  ///
  /// In en, this message translates to:
  /// **'your partner sees the monthly total here, never individual buys'**
  String get categoryShareHelper;

  /// No description provided for @categoryShareLinkFirst.
  ///
  /// In en, this message translates to:
  /// **'link a partner first'**
  String get categoryShareLinkFirst;

  /// No description provided for @unlinkResolveTitle.
  ///
  /// In en, this message translates to:
  /// **'before you unlink'**
  String get unlinkResolveTitle;

  /// No description provided for @unlinkResolveBody.
  ///
  /// In en, this message translates to:
  /// **'what should happen to your shared goals?'**
  String get unlinkResolveBody;

  /// No description provided for @unlinkResolveAssignMe.
  ///
  /// In en, this message translates to:
  /// **'keep it — becomes mine'**
  String get unlinkResolveAssignMe;

  /// No description provided for @unlinkResolveAssignPartner.
  ///
  /// In en, this message translates to:
  /// **'give it to {name}'**
  String unlinkResolveAssignPartner(String name);

  /// No description provided for @unlinkResolveDelete.
  ///
  /// In en, this message translates to:
  /// **'delete it'**
  String get unlinkResolveDelete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bg', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
