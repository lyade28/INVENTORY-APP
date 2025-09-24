import 'package:flutter/material.dart';
import '../models/inventaire_session.dart';

class InventaireDetailPage extends StatelessWidget {
  final InventaireSession session;

  const InventaireDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(session.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: session.scans.length,
        itemBuilder: (context, index) {
          final e = session.scans[index];
          return ListTile(
            leading: const Icon(Icons.qr_code),
            title: Text(e.barcode),
            subtitle: Text("${e.siteCode} - ${e.localisationCode}"),
          );
        }, 
      ),
    );
  }
}
