import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sua_o_paga/l10n/app_localizations.dart';
import 'ranking_screen.dart';
import 'entrenar_screen.dart';
import 'castig_screen.dart';
import 'historial_screen.dart';

class HomeScreen extends StatefulWidget {
  final String grupoId;
  final String grupoNombre;

  const HomeScreen({
    super.key,
    required this.grupoId,
    required this.grupoNombre,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          widget.grupoNombre,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('grupos')
                .doc(widget.grupoId)
                .snapshots(),
            builder: (context, snapshot) {
              final codigo = snapshot.hasData
                  ? (snapshot.data!.data()
                          as Map<String, dynamic>)['codigoInvitacion'] ??
                      ''
                  : '';
              return IconButton(
                icon: const Icon(Icons.person_add_outlined,
                    color: Colors.white70),
                tooltip: l10n.unirseGrup,
                onPressed: codigo.isEmpty
                    ? null
                    : () {
                        Share.share(
                          '💪 ${l10n.unirseGrup} "${widget.grupoNombre}" a ${l10n.appName}!\n\n${l10n.codiInvitacio}: $codigo\n\n${l10n.slogan} 😅',
                        );
                      },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white38),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _paginaActual,
        children: [
          RankingScreen(grupoId: widget.grupoId),
          EntrenarScreen(grupoId: widget.grupoId),
          CastigScreen(grupoId: widget.grupoId),
          HistorialScreen(grupoId: widget.grupoId),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) => setState(() => _paginaActual = index),
        backgroundColor: const Color(0xFF12122a),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: l10n.ranking,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.timer),
            label: l10n.entrenar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star),
            label: l10n.castig,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.historial,
          ),
        ],
      ),
    );
  }
}