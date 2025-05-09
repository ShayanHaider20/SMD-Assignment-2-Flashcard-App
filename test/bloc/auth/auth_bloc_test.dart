import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_bloc.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_event.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_state.dart';

import '../../test_setup.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
    authBloc = AuthBloc(authService: mockAuthService);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitialState', () {
    expect(authBloc.state, isA<AuthInitialState>());
  });

  group('CheckAuthStatusEvent', () {
    test('emits [AuthLoadingState, AuthenticatedState] when user is signed in',
        () {
      when(mockAuthService.currentUser).thenReturn(mockUser);

      final expectedStates = [
        AuthLoadingState(),
        AuthenticatedState(user: mockUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(CheckAuthStatusEvent());
    });

    test(
        'emits [AuthLoadingState, UnauthenticatedState] when user is not signed in',
        () {
      when(mockAuthService.currentUser).thenReturn(null);

      final expectedStates = [
        AuthLoadingState(),
        UnauthenticatedState(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(CheckAuthStatusEvent());
    });

    test('emits [AuthLoadingState, AuthErrorState] when error occurs', () {
      when(mockAuthService.currentUser).thenThrow(Exception('Test error'));

      final expectedStates = [
        AuthLoadingState(),
        isA<AuthErrorState>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(CheckAuthStatusEvent());
    });
  });

  group('SignInEvent', () {
    const email = 'test@example.com';
    const password = 'password123';

    test(
        'emits [AuthLoadingState, AuthenticatedState] when sign in is successful',
        () {
      when(mockAuthService.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => mockUser);

      final expectedStates = [
        AuthLoadingState(),
        AuthenticatedState(user: mockUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignInEvent(email: email, password: password));

      verify(mockAuthService.signInWithEmailAndPassword(email, password))
          .called(1);
    });

    test('emits [AuthLoadingState, AuthErrorState] when sign in returns null',
        () {
      when(mockAuthService.signInWithEmailAndPassword(email, password))
          .thenAnswer((_) async => null);

      final expectedStates = [
        AuthLoadingState(),
        isA<AuthErrorState>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignInEvent(email: email, password: password));
    });

    test('emits [AuthLoadingState, AuthErrorState] when sign in throws error',
        () {
      when(mockAuthService.signInWithEmailAndPassword(email, password))
          .thenThrow(Exception('Sign in error'));

      final expectedStates = [
        AuthLoadingState(),
        isA<AuthErrorState>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignInEvent(email: email, password: password));
    });
  });

  group('SignUpEvent', () {
    const email = 'new@example.com';
    const password = 'newpass123';
    const displayName = 'New User';

    test(
        'emits [AuthLoadingState, AuthenticatedState] when sign up is successful',
        () {
      when(mockAuthService.signUpWithEmailAndPassword(email, password))
          .thenAnswer((_) async => mockUser);

      final expectedStates = [
        AuthLoadingState(),
        AuthenticatedState(user: mockUser),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignUpEvent(
        email: email,
        password: password,
        displayName: displayName,
      ));

      verify(mockAuthService.signUpWithEmailAndPassword(email, password))
          .called(1);
    });

    test('emits [AuthLoadingState, AuthErrorState] when sign up returns null',
        () {
      when(mockAuthService.signUpWithEmailAndPassword(email, password))
          .thenAnswer((_) async => null);

      final expectedStates = [
        AuthLoadingState(),
        isA<AuthErrorState>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignUpEvent(
        email: email,
        password: password,
        displayName: displayName,
      ));
    });

    test('emits [AuthLoadingState, AuthErrorState] when sign up throws', () {
      when(mockAuthService.signUpWithEmailAndPassword(email, password))
          .thenThrow(Exception('Sign up error'));

      final expectedStates = [
        AuthLoadingState(),
        isA<AuthErrorState>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignUpEvent(
        email: email,
        password: password,
        displayName: displayName,
      ));
    });
  });

  group('SignOutEvent', () {
    test(
        'emits [AuthLoadingState, UnauthenticatedState] when sign out succeeds',
        () {
      when(mockAuthService.signOut()).thenAnswer((_) async {});

      final expectedStates = [
        AuthLoadingState(),
        UnauthenticatedState(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignOutEvent());

      verify(mockAuthService.signOut()).called(1);
    });

    test('emits [AuthLoadingState, AuthErrorState] when sign out throws', () {
      when(mockAuthService.signOut()).thenThrow(Exception('Sign out error'));

      final expectedStates = [
        AuthLoadingState(),
        isA<AuthErrorState>(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(SignOutEvent());
    });
  });
}
