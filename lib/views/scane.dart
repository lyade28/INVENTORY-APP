import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/scan_entry.dart';
import '../models/parsed_site.dart';
import '../services/local_storage_service.dart';
import '../services/site_loader_service.dart';

class ScanPage extends StatefulWidget {
  final String sessionId;

  const ScanPage({super.key, required this.sessionId});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<ScanEntry> scans = [];

  List<ParsedSite> parsedSites = [];
  ParsedSite? selectedSite;
  ParsedLocalisation? selectedLocalisation;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSitesFromJson();
  }

  Future<void> _loadSitesFromJson() async {
    final data = await SiteLoaderService.loadSitesFromAsset();
    setState(() {
      parsedSites = data;
      isLoading = false;
    });
  }

  Future<void> scanCode() async {
    if (selectedSite == null || selectedLocalisation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner un site et une localisation"),
        ),
      );
      return;
    }

    final result = await BarcodeScanner.scan();
    final code = result.rawContent;
    if (code.isEmpty) return;

    final entry = ScanEntry(
      barcode: code,
      siteCode: selectedSite!.code,
      localisationCode: selectedLocalisation!.code,
    );

    await LocalStorageService.addScanToSession(widget.sessionId, entry);

    setState(() {
      scans.add(entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<ParsedLocalisation> filteredLocs =
        selectedSite?.localisations ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Scanner")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<ParsedSite>(
                    decoration: const InputDecoration(
                      labelText: "Choisir un site",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSite,
                    items: parsedSites
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text("${s.code} - ${s.name}"),
                            ))
                        .toList(),
                    onChanged: (s) => setState(() {
                      selectedSite = s;
                      selectedLocalisation = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ParsedLocalisation>(
                    decoration: const InputDecoration(
                      labelText: "Choisir une localisation",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedLocalisation,
                    items: filteredLocs
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text("${l.code} - ${l.name}"),
                            ))
                        .toList(),
                    onChanged: (l) => setState(() => selectedLocalisation = l),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: scanCode,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scanner"),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scans.length,
                      itemBuilder: (context, index) {
                        final e = scans[index];
                        final locShort = e.localisationCode.length > 10
                            ? e.localisationCode.substring(0, 10)
                            : e.localisationCode;

                        return ListTile(
                          leading: const Icon(Icons.qr_code),
                          title: Text(e.barcode),
                          subtitle:
                              Text("${e.barcode} - $locShort - ${e.siteCode}"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
