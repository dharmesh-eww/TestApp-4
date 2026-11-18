import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pawpal/main.dart';

void main() {
  testWidgets('PawPal opens with the five primary destinations', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PawPal()));
    expect(find.text('Good day, pet parent'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('My Pets'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('empty pet state offers pet creation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PawPal()));
    expect(find.text('Your pet’s story starts here'), findsOneWidget);
    expect(find.text('Add your first pet'), findsOneWidget);
  });
}
