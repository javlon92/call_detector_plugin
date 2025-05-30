import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

/// {@template Status}
///
/// Перечисление [Status] представляет различные состояния, которые могут быть присвоены объектам,
/// связанным с процессами, например, с загрузкой данных, выполнением операций или обработкой ошибок.
///
/// Статусы включают:
///
/// - [initial] — начальное состояние (по умолчанию).
/// - [loading] — процесс загрузки данных.
/// - [success] — успешное выполнение операции.
/// - [failure] — ошибка при выполнении операции.
///
/// Также доступны геттеры [isInitial], [isLoading], [isSuccess], [isFailure] и [isNotInitial], [isNotLoading], [isNotSuccess], [isNotFailure] для удобной проверки текущего состояния,
/// а методы [map], [maybeMap], [mapOrNull] и [fromString]
/// позволяют элегантно обрабатывать значения перечисления без использования условных операторов.
///
/// Пример использования:
///
/// ```dart
/// Status status = Status.loading;
/// if (status.isLoading) {
///   // Выполнить действия при загрузке
/// }
/// ```
///
/// {@endtemplate}
@JsonEnum(fieldRename: FieldRename.snake)
enum Status implements Comparable<Status> {
  /// - [initial] — Начальное состояние.
  initial,

  /// - [loading] — Состояние загрузки.
  loading,

  /// - [success] — Состояние успешного выполнения.
  success,

  /// - [failure] — Состояние ошибки.
  failure;

  /// Проверяет, является ли текущий статус [initial].
  ///
  /// - [isInitial] — Возвращает `true`, если статус равен [initial].
  bool get isInitial => this == initial;

  /// Проверяет, является ли текущий статус [loading].
  ///
  /// - [isLoading] — Возвращает `true`, если статус равен [loading].
  bool get isLoading => this == loading;

  /// Проверяет, является ли текущий статус [success].
  ///
  /// - [isSuccess] — Возвращает `true`, если статус равен [success].
  bool get isSuccess => this == success;

  /// Проверяет, является ли текущий статус [error].
  ///
  /// - [isFailure] — Возвращает `true`, если статус равен [failure].
  bool get isFailure => this == failure;

  /// Проверяет, не является ли текущий статус [initial].
  ///
  /// - [isNotInitial] — Возвращает `true`, если статус **не** равен [initial].
  bool get isNotInitial => !isInitial;

  /// Проверяет, не является ли текущий статус [loading].
  ///
  /// - [isNotLoading] — Возвращает `true`, если статус **не** равен [loading].
  bool get isNotLoading => !isLoading;

  /// Проверяет, не является ли текущий статус [success].
  ///
  /// - [isNotSuccess] — Возвращает `true`, если статус **не** равен [success].
  bool get isNotSuccess => !isSuccess;

  /// Проверяет, не является ли текущий статус [error].
  ///
  /// - [isNotFailure] — Возвращает `true`, если статус **не** равен [failure].
  bool get isNotFailure => !isFailure;

  /// Паттерн-матчинг для статусов.
  ///
  /// Метод [map] выполняет действие в зависимости от текущего состояния.
  /// Он принимает обработчики для каждого из статусов и вызывает соответствующий обработчик,
  /// в зависимости от текущего статуса.
  ///
  /// **Суть метода**: Метод [map] полезен, когда необходимо выполнить разные действия в зависимости
  /// от текущего состояния. Вместо многочисленных условных операторов `if`, можно использовать
  /// этот метод для более чистого и понятного кода.
  ///
  /// Пример использования:
  ///
  /// ```dart
  /// Status status = Status.loading;
  /// status.map(
  ///   initial: () => print('Начальное состояние'),
  ///   loading: () => print('Загрузка данных'),
  ///   success: () => print('Операция успешна'),
  ///   failure: () => print('Ошибка при выполнении операции'),
  /// );
  /// ```
  T map<T>({
    required ValueGetter<T> initial,
    required ValueGetter<T> loading,
    required ValueGetter<T> success,
    required ValueGetter<T> failure,
  }) =>
      switch (this) {
        Status.initial => initial(),
        Status.loading => loading(),
        Status.success => success(),
        Status.failure => failure(),
      };

