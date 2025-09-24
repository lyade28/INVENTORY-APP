// services/site_loader_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/parsed_site.dart';

class SiteLoaderService {
  static Future<List<ParsedSite>> loadSitesFromAsset() async {
    final rawJson = await rootBundle.loadString('assets/sites_localisations.json');
    final List<dynamic> data = json.decode(rawJson);
    return data.map((e) => ParsedSite.fromJson(e)).toList();
  }
}
