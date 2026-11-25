import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sua_o_paga/l10n/app_localizations.dart';

class CastigScreen extends StatefulWidget {
  final String grupoId;

  const CastigScreen({super.key, required this.grupoId});

  @override
  State<CastigScreen> createState() => _CastigScreenState();
}

class _CastigScreenState extends State<CastigScreen> {
  final _novaPropostaController = TextEditingController();
  bool _loading = false;

  Future<void> _proposarCastig(String proposta) async {
    if (proposta.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('castigs').add({
        'grupoId': widget.grupoId,
        'text': proposta.trim(),
        'vots': [],
        'creadoEn': FieldValue.serverTimestamp(),
      });
      _novaPropostaController.clear();
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

  Future<void> _votar(String castigId, List<dynamic> votsActuals) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final jaHaVotat = votsActuals.contains(uid);
    try {
      await FirebaseFirestore.instance
          .collection('castigs')
          .doc(castigId)
          .update({
        'vots': jaHaVotat
            ? FieldValue.arrayRemove([uid])
            : FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _seleccionarCastigGuanyador(
      String castigId, String text) async {
    try {
      await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.grupoId)
          .update({'castigoSemana': text});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Càstig de la setmana actualitzat!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('castigs')
          .where('grupoId', isEqualTo: widget.grupoId)
          .orderBy('creadoEn', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        final castigs = snapshot.data!.docs;
        final totalMembres = 5;

        final castigsOrdenats = [...castigs];
        castigsOrdenats.sort((a, b) {
          final votsA =
              ((a.data() as Map<String, dynamic>)['vots'] as List).length;
          final votsB =
              ((b.data() as Map<String, dynamic>)['vots'] as List).length;
          return votsB.compareTo(votsA);
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('grupos')
                    .doc(widget.grupoId)
                    .snapshots(),
                builder: (context, snapGrup) {
                  final castigActual = snapGrup.hasData
                      ? (snapGrup.data!.data()
                              as Map<String, dynamic>)['castigoSemana'] ??
                          ''
                      : '';

                  if (castigActual.isEmpty) return const SizedBox();

                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.castigSetmana,
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                castigActual,
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
                  );
                },
              ),

              Text(
                l10n.votarCastig,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'El més votat serà el càstig de la setmana',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 12),

              if (castigs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Encara no hi ha propostes.\nAfegeix la primera!',
                    style: const TextStyle(color: Colors.white38),
                    textAlign: TextAlign.center,
                  ),
                ),

              ...castigsOrdenats.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final vots = (data['vots'] as List? ?? []);
                final numVots = vots.length;
                final jaHaVotat = vots.contains(uid);
                final esElMesVotat = castigsOrdenats.isNotEmpty &&
                    doc.id == castigsOrdenats.first.id &&
                    numVots > 0;

                return GestureDetector(
                  onTap: () => _votar(doc.id, vots),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: jaHaVotat
                          ? Colors.green.withOpacity(0.1)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: jaHaVotat
                            ? Colors.green.withOpacity(0.4)
                            : esElMesVotat
                                ? Colors.amber.withOpacity(0.3)
                                : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['text'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                            if (esElMesVotat)
                              const Text('🥇',
                                  style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: jaHaVotat
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                jaHaVotat ? '✓ $numVots' : '$numVots',
                                style: TextStyle(
                                  color: jaHaVotat
                                      ? Colors.green
                                      : Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalMembres > 0
                                ? numVots / totalMembres
                                : 0,
                            backgroundColor:
                                Colors.white.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              jaHaVotat
                                  ? Colors.green
                                  : Colors.white38,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.proposarCastig,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _novaPropostaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ex: Pagar les copes del dissabte...',
                        hintStyle:
                            const TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () => _proposarCastig(
                              _novaPropostaController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1a1a2e),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.afegirProposta,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}