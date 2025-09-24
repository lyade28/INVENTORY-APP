import 'package:flutter/material.dart';
import '../models/inventaire_session.dart';
import '../models/parsed_site.dart';

class InventaireDetailPage extends StatelessWidget {
  final InventaireSession session;
  final List<ParsedSite> parsedSites;

  const InventaireDetailPage({
    super.key,
    required this.session,
    required this.parsedSites,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(session.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: session.scans.length,
        itemBuilder: (context, index) {
          final e = session.scans[index];

          // Supprimer le dernier caractère du code-barres
          final barcodeShort = e.barcode.length > 1
              ? e.barcode.substring(0, e.barcode.length - 1)
              : e.barcode;

          // Limiter le code localisation
          final locShort = e.localisationCode.length > 10
              ? e.localisationCode.substring(0, 10)
              : e.localisationCode;

          // Retrouver le site pour obtenir son âge
          final site = parsedSites.firstWhere(
            (s) => s.code == e.siteCode,
            orElse: () => ParsedSite(
              code: '',
              name: '',
              age: '',
              localisations: [],
            ),
          );

          final age = site.age;

          return ListTile(
            leading: const Icon(Icons.qr_code),
            title: Text("$barcodeShort - $locShort - $age"),
          );
        },
      ),
    );
  }
}
