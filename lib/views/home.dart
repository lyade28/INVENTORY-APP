import 'package:flutter/material.dart';
import '../models/inventaire_session.dart';
import '../services/local_storage_service.dart';
import 'create_inventaire_page.dart';
import 'inventaire_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<InventaireSession> sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final data = await LocalStorageService.getSessions();
    setState(() {
      sessions = data;
    });
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
        builder: (_) => InventaireDetailPage(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventaires")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToCreateInventaire,
        label: const Text("Créer un inventaire"),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return Card(
            child: ListTile(
              title: Text(session.name),
              subtitle: Text("Créé le ${session.createdAt.toLocal()}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openDetail(session),
            ),
          );
        },
      ),
    );
  }
}
