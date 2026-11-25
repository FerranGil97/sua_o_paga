import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In ca, this message translates to:
  /// **'SuaOPaga'**
  String get appName;

  /// No description provided for @slogan.
  ///
  /// In ca, this message translates to:
  /// **'Sua o paga les conseqüències'**
  String get slogan;

  /// No description provided for @entrarGoogle.
  ///
  /// In ca, this message translates to:
  /// **'Entrar amb Google'**
  String get entrarGoogle;

  /// No description provided for @ranking.
  ///
  /// In ca, this message translates to:
  /// **'Ranking'**
  String get ranking;

  /// No description provided for @entrenar.
  ///
  /// In ca, this message translates to:
  /// **'Entrenar'**
  String get entrenar;

  /// No description provided for @castig.
  ///
  /// In ca, this message translates to:
  /// **'Càstig'**
  String get castig;

  /// No description provided for @historial.
  ///
  /// In ca, this message translates to:
  /// **'Historial'**
  String get historial;

  /// No description provided for @crearGrup.
  ///
  /// In ca, this message translates to:
  /// **'Crear un grup nou'**
  String get crearGrup;

  /// No description provided for @unirseGrup.
  ///
  /// In ca, this message translates to:
  /// **'Unir-se a un grup'**
  String get unirseGrup;

  /// No description provided for @nomGrup.
  ///
  /// In ca, this message translates to:
  /// **'Nom del grup'**
  String get nomGrup;

  /// No description provided for @codiInvitacio.
  ///
  /// In ca, this message translates to:
  /// **'Codi d\'invitació'**
  String get codiInvitacio;

  /// No description provided for @crearBtn.
  ///
  /// In ca, this message translates to:
  /// **'Crear grup'**
  String get crearBtn;

  /// No description provided for @unirseBtn.
  ///
  /// In ca, this message translates to:
  /// **'Unir-se'**
  String get unirseBtn;

  /// No description provided for @elsMeusGrups.
  ///
  /// In ca, this message translates to:
  /// **'Els meus grups'**
  String get elsMeusGrups;

  /// No description provided for @membres.
  ///
  /// In ca, this message translates to:
  /// **'{n} membres'**
  String membres(int n);

  /// No description provided for @tancarSessio.
  ///
  /// In ca, this message translates to:
  /// **'Tancar sessió'**
  String get tancarSessio;

  /// No description provided for @castigSetmana.
  ///
  /// In ca, this message translates to:
  /// **'Càstig d\'aquesta setmana'**
  String get castigSetmana;

  /// No description provided for @minimMinuts.
  ///
  /// In ca, this message translates to:
  /// **'Mínim 30 min per comptar un entrenament'**
  String get minimMinuts;

  /// No description provided for @diesEntrenant.
  ///
  /// In ca, this message translates to:
  /// **'{n} dies entrenats'**
  String diesEntrenant(int n);

  /// No description provided for @laTevaSetmana.
  ///
  /// In ca, this message translates to:
  /// **'La teva setmana'**
  String get laTevaSetmana;

  /// No description provided for @quinEsport.
  ///
  /// In ca, this message translates to:
  /// **'Quin esport?'**
  String get quinEsport;

  /// No description provided for @durada.
  ///
  /// In ca, this message translates to:
  /// **'Durada'**
  String get durada;

  /// No description provided for @registrarEntreno.
  ///
  /// In ca, this message translates to:
  /// **'Registrar entreno'**
  String get registrarEntreno;

  /// No description provided for @comptaMsg.
  ///
  /// In ca, this message translates to:
  /// **'Compta!'**
  String get comptaMsg;

  /// No description provided for @noComptaMsg.
  ///
  /// In ca, this message translates to:
  /// **'Mínim 30 min'**
  String get noComptaMsg;

  /// No description provided for @votarCastig.
  ///
  /// In ca, this message translates to:
  /// **'Vota el càstig'**
  String get votarCastig;

  /// No description provided for @proposarCastig.
  ///
  /// In ca, this message translates to:
  /// **'Proposar un càstig nou'**
  String get proposarCastig;

  /// No description provided for @afegirProposta.
  ///
  /// In ca, this message translates to:
  /// **'Afegir proposta'**
  String get afegirProposta;

  /// No description provided for @rankingTotal.
  ///
  /// In ca, this message translates to:
  /// **'Ranking total'**
  String get rankingTotal;

  /// No description provided for @historialSetmanes.
  ///
  /// In ca, this message translates to:
  /// **'Historial per setmanes'**
  String get historialSetmanes;

  /// No description provided for @perdedor.
  ///
  /// In ca, this message translates to:
  /// **'Perdedor'**
  String get perdedor;

  /// No description provided for @dies.
  ///
  /// In ca, this message translates to:
  /// **'dies'**
  String get dies;

  /// No description provided for @jaRegistratAvui.
  ///
  /// In ca, this message translates to:
  /// **'Ja has registrat un entreno vàlid avui!'**
  String get jaRegistratAvui;

  /// No description provided for @entrenoPetit.
  ///
  /// In ca, this message translates to:
  /// **'Mínim 30 minuts per comptar!'**
  String get entrenoPetit;

  /// No description provided for @seleccionaEsport.
  ///
  /// In ca, this message translates to:
  /// **'Selecciona un esport!'**
  String get seleccionaEsport;

  /// No description provided for @entrenoRegistrat.
  ///
  /// In ca, this message translates to:
  /// **'Entreno registrat! +1 dia al ranking'**
  String get entrenoRegistrat;

  /// No description provided for @setmana.
  ///
  /// In ca, this message translates to:
  /// **'Setmana'**
  String get setmana;
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
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
