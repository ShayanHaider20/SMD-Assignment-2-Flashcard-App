import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_learning_flashcards/app_theme.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_bloc.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_event.dart';
import 'package:micro_learning_flashcards/blocs/auth/auth_state.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_event.dart'; // Import Deck events
import 'package:micro_learning_flashcards/screens/auth/login_screen.dart';
import 'package:micro_learning_flashcards/screens/dashboard_screen.dart';
import 'package:micro_learning_flashcards/services/auth_service.dart';
import 'package:micro_learning_flashcards/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyC9PjBh77LAfGERtnkQpD8hyRjQbLSvgdk",
    authDomain: "microlearning-flashcards.firebaseapp.com",
    projectId: "microlearning-flashcards",
    storageBucket: "microlearning-flashcards.firebasestorage.app",
    messagingSenderId: "855904470971",
    appId: "1:855904470971:web:ded19f3f5019946372669e",
    measurementId: "G-97TVNE1E7Q",
  );
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();
  final FirebaseService firebaseService = FirebaseService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: authService,
          )..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<DeckBloc>(
          create: (context) => DeckBloc(
            firebaseService: firebaseService,
          )..add(
              LoadPublicDecksEvent()), // Or LoadUserDecksEvent(userId: "...")
        ),
      ],
      child: MaterialApp(
        title: 'Micro Learning Flashcards',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthenticatedState) {
              // If you need to load user-specific decks after authentication
              context
                  .read<DeckBloc>()
                  .add(LoadUserDecksEvent(userId: state.user.uid));
              return const DashboardScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
