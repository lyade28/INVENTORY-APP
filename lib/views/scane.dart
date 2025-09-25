import 'dart:io';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:file_picker/file_picker.dart';

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
  final Color primaryColor = const  Color(0xFF034A80); 

  @override
  void initState() {
    super.initState();
    _loadSitesFromJson();
  }

  Future<void> _loadSitesFromJson() async {
    try {
      final data = await SiteLoaderService.loadFromAsset();
      setState(() {
        parsedSites = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur chargement asset JSON : $e");
    }
  }

  Future<void> _loadFromFilePicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      try {
        final parsed = await SiteLoaderService.loadFromFile(file);
        setState(() {
          parsedSites = parsed;
          selectedSite = null;
          selectedLocalisation = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fichier JSON chargé avec succès")),
        );
      } catch (e) {
        debugPrint("Erreur de parsing JSON : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fichier invalide")),
        );
      }
    }
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
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Scanner", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadFromFilePicker,
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Charger un fichier JSON"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ParsedSite>(
                    decoration: const InputDecoration(
                      labelText: "Choisir un site",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
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
                      filled: true,
                      fillColor: Colors.white,
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: scanCode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scanner un code"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: scans.isEmpty
                        ? const Center(
                            child: Text("Aucun scan pour le moment."),
                          )
                        : ListView.builder(
                            itemCount: scans.length,
                            itemBuilder: (context, index) {
                              final e = scans[index];
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
                              final barcodeShort = e.barcode.length > 1
                                  ? e.barcode.substring(0, e.barcode.length - 1)
                                  : e.barcode;

                              final locShort = e.localisationCode.length > 10
                                  ? e.localisationCode.substring(0, 10)
                                  : e.localisationCode;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        primaryColor.withOpacity(0.1),
                                    child: const Icon(Icons.qr_code,
                                        color: Colors.black87),
                                  ),
                                  title: Text(
                                    barcodeShort,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text("$locShort - $age",
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ),
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
