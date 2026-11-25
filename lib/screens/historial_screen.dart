import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sua_o_paga/l10n/app_localizations.dart';

class HistorialScreen extends StatelessWidget {
  final String grupoId;

  const HistorialScreen({super.key, required this.grupoId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('grupos')
          .doc(grupoId)
          .snapshots(),
      builder: (context, snapGrup) {
        if (!snapGrup.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        final grupoData = snapGrup.data!.data() as Map<String, dynamic>;
        final nombresMiembros =
            Map<String, String>.from(grupoData['nombresMiembros'] ?? {});

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('entrenos')
              .where('grupoId', isEqualTo: grupoId)
              .where('computa', isEqualTo: true)
              .orderBy('fecha', descending: true)
              .snapshots(),
          builder: (context, snapEntrenos) {
            if (!snapEntrenos.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }

            final entrenos = snapEntrenos.data!.docs;

            final Map<String, int> totalDiesPerUsuari = {};
            for (final doc in entrenos) {
              final data = doc.data() as Map<String, dynamic>;
              final usuariId = data['usuariId'] as String;
              totalDiesPerUsuari[usuariId] =
                  (totalDiesPerUsuari[usuariId] ?? 0) + 1;
            }

            final rankingTotal = nombresMiembros.entries.map((e) {
              return {
                'uid': e.key,
                'nom': e.value,
                'dies': totalDiesPerUsuari[e.key] ?? 0,
              };
            }).toList();
            rankingTotal.sort((a, b) =>
                (b['dies'] as int).compareTo(a['dies'] as int));

            final Map<String, List<QueryDocumentSnapshot>> perSetmana = {};
            for (final doc in entrenos) {
              final data = doc.data() as Map<String, dynamic>;
              final fecha = (data['fecha'] as Timestamp).toDate();
              final dilluns =
                  fecha.subtract(Duration(days: fecha.weekday - 1));
              final clau =
                  '${dilluns.year}-${dilluns.month.toString().padLeft(2, '0')}-${dilluns.day.toString().padLeft(2, '0')}';
              perSetmana.putIfAbsent(clau, () => []);
              perSetmana[clau]!.add(doc);
            }

            final setmanes = perSetmana.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ranking total
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.rankingTotal,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ...rankingTotal.asMap().entries.map((entry) {
                          final pos = entry.key;
                          final membre = entry.value;
                          final esJo = membre['uid'] == uid;
                          final dies = membre['dies'] as int;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    pos == 0
                                        ? '🥇'
                                        : pos == 1
                                            ? '🥈'
                                            : pos == 2
                                                ? '🥉'
                                                : '${pos + 1}',
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    membre['nom'] as String,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: esJo
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$dies ${l10n.dies}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Historial per setmanes
                  Text(
                    l10n.historialSetmanes,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  if (setmanes.isEmpty)
                    Center(
                      child: Text(
                        'Encara no hi ha entrenos registrats!',
                        style:
                            const TextStyle(color: Colors.white38),
                      ),
                    ),

                  ...setmanes.map((clauSetmana) {
                    final entrenosSetmana = perSetmana[clauSetmana]!;

                    final Map<String, Set<String>> diesPerUsuari = {};
                    for (final doc in entrenosSetmana) {
                      final data = doc.data() as Map<String, dynamic>;
                      final usuariId = data['usuariId'] as String;
                      final fecha =
                          (data['fecha'] as Timestamp).toDate();
                      final diaKey =
                          '${fecha.year}-${fecha.month}-${fecha.day}';
                      diesPerUsuari.putIfAbsent(usuariId, () => {});
                      diesPerUsuari[usuariId]!.add(diaKey);
                    }

                    String? perdedorId;
                    int minDies = 999;
                    for (final entry in nombresMiembros.entries) {
                      final dies =
                          diesPerUsuari[entry.key]?.length ?? 0;
                      if (dies < minDies) {
                        minDies = dies;
                        perdedorId = entry.key;
                      }
                    }

                    final parts = clauSetmana.split('-');
                    final dilluns = DateTime(
                        int.parse(parts[0]),
                        int.parse(parts[1]),
                        int.parse(parts[2]));
                    final diumenge =
                        dilluns.add(const Duration(days: 6));
                    final etiqueta =
                        '${dilluns.day}/${dilluns.month} – ${diumenge.day}/${diumenge.month}';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        title: Text(
                          '${l10n.setmana} $etiqueta',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: perdedorId != null
                            ? Text(
                                '😅 ${l10n.perdedor}: ${nombresMiembros[perdedorId] ?? ''}',
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              )
                            : null,
                        iconColor: Colors.white38,
                        collapsedIconColor: Colors.white38,
                        children: nombresMiembros.entries.map((e) {
                          final dies =
                              diesPerUsuari[e.key]?.length ?? 0;
                          final esJo = e.key == uid;
                          final esPerdedor = e.key == perdedorId;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.1),
                                  child: Text(
                                    e.value
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: esJo
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$dies ${l10n.dies}',
                                  style: TextStyle(
                                    color: esPerdedor
                                        ? Colors.red
                                        : Colors.white54,
                                    fontSize: 13,
                                    fontWeight: esPerdedor
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (esPerdedor)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Text('😅',
                                        style:
                                            TextStyle(fontSize: 14)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}