class Site {
  final String code;
  final String name;

  Site({required this.code, required this.name});

  factory Site.fromRawString(String raw) {
    return Site(
      code: raw.substring(0, 5),
      name: raw.substring(5).trim(),
    );
  }

  @override
  String toString() => "$code$name";
}
