import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sua_o_paga/l10n/app_localizations.dart';

class RankingScreen extends StatelessWidget {
  final String grupoId;

  const RankingScreen({super.key, required this.grupoId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final inicioSemana = _getInicioSemana();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grupos')
          .doc(grupoId)
          .snapshots(),
      builder: (context, snapGrupo) {
        if (!snapGrupo.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        final grupoData = snapGrupo.data!.data() as Map<String, dynamic>;
        final castigo = grupoData['castigoSemana'] ?? '';
        final nombresMiembros =
            Map<String, String>.from(grupoData['nombresMiembros'] ?? {});

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('entrenos')
              .where('grupoId', isEqualTo: grupoId)
              .where('fecha', isGreaterThanOrEqualTo: inicioSemana)
              .snapshots(),
          builder: (context, snapEntrenos) {
            if (!snapEntrenos.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            final Map<String, Set<String>> diesPerUsuari = {};
            for (final doc in snapEntrenos.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final usuariId = data['usuariId'] as String;
              final fecha = (data['fecha'] as Timestamp).toDate();
              final diaKey =
                  '${fecha.year}-${fecha.month}-${fecha.day}';
              diesPerUsuari.putIfAbsent(usuariId, () => {});
              diesPerUsuari[usuariId]!.add(diaKey);
            }

            final ranking = nombresMiembros.entries.map((e) {
              return {
                'uid': e.key,
                'nom': e.value,
                'dies': diesPerUsuari[e.key]?.length ?? 0,
              };
            }).toList();
            ranking.sort((a, b) =>
                (b['dies'] as int).compareTo(a['dies'] as int));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (castigo.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.castigSetmana,
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 11),
                                ),
                                Text(
                                  castigo,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  ...ranking.asMap().entries.map((entry) {
                    final pos = entry.key;
                    final membre = entry.value;
                    final esJo = membre['uid'] == uid;
                    final dies = membre['dies'] as int;
                    final esPerdedor =
                        pos == ranking.length - 1 && ranking.length > 1;
                    final esLider = pos == 0 && dies > 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: esPerdedor
                            ? Colors.red.withOpacity(0.1)
                            : esLider
                                ? Colors.green.withOpacity(0.08)
                                : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: esJo
                            ? Border.all(
                                color: Colors.white.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              pos == 0 ? '🥇' : '${pos + 1}',
                              style: TextStyle(
                                color: pos == 0
                                    ? Colors.amber
                                    : Colors.white54,
                                fontSize: pos == 0 ? 20 : 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                Colors.white.withOpacity(0.1),
                            child: Text(
                              (membre['nom'] as String)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      membre['nom'] as String,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: esJo
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (esJo) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text('tu',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.diesEntrenant(dies),
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (esPerdedor)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('😅',
                                  style: TextStyle(fontSize: 14)),
                            )
                          else if (esLider)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('💪',
                                  style: TextStyle(fontSize: 14)),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      l10n.minimMinuts,
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Timestamp _getInicioSemana() {
    final ara = DateTime.now();
    final dilluns = ara.subtract(Duration(days: ara.weekday - 1));
    final iniciDia = DateTime(dilluns.year, dilluns.month, dilluns.day);
    return Timestamp.fromDate(iniciDia);
  }
}