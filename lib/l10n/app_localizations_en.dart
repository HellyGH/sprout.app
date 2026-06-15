// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sprout';

  @override
  String get appTagline => 'Watch your money grow.';

  @override
  String get navHome => 'Home';

  @override
  String get navStats => 'Stats';

  @override
  String get navGoals => 'Goals';

  @override
  String get navYou => 'You';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonKeep => 'Keep';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonNew => 'New';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authFieldName => 'Name';

  @override
  String get authFieldEmail => 'Email';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authNameRequired => 'Name is required';

  @override
  String get authEmailRequired => 'Email is required';

  @override
  String get authEmailInvalid =>
      'That doesn\'t look quite right — try again 🌱';

  @override
  String get authPasswordRequired => 'Password is required';

  @override
  String get authPasswordTooShort => 'Password needs at least 6 characters';

  @override
  String get authEmailLooksOff => 'Email looks off';

  @override
  String get authPasswordRuleSignup => 'Password must be at least 6 characters';

  @override
  String get authAccountExists => 'An account already exists for that email';

  @override
  String get authNoMatch => 'No matching account — check your details';

  @override
  String get onbWelcomeGreetingGeneric => 'Hey there,';

  @override
  String onbWelcomeGreetingNamed(String name) {
    return 'Hey $name,';
  }

  @override
  String get onbWelcomeIntro => 'I\'m Sprout.';

  @override
  String get onbWelcomeSubtitle => 'Let\'s grow your money — together.';

  @override
  String get onbLetsGrow => 'Let\'s grow 🌱';

  @override
  String get onbBudgetTitle => 'Set your monthly budget';

  @override
  String get onbBudgetSubtitle => 'Don\'t worry — you can change this anytime.';

  @override
  String get onbBudgetCurrency => 'Currency';

  @override
  String onbBudgetPerDay(String amount) {
    return 'That\'s about $amount/day.';
  }

  @override
  String get onbGoalTitle => 'What are you saving for?';

  @override
  String get onbGoalSubtitle => 'Pick one to start. You can add more later.';

  @override
  String get onbGoalPresetTokyo => 'Tokyo trip';

  @override
  String get onbGoalPresetMacbook => 'MacBook';

  @override
  String get onbGoalPresetEmergency => 'Emergency fund';

  @override
  String get onbGoalPresetConcert => 'Concert';

  @override
  String get onbGoalCreateOwn => 'Or create your own';

  @override
  String get onbGoalCustom => 'Custom goal';

  @override
  String get onbGoalNameField => 'Goal name';

  @override
  String get onbGoalTargetField => 'Target amount';

  @override
  String get onbGoalDeadlineHint => 'Deadline (optional)';

  @override
  String get onbQuizTitle => 'Quick personality check';

  @override
  String get onbQuizSubtitle => 'Helps me tone-tune nudges. No wrong answers.';

  @override
  String onbQuizResult(String type) {
    return 'You\'re a $type — got it. I\'ll keep that in mind.';
  }

  @override
  String get personalitySaver => 'Saver';

  @override
  String get personalityTreater => 'Treater';

  @override
  String get personalityGoalChaser => 'Goal-chaser';

  @override
  String get personalityImpulse => 'Impulse';

  @override
  String get onbQuizQ1 => 'A €40 hoodie catches your eye. You…';

  @override
  String get onbQuizQ1Saver => 'Walk on — saving for something better';

  @override
  String get onbQuizQ1Treater => 'Buy it. You earned it.';

  @override
  String get onbQuizQ1GoalChaser =>
      'Add it to a \'maybe\' list, decide tomorrow';

  @override
  String get onbQuizQ1Impulse => 'It\'s already in your cart 😅';

  @override
  String get onbQuizQ2 => 'Friday night?';

  @override
  String get onbQuizQ2Saver => 'Cozy in — popcorn + film';

  @override
  String get onbQuizQ2Treater => 'Dinner out with mates';

  @override
  String get onbQuizQ2GoalChaser => 'Free event with friends';

  @override
  String get onbQuizQ2Impulse => 'See where the night takes you';

  @override
  String get onbQuizQ3 => 'Your favourite app pings: 50% off!';

  @override
  String get onbQuizQ3Saver => 'Mute it';

  @override
  String get onbQuizQ3Treater => 'Browse, probably buy';

  @override
  String get onbQuizQ3GoalChaser => 'Buy only what you\'d planned';

  @override
  String get onbQuizQ3Impulse => 'Open it immediately';

  @override
  String get onbQuizQ4 => 'How often do you check your balance?';

  @override
  String get onbQuizQ4Daily => 'Daily';

  @override
  String get onbQuizQ4Weekly => 'Weekly';

  @override
  String get onbQuizQ4Monthly => 'Monthly';

  @override
  String get onbQuizQ4Decline => 'Only when the card declines 😬';

  @override
  String get onbQuizQ5 => 'An unexpected €100 lands in your account.';

  @override
  String get onbQuizQ5Saver => 'Straight to savings';

  @override
  String get onbQuizQ5Treater => 'Treat yourself';

  @override
  String get onbQuizQ5GoalChaser => 'Boost a goal';

  @override
  String get onbQuizQ5Impulse => 'It\'s gone by Tuesday';

  @override
  String get homeWelcomeBack => 'Welcome back,';

  @override
  String get homeFriend => 'Friend';

  @override
  String get homeNoNotifications => 'No notifications…';

  @override
  String get homeSpending => 'Spending';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeNoCategoriesTitle => 'No categories yet';

  @override
  String get homeNoCategoriesBody =>
      'Add one in the You tab to start tracking 🌱';

  @override
  String get homeMarkNoSpend => 'Mark today as no-spend';

  @override
  String get homeLogSpend => '+ Log a spend';

  @override
  String get homeRemainingThisMonth => 'Remaining this month';

  @override
  String get homeTopUp => 'Top up';

  @override
  String homeOfMonthly(String amount) {
    return 'of $amount';
  }

  @override
  String get homeSelectCurrency => 'Select currency';

  @override
  String categoryOfCap(String cap) {
    return 'of $cap';
  }

  @override
  String get statsTotalSpent => 'Total Spent';

  @override
  String get statsTotalExpenses => 'Total Expenses';

  @override
  String get statsLast90Days => 'Last 90 days';

  @override
  String get statsHeatmapLess => 'less';

  @override
  String get statsHeatmapMore => 'more';

  @override
  String statsLogsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count logs',
      one: '$count log',
    );
    return '$_temp0';
  }

  @override
  String statsDaySummary(String amount, String logs) {
    return '$amount across $logs';
  }

  @override
  String get statsNoSpendDay => 'No-spend day 🌱';

  @override
  String get whatIfTitle => 'What if?';

  @override
  String get whatIfEmpty =>
      'Set a goal first and Sprout will show how cutting back speeds you up 🌱';

  @override
  String whatIfCutByPercent(String category, int percent) {
    return 'Cut $category by $percent% →';
  }

  @override
  String get whatIfSave => 'save ';

  @override
  String whatIfPerMonth(String amount) {
    return '$amount/mo';
  }

  @override
  String get whatIfReach => ' — reach ';

  @override
  String get whatIfIn => ' in ';

  @override
  String whatIfWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '$weeks week',
    );
    return '$_temp0';
  }

  @override
  String get whatIfNoTick => '. Increase the cut to start ticking down ⏳';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'Sept';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get monthLongJan => 'January';

  @override
  String get monthLongFeb => 'February';

  @override
  String get monthLongMar => 'March';

  @override
  String get monthLongApr => 'April';

  @override
  String get monthLongMay => 'May';

  @override
  String get monthLongJun => 'June';

  @override
  String get monthLongJul => 'July';

  @override
  String get monthLongAug => 'August';

  @override
  String get monthLongSep => 'September';

  @override
  String get monthLongOct => 'October';

  @override
  String get monthLongNov => 'November';

  @override
  String get monthLongDec => 'December';

  @override
  String get goalDefaultSavings => 'Savings';

  @override
  String get goalDefaultInvest => 'Invest';

  @override
  String get goalsHeader => 'Goals';

  @override
  String get goalsSubtitle =>
      'Track what you\'re saving for. Sprout grows with you.';

  @override
  String get goalsEmptyTitle => 'No goals yet';

  @override
  String get goalsEmptyBody =>
      'Pick something you\'re saving for — even a small one. Sprout will grow alongside.';

  @override
  String get goalsAddCta => 'Add a goal';

  @override
  String get goalSetAside => 'Set aside';

  @override
  String get goalComplete => 'Goal complete 🎉';

  @override
  String get goalYouDidIt => '🎉 You did it!';

  @override
  String goalOfTarget(String target) {
    return 'of $target';
  }

  @override
  String goalToGo(String amount) {
    return '$amount to go';
  }

  @override
  String goalPaceWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '~$weeks weeks at this rate',
      one: '~$weeks week at this rate',
    );
    return '$_temp0';
  }

  @override
  String get goalDeadlinePast => 'past deadline';

  @override
  String get goalDeadlineToday => 'today';

  @override
  String goalDeadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '$days day left',
    );
    return '$_temp0';
  }

  @override
  String goalDeadlineWeeksLeft(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks left',
      one: '$weeks week left',
    );
    return '$_temp0';
  }

  @override
  String get goalDetailHistory => 'History';

  @override
  String goalDetailContribCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions',
      one: '$count contribution',
    );
    return '$_temp0';
  }

  @override
  String get goalDetailFirstSetAside =>
      'Set aside your first €5 — Sprout\'s waiting 🌱';

  @override
  String get goalNotFound => 'Goal not found';

  @override
  String get goalSheetNewTitle => 'New goal';

  @override
  String get goalSheetEditTitle => 'Edit goal';

  @override
  String get goalSheetNameField => 'Name';

  @override
  String get goalSheetDeleteConfirmTitle => 'Delete this goal?';

  @override
  String goalSheetDeleteConfirmBody(String name) {
    return 'Sprout will lose track of \'$name\'. Set-aside history will go too.';
  }

  @override
  String get goalSheetNoDeadline => 'No deadline';

  @override
  String get goalSheetAddGoal => 'Add goal';

  @override
  String setAsideTitle(String goal) {
    return 'Set aside for $goal';
  }

  @override
  String setAsideToGo(String amount) {
    return '$amount to go';
  }

  @override
  String setAsideButtonAmount(String amount) {
    return 'Set aside $amount 🌱';
  }

  @override
  String get milestoneComplete => 'Goal complete! 🎉';

  @override
  String milestonePercent(int percent) {
    return '$percent% there!';
  }

  @override
  String milestoneCompleteSub(String goal) {
    return 'You hit your $goal goal 🌱';
  }

  @override
  String milestoneKeepGoing(String goal) {
    return 'Keep going on $goal';
  }

  @override
  String get youMonthlyBudget => 'Monthly budget';

  @override
  String get youSpentThisMonth => 'Spent this month';

  @override
  String youTopUpThisMonth(String amount) {
    return '+$amount extra this month';
  }

  @override
  String get youTopUpAction => 'Top up this month';

  @override
  String get editBudgetSubtitle => 'this becomes your budget from now on 🌱';

  @override
  String topUpTitle(String month) {
    return 'Top up $month';
  }

  @override
  String get topUpSubtitle => 'a one-off boost, just for this month 🌱';

  @override
  String topUpButton(String amount) {
    return 'add $amount';
  }

  @override
  String youStreakLabel(int count) {
    return '$count-day streak';
  }

  @override
  String youStreakLongest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return 'Longest: $_temp0';
  }

  @override
  String get youStreakStart => 'Log a spend or mark a no-spend day to start.';

  @override
  String get youTalkedOutOf => 'Talked yourself out of';

  @override
  String get youCooldownTitle => 'Cooldown timer';

  @override
  String get youCooldownSubtitle => '30s breath before any big spend';

  @override
  String get youCooldownTriggerAbove => 'Trigger above';

  @override
  String get youAddCategory => 'Add a category';

  @override
  String get youLogOut => 'Log out';

  @override
  String get youRoundUpTitle => 'Round-up savings';

  @override
  String get youRoundUpNoGoal =>
      'Add a goal first — round-ups need a destination 🌱';

  @override
  String youRoundUpActive(String goal) {
    return 'Each spend rounds up; spare change → $goal';
  }

  @override
  String get youRecurringHeader => 'Recurring';

  @override
  String get youRecurringAutoMonth => 'Auto-logs each month';

  @override
  String youRecurringCategoryAutoMonth(String category) {
    return '$category · auto-logs each month';
  }

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get appearanceAccent => 'Accent';

  @override
  String get appearanceLanguage => 'Language';

  @override
  String get appearanceLanguageEnglish => 'English';

  @override
  String get appearanceLanguageBulgarian => 'Български';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accentSproutPurple => 'Sprout purple';

  @override
  String get accentBrandBlue => 'Brand blue';

  @override
  String get accentSproutGreen => 'Sprout green';

  @override
  String get accentCoral => 'Coral';

  @override
  String get accentHoney => 'Honey';

  @override
  String get accentLavender => 'Lavender';

  @override
  String get achievementsHeader => 'Achievements';

  @override
  String achFirstSavedLabel(String amount) {
    return 'First $amount saved';
  }

  @override
  String get achFirstSavedDesc => 'Across all goals.';

  @override
  String get achStreakLabel => '7-day streak';

  @override
  String get achStreakDesc => 'A week of staying on it.';

  @override
  String get achCooldownsLabel => '10 cooldowns won';

  @override
  String get achCooldownsDesc => 'You talked yourself out of ten spends.';

  @override
  String get achGoalLabel => 'First goal hit';

  @override
  String get achGoalDesc => 'You crossed the finish line.';

  @override
  String get addTxLogSpend => 'Log a spend';

  @override
  String get addTxEditTitle => 'Edit transaction';

  @override
  String get addTxCategory => 'Category';

  @override
  String get addTxNoteHint => 'Note (optional)';

  @override
  String get addTxMoodPrompt => 'How did this feel?';

  @override
  String get addTxRepeatMonthly => 'Repeat monthly?';

  @override
  String get addTxSubmitNew => 'Log spend';

  @override
  String get addTxLogged => 'Logged ✓';

  @override
  String get cooldownTitle => 'Take a breath.';

  @override
  String cooldownPrompt(String amount) {
    return 'Still want this $amount spend?';
  }

  @override
  String get cooldownYes => 'Yes, log it';

  @override
  String cooldownNo(String amount) {
    return 'Nope, saved $amount 🌱';
  }

  @override
  String get categoryNotFound => 'Category not found';

  @override
  String get categoryDetailTransactions => 'Transactions';

  @override
  String categoryDetailTotalCount(int count) {
    return '$count total';
  }

  @override
  String get categoryDetailEmpty =>
      'Nothing here yet — log a spend to fill it in 🌱';

  @override
  String categoryDetailSpentOfCap(String cap) {
    return '/ $cap this month';
  }

  @override
  String get categoryDetailLast30 => 'Last 30 days';

  @override
  String get categoryDetailAdjustCap => 'Adjust cap';

  @override
  String get categoryDetailDeleteTxTitle => 'Delete this transaction?';

  @override
  String categoryDetailDeleteTxNote(String note, String amount) {
    return '\"$note\" — $amount';
  }

  @override
  String categoryDetailDeleteTxNoNote(String amount) {
    return '$amount';
  }

  @override
  String adjustCapTitle(String name) {
    return 'Adjust $name cap';
  }

  @override
  String get adjustCapSubtitle =>
      'How much do you want to spend on this each month?';

  @override
  String get addCategoryNew => 'New category';

  @override
  String get addCategoryName => 'Name';

  @override
  String get addCategoryIcon => 'Icon';

  @override
  String get addCategoryColor => 'Color';

  @override
  String get addCategoryMonthlyCap => 'Monthly cap';

  @override
  String get categoryDefaultFood => 'Food';

  @override
  String get categoryDefaultCoffee => 'Coffee';

  @override
  String get categoryDefaultTransport => 'Transport';

  @override
  String get categoryDefaultFun => 'Fun';

  @override
  String get categoryDefaultShopping => 'Shopping';

  @override
  String get categoryDefaultOther => 'Other';

  @override
  String get sparklineEmpty => 'No spending in this category yet 🌱';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String dateDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '$days day ago',
    );
    return '$_temp0';
  }

  @override
  String get nudgeNoSpend => 'No-spend day so far — nice ⚡️';

  @override
  String nudgeAheadOfPace(String amount) {
    return '🌱 $amount ahead of pace — keep going.';
  }

  @override
  String get nudgeTreatDay =>
      'Today was a treat day, no big deal. Tomorrow we go again.';

  @override
  String get insightWeeklyTitle => 'Last week 📅';

  @override
  String insightWeeklyBody(
    int count,
    String total,
    String topCategory,
    String topAmount,
    String goalLine,
    int streak,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '$count transaction',
    );
    return '$_temp0, $total total. Top: $topCategory ($topAmount). $goalLine$streak-day streak alive 🔥';
  }

  @override
  String insightWeeklyGoalLine(String name, String amount) {
    return 'Goal $name: +$amount. ';
  }

  @override
  String get insightLatteTitle => 'Coffee adds up';

  @override
  String insightLatteBody(String month, String year) {
    return 'You spent $month on coffee this month. Sustained = $year/year ☕️';
  }

  @override
  String get insightLatteAction => 'Try a what-if?';

  @override
  String get insightMoodTitle => 'Mood matters';

  @override
  String insightMoodBody(String ratio) {
    return 'On low-mood days you spend $ratio× more than on good ones. A 24-hour rule might help next time 🌱';
  }

  @override
  String get navTogether => 'Together';

  @override
  String get partnerSectionTitle => 'Partner plan';

  @override
  String get partnerSoloPrompt =>
      'link up to plan shared money — your own stuff stays yours 🌱';

  @override
  String get partnerEmailHint => 'partner\'s email';

  @override
  String get partnerInviteCta => 'invite partner';

  @override
  String partnerInviteSentLabel(String email) {
    return 'invite sent to $email';
  }

  @override
  String get partnerUndo => 'undo';

  @override
  String partnerPendingOutbound(String email) {
    return 'waiting on $email to accept';
  }

  @override
  String get partnerCancelInvite => 'cancel invite';

  @override
  String partnerInviteReceived(String name) {
    return '$name wants to grow money with you. join?';
  }

  @override
  String get partnerAcceptYes => 'yes, let\'s';

  @override
  String get partnerAcceptNo => 'not now';

  @override
  String partnerLinkedSince(String name, String date) {
    return 'linked with $name since $date';
  }

  @override
  String get partnerUnlink => 'unlink';

  @override
  String partnerInviteOnItsWay(String email) {
    return 'sprout\'s on its way to $email 🌱';
  }

  @override
  String get partnerInviteAccepted => 'you two are now growing together. nice.';

  @override
  String partnerInviteDeclined(String name) {
    return '$name\'s sitting this one out for now.';
  }

  @override
  String get partnerInviteCancelled => 'invite pulled back. no worries.';

  @override
  String partnerSharedCategoryHigh(String category) {
    return 'shared $category\'s tracking high this month — worth a chat.';
  }

  @override
  String partnerSharedMilestone(String goal, int pct) {
    return 'you both did this. $goal is $pct% there ✨';
  }

  @override
  String partnerSharedGoalComplete(String goal) {
    return 'you grew $goal all the way. proud of you both 🌳';
  }

  @override
  String partnerPotDeposit(String amount) {
    return '$amount dropped into the pot. it\'s growing.';
  }

  @override
  String get partnerUnlinkConfirm =>
      'sure? you\'ll keep your own stuff, just stop sharing totals.';

  @override
  String get partnerUnlinkDone => 'unlinked. your sprout still has your back.';

  @override
  String get partnerErrAlreadyLinked => 'you\'re already partnered up 🌱';

  @override
  String get partnerErrTargetLinked =>
      'that person\'s already partnered with someone else';

  @override
  String get partnerErrEmailUnknown =>
      'no sprout account for that email — invite them to sign up first';

  @override
  String get partnerErrInviteExpired =>
      'this invite expired — ask them to send a fresh one';

  @override
  String get partnerErrNotSharedPot => 'that goal isn\'t a shared pot';

  @override
  String get partnerErrGeneric =>
      'something went sideways — give it another go';

  @override
  String get togetherSoloTitle => 'grow money together';

  @override
  String get togetherSoloBody =>
      'plan a trip, a home, a rainy-day fund — together, while your own money stays private.';

  @override
  String get togetherSoloCta => 'link a partner';

  @override
  String togetherHeader(String name) {
    return 'you & $name';
  }

  @override
  String get togetherSharedGoals => 'shared goals';

  @override
  String get togetherSharedTxThisMonth => 'shared this month';

  @override
  String get togetherSharedCategories => 'shared categories';

  @override
  String get togetherNoSharedGoals =>
      'no shared goals yet — start one below 🌱';

  @override
  String get togetherNoSharedTx => 'no shared spends logged this month yet';

  @override
  String get togetherNoSharedCategories =>
      'nothing shared yet — toggle a category to share its total';

  @override
  String togetherWeeklyRecap(String amount, String goal) {
    return 'this week you both saved $amount toward $goal';
  }

  @override
  String togetherRatesAsOf(String date) {
    return 'rates as of $date';
  }

  @override
  String get togetherSeeAllGoals => 'see all goals';

  @override
  String get togetherNewSharedGoal => 'new shared goal';

  @override
  String get togetherManageShared => 'manage what you share';

  @override
  String togetherFromPartner(String name) {
    return 'from $name';
  }

  @override
  String get togetherFromYou => 'shared by you';

  @override
  String get sharedCategoriesTitle => 'share categories';

  @override
  String get sharedCategoriesSubtitle =>
      'pick which of your categories your partner sees the monthly total for — never the individual buys 🌱';

  @override
  String get sharedCategoriesEmpty => 'you don\'t have any categories yet';

  @override
  String get goalsTogetherSection => 'Together';

  @override
  String get goalFundingSplit => 'split';

  @override
  String get goalFundingPot => 'shared pot';

  @override
  String get sharedGoalPotBalance => 'pot balance';

  @override
  String get sharedGoalDeposit => 'deposit';

  @override
  String get sharedGoalDepositTitle => 'drop into the pot';

  @override
  String get sharedGoalContributions => 'contributions';

  @override
  String get sharedGoalDepositFrom => 'from';

  @override
  String get sharedGoalCreateTitle => 'new shared goal';

  @override
  String get sharedGoalFundingQuestion => 'how do you want to fund it?';

  @override
  String get sharedGoalModePotDesc => 'one shared pot you both top up';

  @override
  String get sharedGoalModeSplitDesc => 'each chips in from your own money';

  @override
  String get sharedGoalYou => 'you';

  @override
  String get addTxShareWithPartner => 'share with partner';

  @override
  String get addTxPaidBy => 'paid by';

  @override
  String get addTxPaidByMe => 'me';

  @override
  String addTxPartnerSees(String amount) {
    return 'your partner sees $amount of this in their total';
  }

  @override
  String get addTxSplitLabel => 'split';

  @override
  String get categoryShareToggle => 'share total with partner';

  @override
  String get categoryShareHelper =>
      'your partner sees the monthly total here, never individual buys';

  @override
  String get categoryShareLinkFirst => 'link a partner first';

  @override
  String get unlinkResolveTitle => 'before you unlink';

  @override
  String get unlinkResolveBody => 'what should happen to your shared goals?';

  @override
  String get unlinkResolveAssignMe => 'keep it — becomes mine';

  @override
  String unlinkResolveAssignPartner(String name) {
    return 'give it to $name';
  }

  @override
  String get unlinkResolveDelete => 'delete it';
}
