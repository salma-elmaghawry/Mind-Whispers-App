import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mind_whispers_app/core/helpers/device_id.dart';
import 'package:mind_whispers_app/core/network/dio_client.dart';
import 'package:mind_whispers_app/core/routes/app_router.dart';
import 'package:mind_whispers_app/core/theme/controller/theme_cubit.dart';
import 'package:mind_whispers_app/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:mind_whispers_app/features/auth/data/datasource/auth_remote_datasource_impl.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository_impl.dart';
import 'package:mind_whispers_app/features/reader/data/datasource/reader_remote_datasource.dart';
import 'package:mind_whispers_app/features/reader/data/datasource/reader_remote_datasource_impl.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/feed/feed_cubit.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_cubit.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton<Dio>(() => DioClient(getIt()).dio);
  getIt.registerLazySingleton<DeviceIdProvider>(() => DeviceIdProvider(getIt()));
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt()));

  getIt.registerLazySingleton<ReaderRemoteDataSource>(() => ReaderRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<ReaderRepository>(() => ReaderRepositoryImpl(getIt()));
  getIt.registerFactory<FeedCubit>(() => FeedCubit(getIt()));

  getIt.registerFactoryParam<PostDetailCubit, int, void>(
    (postId, _) => PostDetailCubit(getIt(), postId),
  );
}
