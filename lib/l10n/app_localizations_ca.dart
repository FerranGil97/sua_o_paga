// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appName => 'SuaOPaga';

  @override
  String get slogan => 'Sua o paga les conseqüències';

  @override
  String get entrarGoogle => 'Entrar amb Google';

  @override
  String get ranking => 'Ranking';

  @override
  String get entrenar => 'Entrenar';

  @override
  String get castig => 'Càstig';

  @override
  String get historial => 'Historial';

  @override
  String get crearGrup => 'Crear un grup nou';

  @override
  String get unirseGrup => 'Unir-se a un grup';

  @override
  String get nomGrup => 'Nom del grup';

  @override
  String get codiInvitacio => 'Codi d\'invitació';

  @override
  String get crearBtn => 'Crear grup';

  @override
  String get unirseBtn => 'Unir-se';

  @override
  String get elsMeusGrups => 'Els meus grups';

  @override
  String membres(int n) {
    return '$n membres';
  }

  @override
  String get tancarSessio => 'Tancar sessió';

  @override
  String get castigSetmana => 'Càstig d\'aquesta setmana';

  @override
  String get minimMinuts => 'Mínim 30 min per comptar un entrenament';

  @override
  String diesEntrenant(int n) {
    return '$n dies entrenats';
  }

  @override
  String get laTevaSetmana => 'La teva setmana';

  @override
  String get quinEsport => 'Quin esport?';

  @override
  String get durada => 'Durada';

  @override
  String get registrarEntreno => 'Registrar entreno';

  @override
  String get comptaMsg => 'Compta!';

  @override
  String get noComptaMsg => 'Mínim 30 min';

  @override
  String get votarCastig => 'Vota el càstig';

  @override
  String get proposarCastig => 'Proposar un càstig nou';

  @override
  String get afegirProposta => 'Afegir proposta';

  @override
  String get rankingTotal => 'Ranking total';

  @override
  String get historialSetmanes => 'Historial per setmanes';

  @override
  String get perdedor => 'Perdedor';

  @override
  String get dies => 'dies';

  @override
  String get jaRegistratAvui => 'Ja has registrat un entreno vàlid avui!';

  @override
  String get entrenoPetit => 'Mínim 30 minuts per comptar!';

  @override
  String get seleccionaEsport => 'Selecciona un esport!';

  @override
  String get entrenoRegistrat => 'Entreno registrat! +1 dia al ranking';

  @override
  String get setmana => 'Setmana';
}
