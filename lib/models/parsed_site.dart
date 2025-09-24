class ParsedSite {
  final String code;
  final String name;
  final String age;
  final List<ParsedLocalisation> localisations;

  ParsedSite({
    required this.code,
    required this.name,
    required this.age,
    required this.localisations,
  });

  factory ParsedSite.fromJson(Map<String, dynamic> json) {
    return ParsedSite(
      code: json['codeSite'],
      name: json['intSite'],
      age: json['age'].toString(),
      localisations: (json['localisations'] as List)
          .map((e) => ParsedLocalisation.fromJson(e))
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
