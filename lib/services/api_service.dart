import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../core/constants/api_constants.dart';
import '../models/stats.dart';

/// Wrapper du client Dio exposant les methodes API de haut niveau
class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  Dio get dio => _dio;

  /// Recupere les statistiques globales
  Future<Stats> fetchStats() async {
    try {
      final response = await _dio.get(ApiConstants.stats);
      return Stats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.error as ApiException? ??
          ApiException(message: e.message ?? 'Erreur inconnue', statusCode: 500);
    }
  }
}

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
  dio.interceptors.add(LoggingInterceptor());
  dio.interceptors.add(ErrorInterceptor());
  return dio;
});

/// Provider de l'ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

/// Intercepteur de logging
class LoggingInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('[API] ' + options.method + ' ' + options.path);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('[API] ' + (response.statusCode?.toString() ?? '') + ' ' + response.requestOptions.path);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('[API ERROR] ' + (err.message ?? ''), error: err);
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
          message: 'Erreur inattendue: ' + (err.message ?? ''),
          statusCode: 500,
        );
    }
  }

  String _messageFromStatus(int status) {
    switch (status) {
      case 400: return 'Requete invalide';
      case 401: return 'Non autorise';
      case 403: return 'Acces refuse';
      case 404: return 'Ressource introuvable';
      case 429: return 'Trop de requetes';
      case 500: return 'Erreur interne du serveur';
      case 503: return 'Service indisponible';
      default: return 'Erreur HTTP ' + status.toString();
    }
  }
}

/// Exception API structuree
class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException(' + statusCode.toString() + '): ' + message;
}
