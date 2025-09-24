class ParsedSite {
  final String code;
  final String name;
  final List<ParsedLocalisation> localisations;

  ParsedSite({
    required this.code,
    required this.name,
    required this.localisations,
  });

  factory ParsedSite.fromJson(Map<String, dynamic> json) {
    return ParsedSite(
      code: json['codeSite'],
      name: json['intSite'],
      localisations: (json['localisations'] as List)
          .map((l) => ParsedLocalisation.fromJson(l))
          .toList(),
    );
  }
}

class ParsedLocalisation {
  final String code;
  final String name;

  ParsedLocalisation({
    required this.code,
    required this.name,
  });

  factory ParsedLocalisation.fromJson(Map<String, dynamic> json) {
    return ParsedLocalisation(
      code: json['clocal'],
      name: json['local'],
    );
  }
}
