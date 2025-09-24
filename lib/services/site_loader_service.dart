// services/site_loader_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/parsed_site.dart';

class SiteLoaderService {
  static Future<List<ParsedSite>> loadFromAsset() async {
    final rawJson = await rootBundle.loadString('assets/sites_localisations.json');
    return _parseJson(rawJson);
  }

  static Future<List<ParsedSite>> loadFromFile(File file) async {
    final rawJson = await file.readAsString();
    return _parseJson(rawJson);
  }

  static List<ParsedSite> _parseJson(String jsonString) {
    final List<dynamic> data = json.decode(jsonString);
    return data.map((e) => ParsedSite.fromJson(e)).toList();
  }
}
