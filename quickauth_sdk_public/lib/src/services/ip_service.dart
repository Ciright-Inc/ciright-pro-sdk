import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ipification_plugin/ipification.dart';

/// Wraps [IPificationPlugin] using the same integration pattern as
/// `ipification_app/lib/data/services/ipification_auth_service.dart`:
/// **do not `await` the configuration setters** — some plugin builds deadlock
/// if those platform calls are awaited in sequence.
class IpService {
  IpService() : _plugin = IPificationPlugin();

  final IPificationPlugin _plugin;
  bool _configured = false;
  String? _lastClientId;
  String? _lastRedirectUri;

  static const Duration _coverageTimeout = Duration(seconds: 45);
  static const Duration _authTimeout = Duration(seconds: 180);

  Future<void> _ensureConfigured({
    required String clientId,
    required String redirectUri,
  }) async {
    if (_configured &&
        _lastClientId == clientId &&
        _lastRedirectUri == redirectUri) {
      return;
    }

    debugPrint('QuickAuth IpService: configuring SDK (fire-and-forget, no await)');
    _plugin.setEnv(ENV.SANDBOX);
    _plugin.setClientId(clientId);
    _plugin.setRedirectUri(redirectUri);

    _lastClientId = clientId;
    _lastRedirectUri = redirectUri;
    _configured = true;
    debugPrint('QuickAuth IpService: configure dispatched');
  }

  Future<bool> checkCoverage({
    required String phone,
    required String clientId,
    required String redirectUri,
  }) async {
    await _ensureConfigured(clientId: clientId, redirectUri: redirectUri);
    try {
      debugPrint('QuickAuth IpService: checkCoverageWithPhoneNumber $phone');
      final coverage = await _plugin
          .checkCoverageWithPhoneNumber(phone)
          .timeout(_coverageTimeout);
      debugPrint(
        'QuickAuth IpService: coverage isAvailable=${coverage.isAvailable}',
      );
      return coverage.isAvailable;
    } on TimeoutException catch (e) {
      debugPrint('QuickAuth IpService.checkCoverage timeout: $e');
      return false;
    } on PlatformException catch (e) {
      debugPrint(
        'QuickAuth IpService.checkCoverage PlatformException: ${e.code} ${e.message}',
      );
      return false;
    } catch (e, st) {
      debugPrint('QuickAuth IpService.checkCoverage failed: $e\n$st');
      return false;
    }
  }

  Future<String> authenticate({
    required String phone,
    required String clientId,
    required String redirectUri,
  }) async {
    await _ensureConfigured(clientId: clientId, redirectUri: redirectUri);
    try {
      _plugin.setScope(value: 'openid ip:phone_verify');
      debugPrint('QuickAuth IpService: doAuthentication loginHint=$phone');
      final response = await _plugin
          .doAuthentication(loginHint: phone)
          .timeout(_authTimeout);
      final code = response.code;
      debugPrint(
        'QuickAuth IpService: code length=${code?.length ?? 0}',
      );
      if (code == null || code.isEmpty) {
        throw const FormatException('Authorization code is missing');
      }
      return code;
    } on TimeoutException {
      throw Exception(
        'IP verification timed out after ${_authTimeout.inSeconds}s. '
        'Finish the browser step and return to the app; check IMVerificationActivity + redirect URI.',
      );
    } on PlatformException catch (e) {
      throw Exception(
        'IP verification failed (${e.code}): ${e.message ?? "unknown"}',
      );
    } catch (error) {
      throw Exception('IP verification failed: $error');
    }
  }
}
