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
    final Color primaryColor = const  Color(0xFF034A80); // Bleu foncé

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(session.name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: session.scans.isEmpty
          ? const Center(child: Text("Aucun élément scanné."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: session.scans.length,
              itemBuilder: (context, index) {
                final e = session.scans[index];

                final barcodeShort = e.barcode.length > 1
                    ? e.barcode.substring(0, e.barcode.length - 1)
                    : e.barcode;

                final locShort = e.localisationCode.length > 10
                    ? e.localisationCode.substring(0, 10)
                    : e.localisationCode;

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

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.qr_code, color: Colors.black87),
                    ),
                    title: Text(
                      barcodeShort,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "$locShort",
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        age,
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
