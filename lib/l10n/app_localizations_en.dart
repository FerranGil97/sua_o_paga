// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SuaOPaga';

  @override
  String get slogan => 'Sweat or pay the consequences';

  @override
  String get entrarGoogle => 'Sign in with Google';

  @override
  String get ranking => 'Ranking';

  @override
  String get entrenar => 'Workout';

  @override
  String get castig => 'Penalty';

  @override
  String get historial => 'History';

  @override
  String get crearGrup => 'Create a new group';

  @override
  String get unirseGrup => 'Join a group';

  @override
  String get nomGrup => 'Group name';

  @override
  String get codiInvitacio => 'Invitation code';

  @override
  String get crearBtn => 'Create group';

  @override
  String get unirseBtn => 'Join';

  @override
  String get elsMeusGrups => 'My groups';

  @override
  String membres(int n) {
    return '$n members';
  }

  @override
  String get tancarSessio => 'Sign out';

  @override
  String get castigSetmana => 'This week\'s penalty';

  @override
  String get minimMinuts => 'Minimum 30 min for a workout to count';

  @override
  String diesEntrenant(int n) {
    return '$n days trained';
  }

  @override
  String get laTevaSetmana => 'Your week';

  @override
  String get quinEsport => 'Which sport?';

  @override
  String get durada => 'Duration';

  @override
  String get registrarEntreno => 'Log workout';

  @override
  String get comptaMsg => 'Counts!';

  @override
  String get noComptaMsg => 'Min 30 min';

  @override
  String get votarCastig => 'Vote the penalty';

  @override
  String get proposarCastig => 'Propose a new penalty';

  @override
  String get afegirProposta => 'Add proposal';

  @override
  String get rankingTotal => 'All-time ranking';

  @override
  String get historialSetmanes => 'Weekly history';

  @override
  String get perdedor => 'Loser';

  @override
  String get dies => 'days';

  @override
  String get jaRegistratAvui => 'You already logged a valid workout today!';

  @override
  String get entrenoPetit => 'Minimum 30 minutes to count!';

  @override
  String get seleccionaEsport => 'Select a sport!';

  @override
  String get entrenoRegistrat => 'Workout logged! +1 day to ranking';

  @override
  String get setmana => 'Week';
}
