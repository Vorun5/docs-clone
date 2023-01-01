import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/models/user_model.dart';
import 'package:google_docs_clone/repository/local_storage_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authResitoryProvider = Provider(
  (_) => AuthRepository(
    googleSignIn: GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    ),
    client: Client(),
    localStorageRepository: LocalStorageRepository(),
  ),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;

  AuthRepository(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageRepository localStorageRepository})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    var error = ErrorModel(
      error: 'Some unecpected error occurred.',
      data: null,
    );

    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName ?? 'Anonimys',
          photoUrl: user.photoUrl ?? '',
          uid: '',
          token: '',
        );
        final response = await _client.post(
          Uri.parse('$host/api/signup'),
          body: jsonEncode(userAcc.toJson()),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        switch (response.statusCode) {
          case HttpStatus.ok:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(response.body)['user']['_id'],
              token: jsonDecode(response.body)['token'],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }

    return error;
  }

  Future<ErrorModel> getUserData() async {
    var error = ErrorModel(
      error: 'Some unecpected error occurred.',
      data: null,
    );

    try {
      final token = await _localStorageRepository.getToken();

      if (token != null) {
        final response = await _client.get(
          Uri.parse('$host/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        switch (response.statusCode) {
          case HttpStatus.ok:
            // TODO: тут возможно jsonEncode
            final newUser = UserModel.fromJson(
              jsonDecode(response.body)['user'],
            ).copyWith(token: token);

            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }

    return error;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken('');
  }
}
