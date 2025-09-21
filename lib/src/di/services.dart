import 'package:get_it/get_it.dart';

abstract final class Services {
  static GetIt get instance => GetIt.instance;

  static T registerSingleton<T extends Object>(T singleton) {
    return instance.registerSingleton(singleton);
  }

  static void registerLazySingleton<T extends Object>(T Function() factory) {
    instance.registerLazySingleton<T>(factory);
  }

  static void registerSingletonAsync<T extends Object>(
    Future<T> Function() factory,
  ) {
    instance.registerSingletonAsync(factory);
  }

  static void registerLazySingletonAsync<T extends Object>(
    Future<T> Function() factory,
  ) {
    instance.registerLazySingletonAsync(factory);
  }

  static void registerFactory<T extends Object>(T Function() factory) {
    instance.registerFactory(factory);
  }

  static void registerFactoryAsync<T extends Object>(
    Future<T> Function() factory,
  ) {
    instance.registerFactoryAsync(factory);
  }
}
