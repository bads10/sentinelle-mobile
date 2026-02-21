import 'dart:async';
import 'package:flutter/foundation.dart';

/// Niveau de sévérité d'un événement d'ingestion.
enum IngestionLevel { info, warning, error }

/// Entrée de journal pour une tentative d'ingestion.
class IngestionLogEntry {
  final DateTime timestamp;
  final String source;
  final IngestionLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final int attempt;

  const IngestionLogEntry({
    required this.timestamp,
    required this.source,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.attempt = 1,
  });

  @override
  String toString() {
    final buf = StringBuffer();
    buf.write('[${level.name.toUpperCase()}] ${timestamp.toIso8601String()} ');
    buf.write('source=$source attempt=$attempt | $message');
    if (error != null) buf.write(' | error=$error');
    return buf.toString();
  }
}

/// Logger d'ingestion avec support retry et drain vers debugPrint.
class IngestionLogger {
  IngestionLogger._();
  static final IngestionLogger instance = IngestionLogger._();

  final List<IngestionLogEntry> _entries = [];
  static const int _maxEntries = 500;

  // ---------------------------------------------------------------------------
  // Logging primitives
  // ---------------------------------------------------------------------------

  void info(String source, String message, {int attempt = 1}) {
    _add(IngestionLevel.info, source, message, attempt: attempt);
  }

  void warning(String source, String message, {int attempt = 1}) {
    _add(IngestionLevel.warning, source, message, attempt: attempt);
  }

  void error(
    String source,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    int attempt = 1,
  }) {
    _add(
      IngestionLevel.error,
      source,
      message,
      error: error,
      stackTrace: stackTrace,
      attempt: attempt,
    );
  }

  void _add(
    IngestionLevel level,
    String source,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    int attempt = 1,
  }) {
    final entry = IngestionLogEntry(
      timestamp: DateTime.now().toUtc(),
      source: source,
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      attempt: attempt,
    );
    _entries.add(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    if (kDebugMode) debugPrint(entry.toString());
  }

  // ---------------------------------------------------------------------------
  // Retry helper
  // ---------------------------------------------------------------------------

  /// Execute [fn] up to [maxAttempts] times with exponential back-off.
  /// Logs every failure and re-throws the last exception if all attempts fail.
  static Future<T> withRetry<T>(
    String source,
    Future<T> Function() fn, {
    int maxAttempts = 3,
    Duration baseDelay = const Duration(seconds: 2),
  }) async {
    final logger = IngestionLogger.instance;
    Object? lastError;
    StackTrace? lastStack;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (attempt > 1) {
          logger.info(
            source,
            'Retry attempt $attempt/$maxAttempts',
            attempt: attempt,
          );
        }
        final result = await fn();
        if (attempt > 1) {
          logger.info(source, 'Succeeded on attempt $attempt', attempt: attempt);
        }
        return result;
      } catch (e, st) {
        lastError = e;
        lastStack = st;
        logger.error(
          source,
          'Attempt $attempt/$maxAttempts failed',
          error: e,
          stackTrace: st,
          attempt: attempt,
        );
        if (attempt < maxAttempts) {
          final delay = baseDelay * (1 << (attempt - 1)); // 2s, 4s, 8s ...
          await Future<void>.delayed(delay);
        }
      }
    }

    throw IngestionException(
      source: source,
      message: 'All $maxAttempts attempts failed',
      cause: lastError,
      causeStack: lastStack,
    );
  }

  // ---------------------------------------------------------------------------
  // Accessors
  // ---------------------------------------------------------------------------

  List<IngestionLogEntry> get entries => List.unmodifiable(_entries);

  List<IngestionLogEntry> entriesForSource(String source) =>
      _entries.where((e) => e.source == source).toList();

  List<IngestionLogEntry> get errors =>
      _entries.where((e) => e.level == IngestionLevel.error).toList();

  void clear() => _entries.clear();
}

/// Exception levée après épuisement des tentatives.
class IngestionException implements Exception {
  final String source;
  final String message;
  final Object? cause;
  final StackTrace? causeStack;

  const IngestionException({
    required this.source,
    required this.message,
    this.cause,
    this.causeStack,
  });

  @override
  String toString() =>
      'IngestionException[$source]: $message${cause != null ? " (cause: $cause)" : ""}';
}
