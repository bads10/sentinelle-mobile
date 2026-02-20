import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/constants/api_constants.dart';

/// Provider du client Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout:
          const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout:
          const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Intercepteurs
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(ErrorInterceptor());

  return dio;
});

/// Intercepteur de logging
class LoggingInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('[API] ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('[API] ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('[API ERROR] ${err.message}', error: err);
    super.onError(err, handler);
  }
}

/// Intercepteur de gestion des erreurs
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = _handleError(err);
    handler.next(DioException(
      requestOptions: err.requestOptions,
      error: apiError,
      type: err.type,
      response: err.response,
    ));
  }

  ApiException _handleError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Timeout de connexion au serveur',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 500;
        return ApiException(
          message: _messageFromStatus(statusCode),
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Impossible de se connecter au serveur',
          statusCode: 503,
        );
      default:
        return ApiException(
          message: 'Erreur inattendue: ${err.message}',
          statusCode: 500,
        );
    }
  }

  String _messageFromStatus(int status) {
    switch (status) {
      case 400: return 'Requête invalide';
      case 401: return 'Non autorisé';
      case 403: return 'Accès refusé';
      case 404: return 'Ressource introuvable';
      case 429: return 'Trop de requêtes';
      case 500: return 'Erreur interne du serveur';
      case 503: return 'Service indisponible';
      default: return 'Erreur HTTP $status';
    }
  }
}

/// Exception API structurée
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
