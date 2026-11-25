import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sua_o_paga/l10n/app_localizations.dart';

class EntrenarScreen extends StatefulWidget {
  final String grupoId;

  const EntrenarScreen({super.key, required this.grupoId});

  @override
  State<EntrenarScreen> createState() => _EntrenarScreenState();
}

class _EntrenarScreenState extends State<EntrenarScreen> {
  String? _esportSeleccionat;
  int _minuts = 45;
  bool _loading = false;

  final List<Map<String, String>> _esports = [
    {'nom': 'Córrer', 'icon': '🏃'},
    {'nom': 'Bici', 'icon': '🚴'},
    {'nom': 'Natació', 'icon': '🏊'},
    {'nom': 'Gimnàs', 'icon': '💪'},
    {'nom': 'Futbol', 'icon': '⚽'},
    {'nom': 'Bàsquet', 'icon': '🏀'},
    {'nom': 'Tennis', 'icon': '🎾'},
    {'nom': 'Altre', 'icon': '🏅'},
  ];

  Future<void> _registrarEntreno(AppLocalizations l10n) async {
    if (_esportSeleccionat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.seleccionaEsport)),
      );
      return;
    }
    if (_minuts < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.entrenoPetit)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ara = DateTime.now();

      final iniciDia = DateTime(ara.year, ara.month, ara.day);
      final finalDia = iniciDia.add(const Duration(days: 1));

      final entrenoDAvui = await FirebaseFirestore.instance
          .collection('entrenos')
          .where('grupoId', isEqualTo: widget.grupoId)
          .where('usuariId', isEqualTo: uid)
          .where('fecha',
              isGreaterThanOrEqualTo: Timestamp.fromDate(iniciDia))
          .where('fecha', isLessThan: Timestamp.fromDate(finalDia))
          .where('computa', isEqualTo: true)
          .get();

      if (entrenoDAvui.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.jaRegistratAvui)),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('entrenos').add({
        'grupoId': widget.grupoId,
        'usuariId': uid,
        'esport': _esportSeleccionat,
        'minuts': _minuts,
        'computa': _minuts >= 30,
        'fecha': Timestamp.fromDate(ara),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.entrenoRegistrat)),
        );
        setState(() {
          _esportSeleccionat = null;
          _minuts = 45;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ara = DateTime.now();
    final iniciSetmana = ara.subtract(Duration(days: ara.weekday - 1));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('entrenos')
                .where('grupoId', isEqualTo: widget.grupoId)
                .where('usuariId', isEqualTo: uid)
                .where('computa', isEqualTo: true)
                .where('fecha',
                    isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                        iniciSetmana.year,
                        iniciSetmana.month,
                        iniciSetmana.day)))
                .snapshots(),
            builder: (context, snapshot) {
              final dies = snapshot.data?.docs.length ?? 0;

              final Set<int> diesEntrenats = {};
              if (snapshot.hasData) {
                for (final doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fecha = (data['fecha'] as Timestamp).toDate();
                  diesEntrenats.add(fecha.weekday);
                }
              }

              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.laTevaSetmana,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          l10n.diesEntrenant(dies),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Dl', 'Dm', 'Dc', 'Dj', 'Dv', 'Ds', 'Dg']
                          .asMap()
                          .entries
                          .map((e) {
                        final diaNum = e.key + 1;
                        final label = e.value;
                        final entrenat = diesEntrenats.contains(diaNum);
                        final esAvui = ara.weekday == diaNum;

                        return Column(
                          children: [
                            Text(label,
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11)),
                            const SizedBox(height: 4),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: entrenat
                                    ? Colors.green
                                    : Colors.white.withOpacity(0.08),
                                border: esAvui
                                    ? Border.all(
                                        color: Colors.white54,
                                        width: 1.5)
                                    : null,
                              ),
                              child: Center(
                                child: entrenat
                                    ? const Text('✓',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14))
                                    : Text('$diaNum',
                                        style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11)),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quinEsport,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: _esports.map((esport) {
                    final seleccionat =
                        _esportSeleccionat == esport['nom'];
                    return GestureDetector(
                      onTap: () => setState(
                          () => _esportSeleccionat = esport['nom']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: seleccionat
                              ? Colors.white
                              : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(esport['icon']!,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(
                              esport['nom']!,
                              style: TextStyle(
                                color: seleccionat
                                    ? const Color(0xFF1a1a2e)
                                    : Colors.white54,
                                fontSize: 10,
                                fontWeight: seleccionat
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.durada,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => setState(
                          () => _minuts = (_minuts - 15).clamp(15, 300)),
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.white54, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          '$_minuts min',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _minuts >= 30
                              ? '✅ ${l10n.comptaMsg}'
                              : '❌ ${l10n.noComptaMsg}',
                          style: TextStyle(
                            color: _minuts >= 30
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () => setState(
                          () => _minuts = (_minuts + 15).clamp(15, 300)),
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.white54, size: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _loading ? null : () => _registrarEntreno(l10n),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1a1a2e),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF1a1a2e)),
                  )
                : Text(
                    l10n.registrarEntreno,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }
}