import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mind_whispers_app/core/network/dio_client.dart';
import 'package:mind_whispers_app/core/routes/app_router.dart';
import 'package:mind_whispers_app/core/theme/controller/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton<Dio>(() => DioClient(getIt()).dio);
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));

  // Per feature, register in this order:
  // 1. Data source:  getIt.registerLazySingleton<XRemoteDataSource>(() => XRemoteDataSourceImpl(getIt()));
  //    (or XFakeDataSource() while the real API isn't ready yet, see API_CONTRACT.md)
  // 2. Repository:   getIt.registerLazySingleton<XRepository>(() => XRepositoryImpl(getIt()));
  // 3. Cubit:        getIt.registerFactory<XCubit>(() => XCubit(getIt()));
}
