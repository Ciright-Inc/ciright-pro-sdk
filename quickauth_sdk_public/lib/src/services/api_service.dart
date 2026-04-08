import 'package:dio/dio.dart';

import '../models/auth_result.dart';

class ApiService {
  ApiService({
    required String baseUrl,
    required String apiKey,
    required String cirightProClientId,
    required String redirectUri,
    Dio? dio,
  })  : _apiKey = apiKey,
        _cirightProClientId = cirightProClientId,
        _redirectUri = redirectUri,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                headers: <String, dynamic>{
                  'Content-Type': 'application/json',
                  'x-api-key': apiKey,
                  // Tenant metadata for backend-side SaaS policy enforcement.
                  'x-qa-client-id': cirightProClientId,
                  'x-qa-redirect-uri': redirectUri,
                },
              ),
            ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  final Dio _dio;
  final String _apiKey;
  final String _cirightProClientId;
  final String _redirectUri;

  Future<AuthResult> login({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, dynamic>{
          'phone': phone,
          'code': code,
        },
        options: Options(
          headers: <String, dynamic>{
            'x-api-key': _apiKey,
            'x-qa-client-id': _cirightProClientId,
            'x-qa-redirect-uri': _redirectUri,
          },
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      return AuthResult.fromJson(data);
    } on DioException catch (error) {
      final message = error.response?.data is Map<String, dynamic>
          ? ((error.response!.data as Map<String, dynamic>)['message']
                  as String?) ??
              'Backend request failed'
          : 'Backend request failed';
      return AuthResult(success: false, message: message);
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Unexpected SDK backend error',
      );
    }
  }
}
