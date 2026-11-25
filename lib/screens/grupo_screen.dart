import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:sua_o_paga/l10n/app_localizations.dart';

class GrupoScreen extends StatefulWidget {
  const GrupoScreen({super.key});

  @override
  State<GrupoScreen> createState() => _GrupoScreenState();
}

class _GrupoScreenState extends State<GrupoScreen> {
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  bool _loading = false;

  String _generarCodigo() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _crearGrupo() async {
    if (_nombreController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final nombre = FirebaseAuth.instance.currentUser!.displayName ?? 'Usuari';
      final codigo = _generarCodigo();
      await FirebaseFirestore.instance.collection('grupos').add({
        'nombre': _nombreController.text.trim(),
        'codigoInvitacion': codigo,
        'creadorId': uid,
        'miembros': [uid],
        'nombresMiembros': {uid: nombre},
        'castigoSemana': '',
        'creadoEn': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grup creat! Codi: $codigo')),
        );
        _nombreController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _unirseGrupo() async {
    if (_codigoController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final nombre = FirebaseAuth.instance.currentUser!.displayName ?? 'Usuari';
      final codigo = _codigoController.text.trim().toUpperCase();
      final query = await FirebaseFirestore.instance
          .collection('grupos')
          .where('codigoInvitacion', isEqualTo: codigo)
          .get();
      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Codi incorrecte. Torna-ho a provar!')),
          );
        }
        return;
      }
      final grupoDoc = query.docs.first;
      await grupoDoc.reference.update({
        'miembros': FieldValue.arrayUnion([uid]),
        'nombresMiembros.$uid': nombre,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('T\'has unit al grup!')),
        );
        _codigoController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // CREAR GRUP
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.crearGrup,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nombreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.nomGrup,
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _crearGrupo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1a1a2e),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.crearBtn,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text('— o —',
                    style: TextStyle(color: Colors.white38)),
              ),
              const SizedBox(height: 16),

              // UNIR-SE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.unirseGrup,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _codigoController,
                      style: const TextStyle(
                          color: Colors.white,
                          letterSpacing: 4,
                          fontSize: 18),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: l10n.codiInvitacio,
                        hintStyle: const TextStyle(
                            color: Colors.white38, letterSpacing: 1),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loading ? null : _unirseGrupo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1a1a2e),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.unirseBtn,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(l10n.elsMeusGrups,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('grupos')
                    .where('miembros', arrayContains: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  final grupos = snapshot.data!.docs;
                  if (grupos.isEmpty) {
                    return Text(
                      'Encara no ets a cap grup.\nCrea\'n un o uneix-te amb un codi!',
                      style: const TextStyle(color: Colors.white38),
                      textAlign: TextAlign.center,
                    );
                  }
                  return Column(
                    children: grupos.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final membres = (data['miembros'] as List).length;
                      final codigo = data['codigoInvitacion'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['nombre'] ?? '',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.membres(membres),
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(codigo,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Text(l10n.tancarSessio,
                    style: const TextStyle(color: Colors.white38)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}