  /// Паттерн-матчинг с возможностью задания действия по умолчанию.
  ///
  /// **Суть метода**: Метод [maybeMap] работает аналогично [map], но позволяет указать действие, которое будет
  /// выполнено в случае, если ни один из статусов не был передан. Это особенно полезно, если необходимо
  /// всегда иметь какой-то "дефолт" обработчик для незаданных состояний.
  ///
  /// Пример использования:
  ///
  /// ```dart
  /// Status status = Status.success;
  /// status.maybeMap(
  ///   orElse: () => print('Неизвестное состояние'),
  ///   success: () => print('Операция успешна'),
  /// );
  /// ```
  T maybeMap<T>({
    required ValueGetter<T> orElse,
    ValueGetter<T>? initial,
    ValueGetter<T>? loading,
    ValueGetter<T>? success,
    ValueGetter<T>? failure,
  }) =>
      map<T>(
        initial: initial ?? orElse,
        loading: loading ?? orElse,
        success: success ?? orElse,
        failure: failure ?? orElse,
      );

  /// Паттерн-матчинг с возможностью возвращать null.
  ///
  /// **Суть метода**: Метод [mapOrNull] аналогичен [maybeMap], но возвращает `null`, если ни одно из состояний не подходит.
  /// Это может быть полезно в случаях, когда нужно провести операцию, которая может вернуть `null`,
  /// если все состояния не подходят.
  ///
  /// Пример использования:
  ///
  /// ```dart
  /// Status status = Status.loading;
  /// final result = status.mapOrNull(
  ///   loading: () => 'Загрузка...',
  /// );
  /// print(result); // Выведет: Загрузка...
  /// ```
  T? mapOrNull<T>({
    ValueGetter<T>? initial,
    ValueGetter<T>? loading,
    ValueGetter<T>? success,
    ValueGetter<T>? failure,
  }) =>
      maybeMap<T?>(
        initial: initial,
        loading: loading,
        success: success,
        failure: failure,
        orElse: () => null,
      );

  /// Возвращает [Status] из строки [value], соответствующей имени статуса.
  ///
  /// **Суть метода**: Метод [fromString] используется для преобразования строкового значения
  /// (например, из JSON, API или UI) в соответствующий экземпляр перечисления [Status].
  ///
  /// Если переданная строка не совпадает ни с одним значением, то по умолчанию возвращается [Status.initial].
  ///
  /// Полезно при работе с сериализацией/десериализацией или при получении статуса из внешних источников.
  ///
  ///
  /// Пример использования:
  ///
  /// ```dart
  /// final status = Status.fromString('success');
  /// print(status); // Status.success
  ///
  /// final fallback = Status.fromString('unknown');
  /// print(fallback); // Status.initial (fallback)
  /// ```
  static Status fromString({
    String? value,
    ValueGetter<Status>? orElse,
  }) {
    final valueLowerCase = value?.toLowerCase();
    return Status.values.firstWhere(
      (e) => e.name == valueLowerCase,
      orElse: orElse ?? () => Status.initial,
    );
  }

  /// Сравнивает два значения перечисления [Status] по порядку.
  ///
  /// **Суть метода**: Метод [compareTo] используется для сравнения текущего состояния с другим
  /// состоянием на основе их порядка в перечислении. Например, он может использоваться для сортировки
  /// статусов или для выполнения действий в зависимости от их очередности.
  ///
  /// Пример использования:
  ///
  /// ```dart
  /// final statuses = [Status.failure, Status.initial, Status.loading];
  /// statuses.sort(); // Используется compareTo автоматически
  /// print(statuses); // → [Status.initial, Status.loading, Status.failure]
  /// ```
  @override
  int compareTo(Status other) => index.compareTo(other.index);
}
