import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase/supabase_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AuthState?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (state) => state?.session?.user ?? repository.currentUser,
    orElse: () => repository.currentUser,
  );
});

class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient? _client;

  User? get currentUser => _client?.auth.currentUser;

  Stream<AuthState?> get authStateChanges {
    final client = _client;
    if (client == null) {
      return Stream<AuthState?>.value(null);
    }
    return client.auth.onAuthStateChange;
  }

  bool get isConfigured => _client != null;

  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw const AuthConfigurationException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('Google did not return an ID token.');
    }

    await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _client?.auth.signOut();
  }
}

class AuthConfigurationException implements Exception {
  const AuthConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}
