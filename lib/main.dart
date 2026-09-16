import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mind_whispers_app/mind_whispers_app.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/theme/controller/theme_cubit.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await setupInjection();

  final savedLocaleCode = getIt<SharedPreferences>().getString('app_locale');
  final startLocale = (savedLocaleCode != null)
      ? Locale(savedLocaleCode)
      : null;

  runApp(
    EasyLocalization(
      startLocale: startLocale,
      fallbackLocale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (context) => getIt<ThemeCubit>()),

          BlocProvider<AuthCubit>(create: (context) => getIt<AuthCubit>()),
        ],
        child: const MindWhispersApp(),
      ),
    ),
  );
}
