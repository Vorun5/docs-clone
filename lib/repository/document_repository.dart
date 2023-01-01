import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:http/http.dart';

final documentRepositoryProvider = Provider(
  (_) => DocumentRepository(
    client: Client(),
  ),
);

class DocumentRepository {
  final Client _client;

  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    var error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );

    try {
      final response = await _client.post(
        Uri.parse('$host/doc/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        }),
      );
      switch (response.statusCode) {
        case HttpStatus.ok:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(jsonDecode(response.body)),
          );
          break;
        default:
          error = ErrorModel(
            error: response.body,
            data: null,
          );
      }
    } catch (e) {
      ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  Future<ErrorModel> getDocumentById({
    required String token,
    required String id,
  }) async {
    var error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );
    try {
      final response = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (response.statusCode) {
        case HttpStatus.ok:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(jsonDecode(response.body)),
          );
          break;
        default:
          throw 'This Document does not exist, please create a new one';
      }
    } catch (e) {
      ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  Future<void> updateDocumentTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    await _client.post(
      Uri.parse('$host/doc/title'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({
        'id': id,
        'title': title,
      }),
    );
  }

  Future<ErrorModel> getDocuemnts(String token) async {
    var error = ErrorModel(
      error: 'Some unexpected error occurred.',
      data: null,
    );

    try {
      final response = await _client.get(
        Uri.parse('$host/docs/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      switch (response.statusCode) {
        case HttpStatus.ok:
          List<DocumentModel> documents = [];
          for (int i = 0; i < jsonDecode(response.body).length; i++) {
            documents.add(DocumentModel.fromJson(jsonDecode(response.body)[i]));
          }
          error = ErrorModel(
            error: null,
            data: documents,
          );
          break;
        default:
          error = ErrorModel(
            error: response.body,
            data: null,
          );
      }
    } catch (e) {
      ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }
}
