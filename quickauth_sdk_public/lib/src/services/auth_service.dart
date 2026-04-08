import 'package:flutter/foundation.dart';

import '../models/auth_result.dart';
import 'api_service.dart';
import 'ip_service.dart';

class AuthService {
  AuthService({
    required ApiService apiService,
    required IpService ipService,
    required String cirightProClientId,
    required String redirectUri,
    bool testMode = false,
    String testAuthCode = 'simulator_test_code',
    void Function(String message)? onProgress,
  })  : _apiService = apiService,
        _ipService = ipService,
        _cirightProClientId = cirightProClientId,
        _redirectUri = redirectUri,
        _testMode = testMode,
        _testAuthCode = testAuthCode,
        _onProgress = onProgress;

  final ApiService _apiService;
  final IpService _ipService;
  final String _cirightProClientId;
  final String _redirectUri;
  final bool _testMode;
  final String _testAuthCode;
  final void Function(String message)? _onProgress;

  Future<AuthResult> login(
    String phone, {
    void Function(String message)? onProgress,
  }) async {
    void emit(String message) {
      debugPrint('QuickAuth: $message');
      onProgress?.call(message);
      _onProgress?.call(message);
    }

    if (phone.trim().isEmpty) {
      return const AuthResult(success: false, message: 'Phone is required');
    }

    // In testMode skip all native plugin calls — useful on simulators / CI.
    if (_testMode) {
      emit('Test mode: calling backend…');
      return await _apiService.login(phone: phone, code: _testAuthCode);
    }

    emit('(1/3) Checking operator coverage (native SDK)…');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final hasCoverage = await _ipService.checkCoverage(
      phone: phone,
      clientId: _cirightProClientId,
      redirectUri: _redirectUri,
    );
    if (!hasCoverage) {
      return const AuthResult(
        success: false,
        message:
            'Coverage unavailable for this number or network — check logs and try again',
      );
    }

    try {
      emit(
        '(2/3) Opening secure verification — complete the prompt, then return to this app…',
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final authCode = await _ipService.authenticate(
        phone: phone,
        clientId: _cirightProClientId,
        redirectUri: _redirectUri,
      );
      emit('(3/3) Exchanging code with your backend…');
      return await _apiService.login(phone: phone, code: authCode);
    } catch (error) {
      return AuthResult(
        success: false,
        message: 'Authentication flow failed: $error',
      );
    }
  }
}
