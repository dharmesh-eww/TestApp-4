import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pawpal/app/pawpal_app.dart';
import 'package:pawpal/core/data/local_database.dart';
import 'package:pawpal/core/providers/app_providers.dart';
import 'package:pawpal/core/data/paw_repository.dart';
import 'package:pawpal/core/domain/pet.dart';
import 'package:pawpal/core/domain/care_entities.dart';
import 'package:pawpal/features/care/domain/reminder_recurrence.dart';

void main() {
  late LocalDatabase database;
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    database = LocalDatabase(databasePath: ':memory:');
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

  test('SQLite backup round-trip is versioned and omits private attachment paths', () async {
    final repository = PawRepository(database);
    final pet = Pet(id: 'pet-1', name: 'Milo', species: 'Dog', photoPath: '/private/photo.jpg');
    await repository.save('pets', pet.toMap());
    final reminder = Reminder(id: 'reminder-1', petId: pet.id, title: 'Walk', category: 'Walk', dueAt: DateTime(2026, 11, 19, 8));
    await repository.save('reminders', reminder.toMap());
    final backup = await repository.exportAll();
    expect(backup, contains('"schema_version": 2'));
    expect(backup, isNot(contains('/private/photo.jpg')));
    final validated = await repository.validateImport(backup);
    expect(validated['pets'], hasLength(1));
    expect(validated['reminders'], hasLength(1));
    await repository.restore(validated, replaceExisting: true);
    expect(await repository.list('pets'), hasLength(1));
  });

  test('legacy v1 backup is upgraded to the current schema', () async {
    final repository = PawRepository(database);
    const legacy = '{"schemaVersion":1,"selected":"pet-legacy","units":"US customary","pets":[{"id":"pet-legacy","name":"Milo","species":"Dog","breed":"Mix","birthday":"2020-01-01","weight":"20","notes":"Friendly"}],"tasks":[{"id":"task-1","petId":"pet-legacy","title":"Dinner","type":"Feeding","due":"2026-11-19T18:00:00.000","repeat":"Daily","done":false,"note":""}],"logs":[]}';
    final validated = await repository.validateImport(legacy);
    expect(validated['pets'], hasLength(1));
    expect(validated['reminders'], hasLength(1));
  });

  test('interval and selected weekday recurrence advance correctly', () {
    final monday = DateTime(2026, 11, 16, 9);
    expect(ReminderRecurrence.next(monday, 'interval', intervalDays: 3), DateTime(2026, 11, 19, 9));
    expect(ReminderRecurrence.next(monday, 'weekdays', weekdays: [1, 3]), DateTime(2026, 11, 18, 9));
  });

  test('monthly skip policy skips a missing calendar day', () {
    final start = DateTime(2026, 1, 31, 9);
    expect(ReminderRecurrence.next(start, 'monthly', monthEndPolicy: 'skip'), DateTime(2026, 3, 31, 9));
  });
}
