// Simple and compatible Flutter client for the Cambridge API
// JSON serialization is done manually for wide compatibility

import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://172.25.43.81:8000';

// ------------------------ MODELS ------------------------

class HealthResponse {
  final String status;
  final String timestamp;
  final String version;

  HealthResponse({required this.status, required this.timestamp, required this.version});

  factory HealthResponse.fromJson(Map<String, dynamic> json) => HealthResponse(
        status: json['status'],
        timestamp: json['timestamp'],
        version: json['version'],
      );
}

class AddCaseRequest {
  final String userPrompt;

  AddCaseRequest(this.userPrompt);

  Map<String, dynamic> toJson() => {'user_prompt': userPrompt};
}

class GenDraftRequest {
  final String caseId;

  GenDraftRequest(this.caseId);

  Map<String, dynamic> toJson() => {'case_id': caseId};
}

class GenDraftResponse {
  final String text;

  GenDraftResponse(this.text);

  factory GenDraftResponse.fromJson(Map<String, dynamic> json) => GenDraftResponse(json['text']);
}

class Argument {
  final String argument;
  final List<CaseReference> caseReferences;

  Argument({required this.argument, required this.caseReferences});

  factory Argument.fromJson(Map<String, dynamic> json) => Argument(
        argument: json['argument'],
        caseReferences: (json['case_references'] as List)
            .map((e) => CaseReference.fromJson(e))
            .toList(),
      );
}

class CaseReference {
  final String caseIdentifier;
  final String title;
  final String? date;
  final double matchingDegree;
  final String sourcefileRawMd;

  CaseReference({
    required this.caseIdentifier,
    required this.title,
    this.date,
    required this.matchingDegree,
    required this.sourcefileRawMd,
  });

  factory CaseReference.fromJson(Map<String, dynamic> json) => CaseReference(
        caseIdentifier: json['caseIdentifier'],
        title: json['title'],
        date: json['Date'],
        matchingDegree: json['matchingDegree'].toDouble(),
        sourcefileRawMd: json['sourcefile_raw_md'],
      );
}

class AnalysisResponse {
  final String caseId;
  final List<Argument> strengths;
  final List<Argument> weaknesses;

  AnalysisResponse({
    required this.caseId,
    required this.strengths,
    required this.weaknesses,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) => AnalysisResponse(
        caseId: json['caseId'],
        strengths: (json['strengths'] as List).map((e) => Argument.fromJson(e)).toList(),
        weaknesses: (json['weaknesses'] as List).map((e) => Argument.fromJson(e)).toList(),
      );
}

class ErrorResponse {
  final String error;
  final String code;

  ErrorResponse({required this.error, required this.code});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
        error: json['error'],
        code: json['code'],
      );
}

// ------------------------ API CLIENT ------------------------

class CambridgeApi {
  static Future<HealthResponse> getHealth() async {
    final res = await http.get(Uri.parse('$baseUrl/health'));
    if (res.statusCode == 200) {
      return HealthResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Health check failed');
    }
  }

  static Future<AnalysisResponse> addCase(AddCaseRequest req) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/add_case'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200) {
      return AnalysisResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Add case failed: ${res.body}');
    }
  }

  static Future<GenDraftResponse> genDraft(GenDraftRequest req) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/gen_draft'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );

    if (res.statusCode == 200) {
      return GenDraftResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Draft generation failed: ${res.body}');
    }
  }
}

// ------------------------ USAGE EXAMPLE ------------------------
// final health = await CambridgeApi.getHealth();
// final analysis = await CambridgeApi.addCase(AddCaseRequest("My employer fired me unfairly."));
// final draft = await CambridgeApi.genDraft(GenDraftRequest("CASE-2024-001"));
