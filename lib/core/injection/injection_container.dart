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
import 'package:mind_whispers_app/features/reader/data/datasource/reader_fake_datasource.dart';
import 'package:mind_whispers_app/features/reader/data/datasource/reader_remote_datasource.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/feed/feed_cubit.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_cubit.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository.dart';
import 'package:mind_whispers_app/features/reader/repository/reader_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton<Dio>(() => DioClient(getIt()).dio);
  getIt.registerLazySingleton<DeviceIdProvider>(() => DeviceIdProvider(getIt()));
  getIt.registerFactory<ThemeCubit>(() => ThemeCubit(getIt()));

  // Per feature, register in this order:
  // 1. Data source:  getIt.registerLazySingleton<XRemoteDataSource>(() => XRemoteDataSourceImpl(getIt()));
  //    (or XFakeDataSource() while the real API isn't ready yet, see API_CONTRACT.md)
  // 2. Repository:   getIt.registerLazySingleton<XRepository>(() => XRepositoryImpl(getIt()));
  // 3. Cubit:        getIt.registerFactory<XCubit>(() => XCubit(getIt()));

  // Auth (see api-1.json for the real endpoint contract)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt()));

  // Reader (feed/post detail/comments) — fake datasource, no live backend
  // for this yet (unlike auth). See API_CONTRACT.md and
  // ReaderFakeDataSource's own doc comment.
  getIt.registerLazySingleton<ReaderRemoteDataSource>(() => ReaderFakeDataSource());
  getIt.registerLazySingleton<ReaderRepository>(() => ReaderRepositoryImpl(getIt()));
  getIt.registerFactory<FeedCubit>(() => FeedCubit(getIt()));
  // PostDetailCubit is scoped to one post per screen, so it takes the post
  // id as a runtime param rather than being resolved by type alone.
  getIt.registerFactoryParam<PostDetailCubit, int, void>(
    (postId, _) => PostDetailCubit(getIt(), postId),
  );
}
