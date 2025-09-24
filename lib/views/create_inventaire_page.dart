import 'package:flutter/material.dart';
import 'package:inventaire/views/scane.dart';
import 'package:uuid/uuid.dart';
import '../models/inventaire_session.dart';
import '../services/local_storage_service.dart';

class CreateInventairePage extends StatefulWidget {
  const CreateInventairePage({super.key});

  @override
  State<CreateInventairePage> createState() => _CreateInventairePageState();
}

class _CreateInventairePageState extends State<CreateInventairePage> {
  final TextEditingController nameController = TextEditingController();

  Future<void> createSession() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final session = InventaireSession(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
      scans: [],
    );

    final sessions = await LocalStorageService.getSessions();
    sessions.add(session);
    await LocalStorageService.saveSessions(sessions);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScanPage(sessionId: session.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un inventaire")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nom de l'inventaire",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: createSession,
              child: const Text("Commencer l'inventaire"),
            ),
          ],
        ),
      ),
    );
  }
}
