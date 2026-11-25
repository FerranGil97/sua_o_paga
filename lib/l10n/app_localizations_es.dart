// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SuaOPaga';

  @override
  String get slogan => 'Suda o paga las consecuencias';

  @override
  String get entrarGoogle => 'Entrar con Google';

  @override
  String get ranking => 'Ranking';

  @override
  String get entrenar => 'Entrenar';

  @override
  String get castig => 'Castigo';

  @override
  String get historial => 'Historial';

  @override
  String get crearGrup => 'Crear un grupo nuevo';

  @override
  String get unirseGrup => 'Unirse a un grupo';

  @override
  String get nomGrup => 'Nombre del grupo';

  @override
  String get codiInvitacio => 'Código de invitación';

  @override
  String get crearBtn => 'Crear grupo';

  @override
  String get unirseBtn => 'Unirse';

  @override
  String get elsMeusGrups => 'Mis grupos';

  @override
  String membres(int n) {
    return '$n miembros';
  }

  @override
  String get tancarSessio => 'Cerrar sesión';

  @override
  String get castigSetmana => 'Castigo de esta semana';

  @override
  String get minimMinuts => 'Mínimo 30 min para contar un entrenamiento';

  @override
  String diesEntrenant(int n) {
    return '$n días entrenados';
  }

  @override
  String get laTevaSetmana => 'Tu semana';

  @override
  String get quinEsport => '¿Qué deporte?';

  @override
  String get durada => 'Duración';

  @override
  String get registrarEntreno => 'Registrar entrenamiento';

  @override
  String get comptaMsg => '¡Cuenta!';

  @override
  String get noComptaMsg => 'Mínimo 30 min';

  @override
  String get votarCastig => 'Vota el castigo';

  @override
  String get proposarCastig => 'Proponer un castigo nuevo';

  @override
  String get afegirProposta => 'Añadir propuesta';

  @override
  String get rankingTotal => 'Ranking total';

  @override
  String get historialSetmanes => 'Historial por semanas';

  @override
  String get perdedor => 'Perdedor';

  @override
  String get dies => 'días';

  @override
  String get jaRegistratAvui =>
      '¡Ya has registrado un entrenamiento válido hoy!';

  @override
  String get entrenoPetit => '¡Mínimo 30 minutos para contar!';

  @override
  String get seleccionaEsport => '¡Selecciona un deporte!';

  @override
  String get entrenoRegistrat => '¡Entrenamiento registrado! +1 día al ranking';

  @override
  String get setmana => 'Semana';
}
