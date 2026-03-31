import 'models/auth_result.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/ip_service.dart';

class QuickAuthSDK {
  QuickAuthSDK._();

  static AuthService? _authService;
  static bool _isInitialized = false;

  /// Initialize the SDK.
  ///
  /// Set [testMode] to `true` on simulators / CI where no real SIM is
  /// available. In test mode the native IP-plugin is skipped entirely and
  /// [testAuthCode] is sent directly to the backend. Obtain a real one-time
  /// code from your IPification dashboard or leave it as the placeholder to
  /// exercise just the backend API-key / DB path.
  static void init({
    required String apiKey,
    required String apiBaseUrl,
    required String ipificationClientId,
    required String redirectUri,
    bool testMode = false,
    String testAuthCode = 'simulator_test_code',
    void Function(String message)? onLoginProgress,
  }) {
    if (apiKey.trim().isEmpty) throw ArgumentError('apiKey cannot be empty');
    if (apiBaseUrl.trim().isEmpty) throw ArgumentError('apiBaseUrl cannot be empty');
    if (ipificationClientId.trim().isEmpty) throw ArgumentError('ipificationClientId cannot be empty');
    if (redirectUri.trim().isEmpty) throw ArgumentError('redirectUri cannot be empty');

    final apiService = ApiService(
      baseUrl: apiBaseUrl,
      apiKey: apiKey,
      ipificationClientId: ipificationClientId,
      redirectUri: redirectUri,
    );
    final ipService = IpService();

    _authService = AuthService(
      apiService: apiService,
      ipService: ipService,
      ipificationClientId: ipificationClientId,
      redirectUri: redirectUri,
      testMode: testMode,
      testAuthCode: testAuthCode,
      onProgress: onLoginProgress,
    );
    _isInitialized = true;
  }

  static Future<AuthResult> login(
    String phone, {
    void Function(String message)? onProgress,
  }) async {
    if (!_isInitialized || _authService == null) {
      return const AuthResult(
        success: false,
        message: 'QuickAuthSDK is not initialized. Call QuickAuthSDK.init() first.',
      );
    }
    return _authService!.login(phone, onProgress: onProgress);
  }
}
