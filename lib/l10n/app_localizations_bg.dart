// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'Sprout';

  @override
  String get appTagline => 'гледай как парите ти растат.';

  @override
  String get navHome => 'Начало';

  @override
  String get navStats => 'Статистика';

  @override
  String get navGoals => 'Цели';

  @override
  String get navYou => 'Профил';

  @override
  String get commonNext => 'Напред';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonCancel => 'Отказ';

  @override
  String get commonSave => 'Запази';

  @override
  String get commonDelete => 'Изтрий';

  @override
  String get commonKeep => 'Остави';

  @override
  String get commonAdd => 'Добави';

  @override
  String get commonNew => 'Ново';

  @override
  String get authLogIn => 'Вход';

  @override
  String get authSignUp => 'Регистрация';

  @override
  String get authFieldName => 'Име';

  @override
  String get authFieldEmail => 'Имейл';

  @override
  String get authFieldPassword => 'Парола';

  @override
  String get authCreateAccount => 'Създай профил';

  @override
  String get authNameRequired => 'Името е задължително';

  @override
  String get authEmailRequired => 'Имейлът е задължителен';

  @override
  String get authEmailInvalid =>
      'това не изглежда съвсем наред — пробвай пак 🌱';

  @override
  String get authPasswordRequired => 'Паролата е задължителна';

  @override
  String get authPasswordTooShort => 'Паролата трябва да е поне 6 символа';

  @override
  String get authEmailLooksOff => 'Имейлът не изглежда наред';

  @override
  String get authPasswordRuleSignup => 'Паролата трябва да е поне 6 символа';

  @override
  String get authAccountExists => 'Вече има профил с този имейл';

  @override
  String get authNoMatch => 'Няма такъв профил — провери данните';

  @override
  String get onbWelcomeGreetingGeneric => 'ей,';

  @override
  String onbWelcomeGreetingNamed(String name) {
    return 'ей $name,';
  }

  @override
  String get onbWelcomeIntro => 'аз съм Sprout.';

  @override
  String get onbWelcomeSubtitle => 'хайде да изградим парите ти — заедно.';

  @override
  String get onbLetsGrow => 'да растем 🌱';

  @override
  String get onbBudgetTitle => 'задай месечен бюджет';

  @override
  String get onbBudgetSubtitle =>
      'без напрежение — можеш да го промениш по всяко време.';

  @override
  String get onbBudgetCurrency => 'Валута';

  @override
  String onbBudgetPerDay(String amount) {
    return 'това е около $amount/ден.';
  }

  @override
  String get onbGoalTitle => 'за какво спестяваш?';

  @override
  String get onbGoalSubtitle => 'избери една за начало. после ще добавиш още.';

  @override
  String get onbGoalPresetTokyo => 'Пътуване до Токио';

  @override
  String get onbGoalPresetMacbook => 'MacBook';

  @override
  String get onbGoalPresetEmergency => 'Спешен фонд';

  @override
  String get onbGoalPresetConcert => 'Концерт';

  @override
  String get onbGoalCreateOwn => 'Или си направи своя';

  @override
  String get onbGoalCustom => 'Собствена цел';

  @override
  String get onbGoalNameField => 'Име на целта';

  @override
  String get onbGoalTargetField => 'Сума';

  @override
  String get onbGoalDeadlineHint => 'Краен срок (по избор)';

  @override
  String get onbQuizTitle => 'бърза проверка на типа';

  @override
  String get onbQuizSubtitle =>
      'помага ми да настроя тона. няма грешни отговори.';

  @override
  String onbQuizResult(String type) {
    return 'ти си $type — ясно. ще го имам предвид.';
  }

  @override
  String get personalitySaver => 'Спестител';

  @override
  String get personalityTreater => 'Глезла';

  @override
  String get personalityGoalChaser => 'Цел-гонещ';

  @override
  String get personalityImpulse => 'Импулсивен';

  @override
  String get onbQuizQ1 => 'Виждаш суичър за 40 €. Ти…';

  @override
  String get onbQuizQ1Saver => 'Подминаваш — пазиш за нещо по-добро';

  @override
  String get onbQuizQ1Treater => 'Купуваш го. Заслужи си го.';

  @override
  String get onbQuizQ1GoalChaser =>
      'Слагаш го в списък \'може би\', утре решаваш';

  @override
  String get onbQuizQ1Impulse => 'Вече е в количката 😅';

  @override
  String get onbQuizQ2 => 'Петък вечер?';

  @override
  String get onbQuizQ2Saver => 'У дома — пуканки и филм';

  @override
  String get onbQuizQ2Treater => 'Вечеря навън с приятели';

  @override
  String get onbQuizQ2GoalChaser => 'Безплатно събитие с приятели';

  @override
  String get onbQuizQ2Impulse => 'Накъдето те поведе вечерта';

  @override
  String get onbQuizQ3 => 'Любимото ти приложение бипка: 50% намаление!';

  @override
  String get onbQuizQ3Saver => 'Заглушаваш го';

  @override
  String get onbQuizQ3Treater => 'Разглеждаш, вероятно купуваш';

  @override
  String get onbQuizQ3GoalChaser => 'Купуваш само това, което си планирал';

  @override
  String get onbQuizQ3Impulse => 'Отваряш веднага';

  @override
  String get onbQuizQ4 => 'Колко често гледаш баланса си?';

  @override
  String get onbQuizQ4Daily => 'Всеки ден';

  @override
  String get onbQuizQ4Weekly => 'Всяка седмица';

  @override
  String get onbQuizQ4Monthly => 'Всеки месец';

  @override
  String get onbQuizQ4Decline => 'Само когато картата откаже 😬';

  @override
  String get onbQuizQ5 => 'Неочаквани 100 € идват в сметката ти.';

  @override
  String get onbQuizQ5Saver => 'Право в спестяванията';

  @override
  String get onbQuizQ5Treater => 'Глезиш се';

  @override
  String get onbQuizQ5GoalChaser => 'Подсилваш цел';

  @override
  String get onbQuizQ5Impulse => 'До вторник ги няма';

  @override
  String get homeWelcomeBack => 'Здрасти отново,';

  @override
  String get homeFriend => 'Приятел';

  @override
  String get homeNoNotifications => 'Няма известия…';

  @override
  String get homeSpending => 'Разходи';

  @override
  String get homeCategories => 'Категории';

  @override
  String get homeNoCategoriesTitle => 'Още няма категории';

  @override
  String get homeNoCategoriesBody => 'Добави една в Профил, за да започнем 🌱';

  @override
  String get homeMarkNoSpend => 'Маркирай днес като ден без харчене';

  @override
  String get homeLogSpend => '+ Запиши разход';

  @override
  String get homeRemainingThisMonth => 'Остават този месец';

  @override
  String get homeTopUp => 'Допълни';

  @override
  String homeOfMonthly(String amount) {
    return 'от $amount';
  }

  @override
  String get homeSelectCurrency => 'Избери валута';

  @override
  String categoryOfCap(String cap) {
    return 'от $cap';
  }

  @override
  String get statsTotalSpent => 'Похарчени общо';

  @override
  String get statsTotalExpenses => 'Общо разходи';

  @override
  String get statsLast90Days => 'Последни 90 дни';

  @override
  String get statsHeatmapLess => 'по-малко';

  @override
  String get statsHeatmapMore => 'повече';

  @override
  String statsLogsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записа',
      one: '$count запис',
    );
    return '$_temp0';
  }

  @override
  String statsDaySummary(String amount, String logs) {
    return '$amount в $logs';
  }

  @override
  String get statsNoSpendDay => 'Ден без харчене 🌱';

  @override
  String get whatIfTitle => 'А ако?';

  @override
  String get whatIfEmpty =>
      'Първо задай цел и Sprout ще ти покаже как съкращенията те ускоряват 🌱';

  @override
  String whatIfCutByPercent(String category, int percent) {
    return 'Намали $category с $percent% →';
  }

  @override
  String get whatIfSave => 'спестяваш ';

  @override
  String whatIfPerMonth(String amount) {
    return '$amount/мес';
  }

  @override
  String get whatIfReach => ' — стигаш ';

  @override
  String get whatIfIn => ' за ';

  @override
  String whatIfWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks седмици',
      one: '$weeks седмица',
    );
    return '$_temp0';
  }

  @override
  String get whatIfNoTick => '. Увеличи срязването, за да тръгне броячът ⏳';

  @override
  String get monthJan => 'яну';

  @override
  String get monthFeb => 'фев';

  @override
  String get monthMar => 'март';

  @override
  String get monthApr => 'апр';

  @override
  String get monthMay => 'май';

  @override
  String get monthJun => 'юни';

  @override
  String get monthJul => 'юли';

  @override
  String get monthAug => 'авг';

  @override
  String get monthSep => 'сеп';

  @override
  String get monthOct => 'окт';

  @override
  String get monthNov => 'ное';

  @override
  String get monthDec => 'дек';

  @override
  String get monthLongJan => 'Януари';

  @override
  String get monthLongFeb => 'Февруари';

  @override
  String get monthLongMar => 'Март';

  @override
  String get monthLongApr => 'Април';

  @override
  String get monthLongMay => 'Май';

  @override
  String get monthLongJun => 'Юни';

  @override
  String get monthLongJul => 'Юли';

  @override
  String get monthLongAug => 'Август';

  @override
  String get monthLongSep => 'Септември';

  @override
  String get monthLongOct => 'Октомври';

  @override
  String get monthLongNov => 'Ноември';

  @override
  String get monthLongDec => 'Декември';

  @override
  String get goalDefaultSavings => 'Спестявания';

  @override
  String get goalDefaultInvest => 'Инвестиции';

  @override
  String get goalsHeader => 'Цели';

  @override
  String get goalsSubtitle => 'Следи за какво спестяваш. Sprout расте с теб.';

  @override
  String get goalsEmptyTitle => 'Още няма цели';

  @override
  String get goalsEmptyBody =>
      'Избери си нещо, за което да спестяваш — дори малко. Sprout ще расте редом.';

  @override
  String get goalsAddCta => 'Добави цел';

  @override
  String get goalSetAside => 'Заделям';

  @override
  String get goalComplete => 'Целта е изпълнена 🎉';

  @override
  String get goalYouDidIt => '🎉 Успя!';

  @override
  String goalOfTarget(String target) {
    return 'от $target';
  }

  @override
  String goalToGo(String amount) {
    return 'още $amount';
  }

  @override
  String goalPaceWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '~$weeks седмици с това темпо',
      one: '~$weeks седмица с това темпо',
    );
    return '$_temp0';
  }

  @override
  String get goalDeadlinePast => 'след крайния срок';

  @override
  String get goalDeadlineToday => 'днес';

  @override
  String goalDeadlineDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'остават $days дни',
      one: 'остава $days ден',
    );
    return '$_temp0';
  }

  @override
  String goalDeadlineWeeksLeft(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'остават $weeks седмици',
      one: 'остава $weeks седмица',
    );
    return '$_temp0';
  }

  @override
  String get goalDetailHistory => 'История';

  @override
  String goalDetailContribCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вноски',
      one: '$count вноска',
    );
    return '$_temp0';
  }

  @override
  String get goalDetailFirstSetAside =>
      'Задели първите си 5 € — Sprout чака 🌱';

  @override
  String get goalNotFound => 'Целта не е намерена';

  @override
  String get goalSheetNewTitle => 'Нова цел';

  @override
  String get goalSheetEditTitle => 'Редактирай цел';

  @override
  String get goalSheetNameField => 'Име';

  @override
  String get goalSheetDeleteConfirmTitle => 'Да изтрием ли тази цел?';

  @override
  String goalSheetDeleteConfirmBody(String name) {
    return 'Sprout ще загуби следата на \'$name\'. Историята на заделените суми също ще изчезне.';
  }

  @override
  String get goalSheetNoDeadline => 'Без краен срок';

  @override
  String get goalSheetAddGoal => 'Добави цел';

  @override
  String setAsideTitle(String goal) {
    return 'Заделям за $goal';
  }

  @override
  String setAsideToGo(String amount) {
    return 'още $amount';
  }

  @override
  String setAsideButtonAmount(String amount) {
    return 'Задели $amount 🌱';
  }

  @override
  String get milestoneComplete => 'Целта е изпълнена! 🎉';

  @override
  String milestonePercent(int percent) {
    return '$percent% сте до там!';
  }

  @override
  String milestoneCompleteSub(String goal) {
    return 'Стигна целта $goal 🌱';
  }

  @override
  String milestoneKeepGoing(String goal) {
    return 'Продължавай към $goal';
  }

  @override
  String get youMonthlyBudget => 'Месечен бюджет';

  @override
  String get youSpentThisMonth => 'Похарчени този месец';

  @override
  String youTopUpThisMonth(String amount) {
    return '+$amount допълнително този месец';
  }

  @override
  String get youTopUpAction => 'Допълни този месец';

  @override
  String get editBudgetSubtitle => 'това става твоят бюджет отсега нататък 🌱';

  @override
  String topUpTitle(String month) {
    return 'Допълване за $month';
  }

  @override
  String get topUpSubtitle => 'еднократен бонус само за този месец 🌱';

  @override
  String topUpButton(String amount) {
    return 'добави $amount';
  }

  @override
  String youStreakLabel(int count) {
    return 'Серия от $count дни';
  }

  @override
  String youStreakLongest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дни',
      one: '$count ден',
    );
    return 'Най-дълга: $_temp0';
  }

  @override
  String get youStreakStart =>
      'Запиши разход или маркирай ден без харчене, за да тръгнеш.';

  @override
  String get youTalkedOutOf => 'Разубеди себе си от';

  @override
  String get youCooldownTitle => 'Таймер за изчакване';

  @override
  String get youCooldownSubtitle => '30 секунди дъх преди всеки голям разход';

  @override
  String get youCooldownTriggerAbove => 'Активиране над';

  @override
  String get youAddCategory => 'Добави категория';

  @override
  String get youLogOut => 'Изход';

  @override
  String get youRoundUpTitle => 'Закръгляне към спестявания';

  @override
  String get youRoundUpNoGoal =>
      'Първо добави цел — закръгленията имат нужда от посока 🌱';

  @override
  String youRoundUpActive(String goal) {
    return 'Всеки разход се закръгля; рестото отива в $goal';
  }

  @override
  String get youRecurringHeader => 'Повтарящи се';

  @override
  String get youRecurringAutoMonth => 'Записва се автоматично всеки месец';

  @override
  String youRecurringCategoryAutoMonth(String category) {
    return '$category · записва се автоматично всеки месец';
  }

  @override
  String get appearanceLabel => 'Изглед';

  @override
  String get appearanceAccent => 'Акцент';

  @override
  String get appearanceLanguage => 'Език';

  @override
  String get appearanceLanguageEnglish => 'English';

  @override
  String get appearanceLanguageBulgarian => 'Български';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeLight => 'Светла';

  @override
  String get themeDark => 'Тъмна';

  @override
  String get accentSproutPurple => 'Sprout лилаво';

  @override
  String get accentBrandBlue => 'Брандово синьо';

  @override
  String get accentSproutGreen => 'Sprout зелено';

  @override
  String get accentCoral => 'Корал';

  @override
  String get accentHoney => 'Мед';

  @override
  String get accentLavender => 'Лавандула';

  @override
  String get achievementsHeader => 'Постижения';

  @override
  String achFirstSavedLabel(String amount) {
    return 'Първите $amount спестени';
  }

  @override
  String get achFirstSavedDesc => 'Във всички цели общо.';

  @override
  String get achStreakLabel => 'Серия от 7 дни';

  @override
  String get achStreakDesc => 'Седмица, в която не пропусна нищо.';

  @override
  String get achCooldownsLabel => '10 спечелени изчаквания';

  @override
  String get achCooldownsDesc => 'Десет пъти разубеди себе си от разход.';

  @override
  String get achGoalLabel => 'Първа постигната цел';

  @override
  String get achGoalDesc => 'Премина финалната линия.';

  @override
  String get addTxLogSpend => 'Запиши разход';

  @override
  String get addTxEditTitle => 'Редактирай разход';

  @override
  String get addTxCategory => 'Категория';

  @override
  String get addTxNoteHint => 'Бележка (по избор)';

  @override
  String get addTxMoodPrompt => 'Как се почувства?';

  @override
  String get addTxRepeatMonthly => 'Повтаряй всеки месец?';

  @override
  String get addTxSubmitNew => 'Запиши';

  @override
  String get addTxLogged => 'Записано ✓';

  @override
  String get cooldownTitle => 'Поеми си дъх.';

  @override
  String cooldownPrompt(String amount) {
    return 'Още ли искаш този разход от $amount?';
  }

  @override
  String get cooldownYes => 'Да, запиши го';

  @override
  String cooldownNo(String amount) {
    return 'Не, спестих $amount 🌱';
  }

  @override
  String get categoryNotFound => 'Категорията не е намерена';

  @override
  String get categoryDetailTransactions => 'Транзакции';

  @override
  String categoryDetailTotalCount(int count) {
    return '$count общо';
  }

  @override
  String get categoryDetailEmpty => 'Тук още няма нищо — запиши разход 🌱';

  @override
  String categoryDetailSpentOfCap(String cap) {
    return '/ $cap този месец';
  }

  @override
  String get categoryDetailLast30 => 'Последните 30 дни';

  @override
  String get categoryDetailAdjustCap => 'Промени лимита';

  @override
  String get categoryDetailDeleteTxTitle => 'Да изтрием ли този разход?';

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
    return 'Промени лимита за $name';
  }

  @override
  String get adjustCapSubtitle => 'Колко искаш да харчиш за това всеки месец?';

  @override
  String get addCategoryNew => 'Нова категория';

  @override
  String get addCategoryName => 'Име';

  @override
  String get addCategoryIcon => 'Икона';

  @override
  String get addCategoryColor => 'Цвят';

  @override
  String get addCategoryMonthlyCap => 'Месечен лимит';

  @override
  String get categoryDefaultFood => 'Храна';

  @override
  String get categoryDefaultCoffee => 'Кафе';

  @override
  String get categoryDefaultTransport => 'Транспорт';

  @override
  String get categoryDefaultFun => 'Забавления';

  @override
  String get categoryDefaultShopping => 'Пазаруване';

  @override
  String get categoryDefaultOther => 'Други';

  @override
  String get sparklineEmpty => 'Още няма разходи в тази категория 🌱';

  @override
  String get dateToday => 'Днес';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String dateDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'преди $days дни',
      one: 'преди $days ден',
    );
    return '$_temp0';
  }

  @override
  String get nudgeNoSpend => 'Засега ден без харчене — браво ⚡️';

  @override
  String nudgeAheadOfPace(String amount) {
    return '🌱 $amount пред темпото — давай.';
  }

  @override
  String get nudgeTreatDay => 'Днес беше глезотен ден, нищо страшно. Утре пак.';

  @override
  String get insightWeeklyTitle => 'Миналата седмица 📅';

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
      other: '$count транзакции',
      one: '$count транзакция',
    );
    return '$_temp0, $total общо. Топ: $topCategory ($topAmount). $goalLineСерията от $streak дни е жива 🔥';
  }

  @override
  String insightWeeklyGoalLine(String name, String amount) {
    return 'Цел $name: +$amount. ';
  }

  @override
  String get insightLatteTitle => 'Кафето се сумира';

  @override
  String insightLatteBody(String month, String year) {
    return 'Похарчи $month за кафе този месец. За цяла година = $year ☕️';
  }

  @override
  String get insightLatteAction => 'Пробвай \'а ако?\'';

  @override
  String get insightMoodTitle => 'Настроението има значение';

  @override
  String insightMoodBody(String ratio) {
    return 'В дни с лошо настроение харчиш $ratio× повече от добрите. Може 24-часовото правило да помогне 🌱';
  }

  @override
  String get navTogether => 'Заедно';

  @override
  String get partnerSectionTitle => 'Партньорски план';

  @override
  String get partnerSoloPrompt =>
      'свържи се, за да планирате общи пари — твоето си остава твое 🌱';

  @override
  String get partnerEmailHint => 'имейл на партньора';

  @override
  String get partnerInviteCta => 'покани партньор';

  @override
  String partnerInviteSentLabel(String email) {
    return 'поканата е изпратена до $email';
  }

  @override
  String get partnerUndo => 'върни';

  @override
  String partnerPendingOutbound(String email) {
    return 'чакаме $email да приеме';
  }

  @override
  String get partnerCancelInvite => 'откажи поканата';

  @override
  String partnerInviteReceived(String name) {
    return '$name иска да растете парите си заедно. навиваш ли се?';
  }

  @override
  String get partnerAcceptYes => 'да, давай';

  @override
  String get partnerAcceptNo => 'не сега';

  @override
  String partnerLinkedSince(String name, String date) {
    return 'свързан с $name от $date';
  }

  @override
  String get partnerUnlink => 'прекрати връзката';

  @override
  String partnerInviteOnItsWay(String email) {
    return 'sprout вече лети към $email 🌱';
  }

  @override
  String get partnerInviteAccepted => 'вече растете заедно. яко.';

  @override
  String partnerInviteDeclined(String name) {
    return '$name ще изчака този път.';
  }

  @override
  String get partnerInviteCancelled => 'поканата е изтеглена. спокойно.';

  @override
  String partnerSharedCategoryHigh(String category) {
    return 'общата категория $category върви нагоре този месец — заслужава разговор.';
  }

  @override
  String partnerSharedMilestone(String goal, int pct) {
    return 'и двамата го направихте. $goal е на $pct% ✨';
  }

  @override
  String partnerSharedGoalComplete(String goal) {
    return 'израснахте $goal докрай. гордея се с вас 🌳';
  }

  @override
  String partnerPotDeposit(String amount) {
    return '$amount паднаха в общия фонд. расте си.';
  }

  @override
  String get partnerUnlinkConfirm =>
      'сигурен ли си? своето си остава твое, просто спирате да споделяте сумите.';

  @override
  String get partnerUnlinkDone => 'връзката е прекратена. sprout пак те пази.';

  @override
  String get partnerErrAlreadyLinked => 'вече си в партньорство 🌱';

  @override
  String get partnerErrTargetLinked =>
      'този човек вече е в партньорство с друг';

  @override
  String get partnerErrEmailUnknown =>
      'няма sprout акаунт за този имейл — поканѝ ги първо да се регистрират';

  @override
  String get partnerErrInviteExpired =>
      'тази покана изтече — помоли ги за нова';

  @override
  String get partnerErrNotSharedPot => 'тази цел не е общ фонд';

  @override
  String get partnerErrGeneric => 'нещо се обърка — пробвай пак';

  @override
  String get togetherSoloTitle => 'растете парите заедно';

  @override
  String get togetherSoloBody =>
      'планирайте пътуване, дом или резерва за черни дни — заедно, докато своите пари остават лични.';

  @override
  String get togetherSoloCta => 'свържи партньор';

  @override
  String togetherHeader(String name) {
    return 'ти и $name';
  }

  @override
  String get togetherSharedGoals => 'общи цели';

  @override
  String get togetherSharedTxThisMonth => 'споделени този месец';

  @override
  String get togetherSharedCategories => 'общи категории';

  @override
  String get togetherNoSharedGoals =>
      'още няма общи цели — започни една отдолу 🌱';

  @override
  String get togetherNoSharedTx => 'още няма споделени разходи този месец';

  @override
  String get togetherNoSharedCategories =>
      'още нищо споделено — включи категория, за да видите общата ѝ сума';

  @override
  String togetherWeeklyRecap(String amount, String goal) {
    return 'тази седмица заедно спестихте $amount към $goal';
  }

  @override
  String togetherRatesAsOf(String date) {
    return 'курсове към $date';
  }

  @override
  String get togetherSeeAllGoals => 'виж всички цели';

  @override
  String get togetherNewSharedGoal => 'нова обща цел';

  @override
  String get togetherManageShared => 'управлявай какво споделяш';

  @override
  String togetherFromPartner(String name) {
    return 'от $name';
  }

  @override
  String get togetherFromYou => 'споделено от теб';

  @override
  String get sharedCategoriesTitle => 'споделяй категории';

  @override
  String get sharedCategoriesSubtitle =>
      'избери за кои твои категории партньорът ти вижда месечната сума — никога отделните покупки 🌱';

  @override
  String get sharedCategoriesEmpty => 'още нямаш категории';

  @override
  String get goalsTogetherSection => 'Заедно';

  @override
  String get goalFundingSplit => 'разделено';

  @override
  String get goalFundingPot => 'общ фонд';

  @override
  String get sharedGoalPotBalance => 'баланс на фонда';

  @override
  String get sharedGoalDeposit => 'внеси';

  @override
  String get sharedGoalDepositTitle => 'пусни в общия фонд';

  @override
  String get sharedGoalContributions => 'вноски';

  @override
  String get sharedGoalDepositFrom => 'от';

  @override
  String get sharedGoalCreateTitle => 'нова обща цел';

  @override
  String get sharedGoalFundingQuestion => 'как ще я финансирате?';

  @override
  String get sharedGoalModePotDesc =>
      'един общ фонд, който и двамата захранвате';

  @override
  String get sharedGoalModeSplitDesc => 'всеки внася от своите пари';

  @override
  String get sharedGoalYou => 'ти';

  @override
  String get addTxShareWithPartner => 'сподели с партньор';

  @override
  String get addTxPaidBy => 'платено от';

  @override
  String get addTxPaidByMe => 'мен';

  @override
  String addTxPartnerSees(String amount) {
    return 'партньорът ти вижда $amount от това в своята сума';
  }

  @override
  String get addTxSplitLabel => 'разделяне';

  @override
  String get categoryShareToggle => 'сподели общата сума с партньор';

  @override
  String get categoryShareHelper =>
      'партньорът ти вижда само месечната сума тук, никога отделните покупки';

  @override
  String get categoryShareLinkFirst => 'първо свържи партньор';

  @override
  String get unlinkResolveTitle => 'преди да прекратиш';

  @override
  String get unlinkResolveBody => 'какво да стане с общите ви цели?';

  @override
  String get unlinkResolveAssignMe => 'запази я — става моя';

  @override
  String unlinkResolveAssignPartner(String name) {
    return 'дай я на $name';
  }

  @override
  String get unlinkResolveDelete => 'изтрий я';
}
