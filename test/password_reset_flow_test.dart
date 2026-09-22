import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
import 'package:mind_whispers_app/core/helpers/device_id.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/features/auth/data/datasource/auth_remote_datasource_impl.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/auth_session.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/user.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mind_whispers_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mind_whispers_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final Map<String, (int, Map<String, dynamic>)> replies = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final (status, body) = replies[options.path] ?? (200, {'message': 'ok'});
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FakeAuthRepository implements AuthRepository {
  final List<String> forgotCalls = [];
  final List<Map<String, String>> resetCalls = [];
  Either<Failure, Unit> forgotResult = const Right(unit);
  Either<Failure, Unit> resetResult = const Right(unit);

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String email}) async {
    forgotCalls.add(email);
    return forgotResult;
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    resetCalls.add({
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return resetResult;
  }

  @override
  bool get hasPersistedToken => false;

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
    bool remember = false,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, User>> me() => throw UnimplementedError();
}

void main() {
  group('data layer', () {
    late _RecordingAdapter adapter;
    late AuthRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'))
        ..httpClientAdapter = adapter;
      repository = AuthRepositoryImpl(
        AuthRemoteDataSourceImpl(dio, DeviceIdProvider(prefs)),
        prefs,
      );
    });

    test('forgotPassword POSTs the email to /auth/forgot-password', () async {
      final result = await repository.forgotPassword(email: 'a@b.com');

      expect(result, const Right<Failure, Unit>(unit));
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.path, '/auth/forgot-password');
      expect(adapter.requests.single.data, {'email': 'a@b.com'});
    });

    test(
      'resetPassword POSTs all four fields to /auth/reset-password',
      () async {
        final result = await repository.resetPassword(
          email: 'a@b.com',
          otp: '123456',
          password: 'secret1',
          passwordConfirmation: 'secret1',
        );

        expect(result, const Right<Failure, Unit>(unit));
        expect(adapter.requests.single.method, 'POST');
        expect(adapter.requests.single.path, '/auth/reset-password');
        expect(adapter.requests.single.data, {
          'email': 'a@b.com',
          'otp': '123456',
          'password': 'secret1',
          'password_confirmation': 'secret1',
        });
      },
    );

    test('a 422 on otp keeps its field errors (not remapped)', () async {
      adapter.replies['/auth/reset-password'] = (
        422,
        {
          'message': 'The code is invalid.',
          'errors': {
            'otp': ['The code is invalid.'],
          },
        },
      );

      final result = await repository.resetPassword(
        email: 'a@b.com',
        otp: '000000',
        password: 'secret1',
        passwordConfirmation: 'secret1',
      );

      final failure = result.swap().getOrElse(
        () => throw StateError('no failure'),
      );
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).errors['otp'], [
        'The code is invalid.',
      ]);
    });

    test(
      'a 422 on email from forgot-password stays a ValidationFailure',
      () async {
        adapter.replies['/auth/forgot-password'] = (
          422,
          {
            'message': 'We can\'t find a user with that email address.',
            'errors': {
              'email': ['We can\'t find a user with that email address.'],
            },
          },
        );

        final result = await repository.forgotPassword(email: 'nobody@b.com');

        expect(result.swap().toOption().toNullable(), isA<ValidationFailure>());
      },
    );
  });

  group('screens', () {
    late _FakeAuthRepository repo;

    setUp(() => repo = _FakeAuthRepository());

    Future<void> pumpApp(
      WidgetTester tester, {
      String initial = Routes.forgotPassword,
    }) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(800, 2400),
          builder: (_, _) => BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(repo),
            child: MaterialApp(
              initialRoute: initial,
              onGenerateRoute: (settings) {
                switch (settings.name) {
                  case Routes.forgotPassword:
                    return MaterialPageRoute(
                      settings: settings,
                      builder: (_) => const ForgotPasswordScreen(),
                    );
                  case Routes.resetPassword:
                    return MaterialPageRoute(
                      settings: settings,
                      builder: (_) => ResetPasswordScreen(
                        email: settings.arguments as String,
                      ),
                    );
                  case Routes.login:
                    return MaterialPageRoute(
                      settings: settings,
                      builder: (_) =>
                          const Scaffold(body: Text('LOGIN_SCREEN')),
                    );
                }
                return null;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> enterAt(WidgetTester tester, int index, String text) async {
      await tester.enterText(find.byType(TextFormField).at(index), text);
    }

    testWidgets(
      'forgot-password rejects a malformed email without calling the API',
      (tester) async {
        await pumpApp(tester);

        await enterAt(tester, 0, 'not-an-email');
        await tester.tap(find.text('auth.forgot.submit'));
        await tester.pumpAndSettle();

        expect(repo.forgotCalls, isEmpty);
        expect(find.text('auth.login.email_invalid'), findsOneWidget);
      },
    );

    testWidgets(
      'forgot-password success opens the reset screen with the email',
      (tester) async {
        await pumpApp(tester);

        await enterAt(tester, 0, 'a@b.com');
        await tester.tap(find.text('auth.forgot.submit'));
        await tester.pumpAndSettle();

        expect(repo.forgotCalls, ['a@b.com']);
        final reset = tester.widget<ResetPasswordScreen>(
          find.byType(ResetPasswordScreen),
        );
        expect(reset.email, 'a@b.com');
      },
    );

    testWidgets('forgot-password failure stays on the screen', (tester) async {
      repo.forgotResult = const Left(
        ValidationFailure(
          message: 'No such user',
          errors: {
            'email': ['No such user'],
          },
        ),
      );
      await pumpApp(tester);

      await enterAt(tester, 0, 'a@b.com');
      await tester.tap(find.text('auth.forgot.submit'));
      await tester.pumpAndSettle();

      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.text('No such user'), findsOneWidget);
    });

    testWidgets('reset screen validates the code and password match locally', (
      tester,
    ) async {
      await pumpApp(tester, initial: Routes.forgotPassword);
      await enterAt(tester, 0, 'a@b.com');
      await tester.tap(find.text('auth.forgot.submit'));
      await tester.pumpAndSettle();

      await enterAt(tester, 0, '123');
      await enterAt(tester, 1, 'secret1');
      await enterAt(tester, 2, 'different');
      await tester.tap(find.text('auth.reset.submit').last);
      await tester.pumpAndSettle();

      expect(repo.resetCalls, isEmpty);
      expect(find.text('auth.reset.otp_invalid'), findsOneWidget);
      expect(find.text('auth.signup.password_mismatch'), findsOneWidget);
    });

    testWidgets('OTP field only accepts up to 6 digits', (tester) async {
      await pumpApp(tester);
      await enterAt(tester, 0, 'a@b.com');
      await tester.tap(find.text('auth.forgot.submit'));
      await tester.pumpAndSettle();

      await enterAt(tester, 0, '12ab34567890');

      final field = tester.widget<TextFormField>(
        find.byType(TextFormField).at(0),
      );
      expect(field.controller!.text, '123456');
    });

    testWidgets('a 422 on otp is shown inline under the code field', (
      tester,
    ) async {
      repo.resetResult = const Left(
        ValidationFailure(
          message: 'The code is invalid.',
          errors: {
            'otp': ['The code is invalid.'],
          },
        ),
      );
      await pumpApp(tester);
      await enterAt(tester, 0, 'a@b.com');
      await tester.tap(find.text('auth.forgot.submit'));
      await tester.pumpAndSettle();

      await enterAt(tester, 0, '000000');
      await enterAt(tester, 1, 'secret1');
      await enterAt(tester, 2, 'secret1');
      await tester.tap(find.text('auth.reset.submit').last);
      await tester.pumpAndSettle();

      expect(repo.resetCalls.single['otp'], '000000');
      expect(repo.resetCalls.single['email'], 'a@b.com');
      expect(find.text('The code is invalid.'), findsOneWidget);

      expect(
        find.widgetWithText(SnackBar, 'The code is invalid.'),
        findsNothing,
      );
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    });

    testWidgets('a successful reset clears the stack and lands on login', (
      tester,
    ) async {
      await pumpApp(tester);
      await enterAt(tester, 0, 'a@b.com');
      await tester.tap(find.text('auth.forgot.submit'));
      await tester.pumpAndSettle();

      await enterAt(tester, 0, '123456');
      await enterAt(tester, 1, 'secret1');
      await enterAt(tester, 2, 'secret1');
      await tester.tap(find.text('auth.reset.submit').last);
      await tester.pumpAndSettle();

      expect(repo.resetCalls.single, {
        'email': 'a@b.com',
        'otp': '123456',
        'password': 'secret1',
        'password_confirmation': 'secret1',
      });
      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      expect(find.byType(ResetPasswordScreen), findsNothing);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });

    testWidgets(
      'resend re-requests the code without stacking another reset screen',
      (tester) async {
        await pumpApp(tester);
        await enterAt(tester, 0, 'a@b.com');
        await tester.tap(find.text('auth.forgot.submit'));
        await tester.pumpAndSettle();
        expect(repo.forgotCalls, ['a@b.com']);

        await tester.tap(find.text('auth.reset.resend'));
        await tester.pumpAndSettle();

        expect(repo.forgotCalls, ['a@b.com', 'a@b.com']);
        expect(find.byType(ResetPasswordScreen), findsOneWidget);

        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      },
    );
  });
}
