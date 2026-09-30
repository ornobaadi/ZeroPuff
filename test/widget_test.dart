import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zeropuff/main.dart';

void main() {
  testWidgets('ZeroPuff app shell renders sign in', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZeroPuffApp()));
    await tester.pumpAndSettle();

    expect(find.text('ZeroPuff'), findsOneWidget);
    expect(find.text('Private by default'), findsOneWidget);
  });
}
