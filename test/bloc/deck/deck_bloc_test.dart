import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_bloc.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_event.dart';
import 'package:micro_learning_flashcards/blocs/deck/deck_state.dart';
import 'package:micro_learning_flashcards/models/deck.dart';
import 'package:micro_learning_flashcards/models/flashcard.dart';

// ignore: unused_import
import '../../test_setup.mocks.dart';

void main() {
  late DeckBloc deckBloc;
  late MockFirebaseService mockFirebaseService;

  setUp(() {
    mockFirebaseService = MockFirebaseService();
    deckBloc = DeckBloc(firebaseService: mockFirebaseService);
  });

  tearDown(() {
    deckBloc.close();
  });

  final testDeck = Deck(
    id: 'test-deck-id',
    title: 'Test Deck',
    description: 'Test Description',
    creatorId: 'user-123',
    creatorName: 'Test User',
    isPublic: true,
    tags: ['test', 'flutter'],
    createdAt: DateTime.now(),
    flashcards: [
      Flashcard(
        question: 'Test Question',
        answer: 'Test Answer',
      ),
    ],
  );

  final testDecks = [testDeck];

  test('initial state is DeckInitialState', () {
    expect(deckBloc.state, isA<DeckInitialState>());
  });

  group('LoadUserDecksEvent', () {
    final userId = 'user-123';

    test('emits [DeckLoadingState] and adds DecksLoadedEvent when successful',
        () {
      // Mock the stream of decks
      when(mockFirebaseService.getUserDecks(any))
          .thenAnswer((_) => Stream.value(testDecks));

      expectLater(
        deckBloc.stream,
        emits(isA<DeckLoadingState>()),
      );

      deckBloc.add(LoadUserDecksEvent(userId: userId));

      verify(mockFirebaseService.getUserDecks(userId)).called(1);
    });

    test('emits [DeckLoadingState] and handles error', () {
      // Mock stream that emits error
      when(mockFirebaseService.getUserDecks(any))
          .thenAnswer((_) => Stream.error('Test error'));

      expectLater(
        deckBloc.stream,
        emits(isA<DeckLoadingState>()),
      );

      deckBloc.add(LoadUserDecksEvent(userId: userId));
    });
  });

  group('LoadPublicDecksEvent', () {
    test('emits [DeckLoadingState] and adds DecksLoadedEvent when successful',
        () {
      // Mock the stream of decks
      when(mockFirebaseService.getPublicDecks())
          .thenAnswer((_) => Stream.value(testDecks));

      expectLater(
        deckBloc.stream,
        emits(isA<DeckLoadingState>()),
      );

      deckBloc.add(LoadPublicDecksEvent());

      verify(mockFirebaseService.getPublicDecks()).called(1);
    });
  });

  group('CreateDeckEvent', () {
    test(
        'emits [DeckLoadingState, DeckCreatedState] when deck creation is successful',
        () async {
      when(mockFirebaseService.createDeck(any))
          .thenAnswer((_) async => 'test-deck-id');

      when(mockFirebaseService.getDeck(any)).thenAnswer((_) async => testDeck);

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckCreatedState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(CreateDeckEvent(deck: testDeck));

      await untilCalled(mockFirebaseService.createDeck(testDeck));
      verify(mockFirebaseService.createDeck(testDeck)).called(1);
    });

    test('emits [DeckLoadingState, DeckErrorState] when deck creation fails',
        () async {
      when(mockFirebaseService.createDeck(any))
          .thenAnswer((_) async => 'test-deck-id');

      when(mockFirebaseService.getDeck(any)).thenAnswer((_) async => null);

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckErrorState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(CreateDeckEvent(deck: testDeck));
    });

    test('emits [DeckLoadingState, DeckErrorState] when exception occurs',
        () async {
      when(mockFirebaseService.createDeck(any))
          .thenThrow(Exception('Test error'));

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckErrorState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(CreateDeckEvent(deck: testDeck));
    });
  });

  group('UpdateDeckEvent', () {
    test('emits [DeckLoadingState, DeckUpdatedState] when update is successful',
        () async {
      when(mockFirebaseService.updateDeck(any)).thenAnswer((_) async => {});

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckUpdatedState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(UpdateDeckEvent(deck: testDeck));

      await untilCalled(mockFirebaseService.updateDeck(testDeck));
      verify(mockFirebaseService.updateDeck(testDeck)).called(1);
    });

    test('emits [DeckLoadingState, DeckErrorState] when exception occurs',
        () async {
      when(mockFirebaseService.updateDeck(any))
          .thenThrow(Exception('Test error'));

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckErrorState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(UpdateDeckEvent(deck: testDeck));
    });
  });

  group('DeleteDeckEvent', () {
    final deckId = 'test-deck-id';

    test(
        'emits [DeckLoadingState, DeckDeletedState] when deletion is successful',
        () async {
      when(mockFirebaseService.deleteDeck(any)).thenAnswer((_) async => {});

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckDeletedState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(DeleteDeckEvent(deckId: deckId));

      await untilCalled(mockFirebaseService.deleteDeck(deckId));
      verify(mockFirebaseService.deleteDeck(deckId)).called(1);
    });

    test('emits [DeckLoadingState, DeckErrorState] when exception occurs',
        () async {
      when(mockFirebaseService.deleteDeck(any))
          .thenThrow(Exception('Test error'));

      final expectedStates = [
        isA<DeckLoadingState>(),
        isA<DeckErrorState>(),
      ];

      expectLater(
        deckBloc.stream,
        emitsInOrder(expectedStates),
      );

      deckBloc.add(DeleteDeckEvent(deckId: deckId));
    });
  });

  group('SearchDecksByTagsEvent', () {
    final tags = ['flutter', 'test'];

    test('emits [DeckLoadingState] and adds DecksLoadedEvent when successful',
        () {
      when(mockFirebaseService.searchDecksByTags(any))
          .thenAnswer((_) => Stream.value(testDecks));

      expectLater(
        deckBloc.stream,
        emits(isA<DeckLoadingState>()),
      );

      deckBloc.add(SearchDecksByTagsEvent(tags: tags));

      verify(mockFirebaseService.searchDecksByTags(tags)).called(1);
    });

    test('emits [DeckLoadingState] and handles error', () {
      when(mockFirebaseService.searchDecksByTags(any))
          .thenAnswer((_) => Stream.error('Test error'));

      expectLater(
        deckBloc.stream,
        emits(isA<DeckLoadingState>()),
      );

      deckBloc.add(SearchDecksByTagsEvent(tags: tags));
    });
  });

  group('DecksLoadedEvent', () {
    test('emits [DecksLoadedState] with loaded decks', () {
      expectLater(
        deckBloc.stream,
        emits(isA<DecksLoadedState>()),
      );

      deckBloc.add(DecksLoadedEvent(decks: testDecks));
    });
  });

  group('DeckErrorEvent', () {
    test('emits [DeckErrorState] with error message', () {
      const errorMessage = 'Test error message';

      expectLater(
        deckBloc.stream,
        emits(isA<DeckErrorState>()),
      );

      deckBloc.add(const DeckErrorEvent(message: errorMessage));
    });
  });
}
