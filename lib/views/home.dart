import 'package:flutter/material.dart';
import 'package:inventaire/views/scane.dart';
import '../models/inventaire_session.dart';
import '../services/local_storage_service.dart';
import 'create_inventaire_page.dart';
import 'inventaire_detail_page.dart';
import '../services/site_loader_service.dart';
import '../models/parsed_site.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<InventaireSession> sessions = [];
  List<ParsedSite> parsedSites = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
    loadParsedSites();
  }

  Future<void> loadSessions() async {
    final data = await LocalStorageService.getSessions();
    setState(() {
      sessions = data;
    });
  }

  Future<void> loadParsedSites() async {
    parsedSites = await SiteLoaderService.loadFromAsset();
  }

  void navigateToCreateInventaire() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateInventairePage()),
    );
    await loadSessions();
  }

  void openDetail(InventaireSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventaireDetailPage(
          session: session,
          parsedSites: parsedSites,
        ),
      ),
    );
  }

  void continueSession(InventaireSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanPage(sessionId: session.id),
      ),
    );
  }

  Future<void> deleteSession(InventaireSession session) async {
    await LocalStorageService.removeSession(session.id);
    await loadSessions();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inventaire supprimé")),
    );
  }

  Future<void> exportSession(InventaireSession session) async {
    final buffer = StringBuffer();
    for (final e in session.scans) {
      final matchingSite = parsedSites.firstWhere(
        (s) => s.code == e.siteCode,
        orElse: () =>
            ParsedSite(code: '', name: '', age: '', localisations: []),
      );

      final age = matchingSite.age;
      buffer.writeln("${e.barcode}${e.localisationCode}$age");
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${session.name}.txt');
    await file.writeAsString(buffer.toString());

    Share.shareXFiles([XFile(file.path)], text: 'Export ${session.name}');
  }

  Future<void> exportAllSessions() async {
    final allSessions = await LocalStorageService.getSessions();

    if (allSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun inventaire à exporter")),
      );
      return;
    }

    final buffer = StringBuffer();

    for (final session in allSessions) {
      buffer.writeln("### ${session.name} ###");

      for (final e in session.scans) {
        final site = parsedSites.firstWhere(
          (s) => s.code == e.siteCode,
          orElse: () =>
              ParsedSite(code: '', name: '', age: '', localisations: []),
        );
        final age = site.age;
        buffer.writeln("${e.barcode}${e.localisationCode}$age");
      }

      buffer.writeln(); // saut de ligne entre les sessions
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/inventaire_global.txt');
    await file.writeAsString(buffer.toString());

    Share.shareXFiles([XFile(file.path)],
        text: 'Export global des inventaires');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventaires"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "Exporter tout",
            onPressed: exportAllSessions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToCreateInventaire,
        label: const Text("Créer un inventaire"),
        icon: const Icon(Icons.add),
      ),
      body: sessions.isEmpty
          ? const Center(child: Text("Aucun inventaire"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  child: ListTile(
                    title: Text(session.name),
                    subtitle: Text(
                        "Créé le ${session.createdAt.toLocal().toString().split('.')[0]}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'delete':
                            deleteSession(session);
                            break;
                          case 'export':
                            exportSession(session);
                            break;
                          case 'continue':
                            continueSession(session);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'continue',
                          child: Text("Continuer"),
                        ),
                        const PopupMenuItem(
                          value: 'export',
                          child: Text("Exporter"),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text("Supprimer"),
                        ),
                      ],
                    ),
                    onTap: () => openDetail(session),
                  ),
                );
              },
            ),
    );
  }
}
