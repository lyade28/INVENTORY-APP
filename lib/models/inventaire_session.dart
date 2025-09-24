import 'scan_entry.dart';

class InventaireSession {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<ScanEntry> scans;

  InventaireSession({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.scans,
  });
}
