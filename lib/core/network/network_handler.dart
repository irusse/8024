import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:neighbours/core/error/failures.dart';
import 'package:neighbours/core/exceptions/exceptions.dart';

class NetworkHandler {
  static Future<Either<Failure, T>> handleRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final result = await request();
      return Right(result);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } on BadRequestException catch (e) {
      return Left(BadRequestFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: $e'));
    }
  }

  static Failure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure('Время ожидания истекло');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Нет подключения к интернету');
      case DioExceptionType.unknown:
        final err = error.error;
        if (err is SocketException) {
          return const NetworkFailure('Нет подключения к интернету');
        } else {
          return NetworkFailure(
              err?.toString() ?? 'Неизвестная сетевая ошибка');
        }
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            final data = error.response?.data;
            dynamic message =
                data is Map<String, dynamic> && data['message'] != null
                    ? data['message']
                    : 'Произошла ошибка';
            if (message is List) {
              message = message.join('\n');
            }
            return BadRequestFailure(message);
          case 403:
            return const AuthFailure('Доступ запрещен');
          case 404:
            return const NotFoundFailure('Ресурс не найден');
          case 500:
            return const ServerFailure('Внутренняя ошибка сервера');
          default:
            return ServerFailure(
              'Ошибка сервера: ${error.response?.statusMessage}',
              statusCode,
            );
        }
      case DioExceptionType.cancel:
        return const NetworkFailure('Запрос отменен');
      default:
        return NetworkFailure(error.message ?? 'Неизвестная сетевая ошибка');
    }
  }
}
