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
  final Color primaryColor = const Color(0xFF1E2A38); // Bleu sombre

  Future<void> createSession() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un nom.")),
      );
      return;
    }

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
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Créer un inventaire",
            style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2,
                      size: 60, color: Color(0xFF1E2A38)),
                  const SizedBox(height: 16),
                  const Text(
                    "Nouveau inventaire",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nom de l'inventaire",
                      prefixIcon: const Icon(Icons.edit),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: createSession,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Commencer l'inventaire"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
