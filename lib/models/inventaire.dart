class InventaireSession {
  final String site;
  final String localisation;
  final List<String> codes;

  InventaireSession({
    required this.site,
    required this.localisation,
    required this.codes,
  });

  Map<String, dynamic> toMap() => {
        'site': site,
        'localisation': localisation,
        'codes': codes,
      };

  factory InventaireSession.fromMap(Map<String, dynamic> map) {
    return InventaireSession(
      site: map['site'],
      localisation: map['localisation'],
      codes: List<String>.from(map['codes']),
    );
  }
}