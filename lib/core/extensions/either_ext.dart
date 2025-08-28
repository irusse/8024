import 'package:dartz/dartz.dart';

extension EitherExtensions<L, R> on Either<L, R> {
  /// Возвращает значение справа или null
  R? get rightOrNull => fold((l) => null, (r) => r);
  
  /// Возвращает значение слева или null
  L? get leftOrNull => fold((l) => l, (r) => null);
  
  /// Проверяет, является ли Either успешным (Right)
  bool get isRight => fold((l) => false, (r) => true);
  
  /// Проверяет, является ли Either неуспешным (Left)
  bool get isLeft => fold((l) => true, (r) => false);
  
  /// Выполняет действие только если Either содержит Right
  Either<L, R> onSuccess(void Function(R) action) {
    return fold(
      (l) => this,
      (r) {
        action(r);
        return this;
      },
    );
  }
  
  /// Выполняет действие только если Either содержит Left
  Either<L, R> onError(void Function(L) action) {
    return fold(
      (l) {
        action(l);
        return this;
      },
      (r) => this,
    );
  }
  
  /// Преобразует Right значение
  Either<L, T> mapRight<T>(T Function(R) mapper) {
    return fold(
      (l) => Left(l),
      (r) => Right(mapper(r)),
    );
  }
  
  /// Преобразует Left значение
  Either<T, R> mapLeft<T>(T Function(L) mapper) {
    return fold(
      (l) => Left(mapper(l)),
      (r) => Right(r),
    );
  }
  
  /// Возвращает значение справа или значение по умолчанию
  R getOrElse(R defaultValue) {
    return fold((l) => defaultValue, (r) => r);
  }
  
  /// Возвращает значение справа или результат функции
  R getOrElseCall(R Function() defaultValue) {
    return fold((l) => defaultValue(), (r) => r);
  }
}