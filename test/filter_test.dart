import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuilder Filter Tests', () {
    testWidgets('containsTag filter should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestContainsTagFilterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestContainsTagFilterWidget(key: testKey),
        ),
      );

      expect(find.text('Tag Filter: 0'), findsOneWidget);

      // Update with non-matching tag
      testKey.currentState?.updateWithWrongTag();
      await tester.pump();

      // Should not update
      expect(find.text('Tag Filter: 0'), findsOneWidget);

      // Update with matching tag
      testKey.currentState?.updateWithCorrectTag();
      await tester.pump();

      // Should update
      expect(find.text('Tag Filter: 1'), findsOneWidget);
    });

    testWidgets('containsExtraTags filter should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestContainsExtraTagsFilterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestContainsExtraTagsFilterWidget(key: testKey),
        ),
      );

      expect(find.text('Multi-Tag Filter: 0'), findsOneWidget);

      // Update with partially matching tags
      testKey.currentState?.updateWithPartialTags();
      await tester.pump();

      // Should update
      expect(find.text('Multi-Tag Filter: 1'), findsOneWidget);

      // Update with completely non-matching tags
      testKey.currentState?.updateWithNoMatchTags();
      await tester.pump();

      // Should not update
      expect(find.text('Multi-Tag Filter: 1'), findsOneWidget);

      // Update with all matching tags
      testKey.currentState?.updateWithAllMatchTags();
      await tester.pump();

      // Should update
      expect(find.text('Multi-Tag Filter: 2'), findsOneWidget);
    });

    testWidgets('Custom filter should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestCustomFilterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestCustomFilterWidget(key: testKey),
        ),
      );

      expect(find.text('Custom Filter: 0'), findsOneWidget);

      // Update with data that doesn't meet the condition
      testKey.currentState?.updateWithSmallValue();
      await tester.pump();

      // Should not update
      expect(find.text('Custom Filter: 0'), findsOneWidget);

      // Update with data that meets the condition
      testKey.currentState?.updateWithLargeValue();
      await tester.pump();

      // Should update
      expect(find.text('Custom Filter: 10'), findsOneWidget);
    });
  });
}

// Tag filter test widget
class TestContainsTagFilterWidget extends StatefulWidget {
  const TestContainsTagFilterWidget({super.key});

  @override
  State<TestContainsTagFilterWidget> createState() =>
      TestContainsTagFilterWidgetState();
}

class TestContainsTagFilterWidgetState
    extends State<TestContainsTagFilterWidget> with TaggedBuildMixin {
  int _counter = 0;

  void updateWithWrongTag() {
    taggedBuildUpdate('wrong_tag');
  }

  void updateWithCorrectTag() {
    _counter++;
    taggedBuildUpdate('filter_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'filter_tag',
          data: () => _counter,
          filter: (info) => info.containsExtraTag('filter_tag'),
          builder: (context) => Text('Tag Filter: ${context.data}'),
        ),
      ),
    );
  }
}

// Multi-tag filter test widget
class TestContainsExtraTagsFilterWidget extends StatefulWidget {
  const TestContainsExtraTagsFilterWidget({super.key});

  @override
  State<TestContainsExtraTagsFilterWidget> createState() =>
      TestContainsExtraTagsFilterWidgetState();
}

class TestContainsExtraTagsFilterWidgetState
    extends State<TestContainsExtraTagsFilterWidget> with TaggedBuildMixin {
  int _counter = 0;

  void updateWithPartialTags() {
    _counter++;
    taggedBuildUpdates(ids: ['tag1', 'other_tag']);
  }

  void updateWithNoMatchTags() {
    taggedBuildUpdates(ids: ['wrong_tag1', 'wrong_tag2']);
  }

  void updateWithAllMatchTags() {
    _counter++;
    taggedBuildUpdates(ids: ['tag1', 'tag2', 'tag3']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'multi_filter_tag',
          data: () => _counter,
          filter: (info) => info.containsExtraTags(['tag1', 'tag2']),
          builder: (context) => Text('Multi-Tag Filter: ${context.data}'),
        ),
      ),
    );
  }
}

// Custom filter test widget
class TestCustomFilterWidget extends StatefulWidget {
  const TestCustomFilterWidget({super.key});

  @override
  State<TestCustomFilterWidget> createState() => TestCustomFilterWidgetState();
}

class TestCustomFilterWidgetState extends State<TestCustomFilterWidget>
    with TaggedBuildMixin {
  int _counter = 0;

  void updateWithSmallValue() {
    _counter = 5;
    taggedBuildUpdate('custom_filter_tag');
  }

  void updateWithLargeValue() {
    _counter = 10;
    taggedBuildUpdate('custom_filter_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'custom_filter_tag',
          data: () => _counter,
          filter: (info) => info.data >= 10,
          builder: (context) => Text('Custom Filter: ${context.data}'),
        ),
      ),
    );
  }
}
