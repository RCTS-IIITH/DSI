import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class NetworkResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final String? errorId;

  NetworkResponse({
    required this.success,
    this.data,
    this.error,
    this.errorId,
  });
}

class NetworkUtils {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  static Future<NetworkResponse> retryingRequest({
    required Future<http.Response> Function() requestFunction,
    int maxAttempts = maxRetries,
  }) async {
    int attempts = 0;
    late http.Response response;
    
    while (attempts < maxAttempts) {
      try {
        attempts++;
        response = await requestFunction();

        // Parse response
        final responseData = json.decode(response.body);
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return NetworkResponse(
            success: true,
            data: responseData,
          );
        }

        // Handle known error responses
        if (responseData is Map && responseData.containsKey('message')) {
          throw APIException(
            responseData['message'],
            response.statusCode,
            responseData['errorId'],
          );
        }

        throw APIException('Request failed', response.statusCode);

      } on TimeoutException catch (e) {
        if (attempts == maxAttempts) rethrow;
        await Future.delayed(retryDelay * attempts);
        continue;
        
      } on http.ClientException catch (e) {
        if (attempts == maxAttempts) rethrow;
        await Future.delayed(retryDelay * attempts);
        continue;
        
      } catch (e) {
        if (e is APIException) rethrow;
        throw APIException(e.toString(), 500);
      }
    }

    throw APIException('Max retry attempts reached', 500);
  }
}

class APIException implements Exception {
  final String message;
  final int statusCode;
  final String? errorId;

  APIException(this.message, this.statusCode, [this.errorId]);

  @override
  String toString() => 'APIException: $message (Status: $statusCode)';
}