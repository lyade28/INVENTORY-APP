class Localisation {
  final String codeSite;
  final String code;
  final String name;

  Localisation({
    required this.codeSite,
    required this.code,
    required this.name,
  });

  factory Localisation.fromRawString(String raw) {
    final codeSite = raw.substring(0, 5);
    final code = raw.substring(5, 18).trim();
    final name = raw.substring(18).trim();
    return Localisation(
      codeSite: codeSite,
      code: code,
      name: name,
    );
  }

  @override
  String toString() => "$code $name";
}
