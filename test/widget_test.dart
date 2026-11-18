import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pawpal/app/pawpal_app.dart';
import 'package:pawpal/core/data/local_database.dart';
import 'package:pawpal/core/providers/app_providers.dart';
import 'package:pawpal/features/care/domain/reminder_recurrence.dart';

void main() {
  late LocalDatabase database;
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    database = LocalDatabase(databasePath: inMemoryDatabasePath);
    await database.open();
  });
  tearDown(() async => database.close());

  testWidgets('onboarding explains local-first privacy and can be completed', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const PawPalApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to PawPal'), findsOneWidget);
    expect(find.textContaining('No account, cloud sync or personal-data upload'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('A little care goes a long way.'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('My Pets'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  test('daily recurrence advances one local calendar day', () {
    final start = DateTime(2026, 11, 18, 8, 30);
    expect(ReminderRecurrence.next(start, 'daily'), DateTime(2026, 11, 19, 8, 30));
  });

  test('monthly recurrence clamps month-end dates to last day', () {
    final start = DateTime(2026, 1, 31, 9);
    expect(ReminderRecurrence.next(start, 'monthly'), DateTime(2026, 2, 28, 9));
  });
}
