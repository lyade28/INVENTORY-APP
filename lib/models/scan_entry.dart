class ScanEntry {
  final String barcode;
  final String siteCode;
  final String localisationCode;

  ScanEntry({
    required this.barcode,
    required this.siteCode,
    required this.localisationCode,
  });

  @override
  String toString() => "$barcode$localisationCode";
}
