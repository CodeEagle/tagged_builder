import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuildBus Tests', () {
    testWidgets('Singleton pattern should work correctly',
        (WidgetTester tester) async {
      final instance1 = TaggedBuildBus.shared;
      final instance2 = TaggedBuildBus.shared;
      expect(identical(instance1, instance2), isTrue);
    });

    testWidgets('Empty tag list update should be ignored',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestEmptyTagsWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestEmptyTagsWidget(key: testKey),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      // Update with empty tag list
      TaggedBuildBus.shared.update([]);
      await tester.pump();

      expect(find.text('Count: 0'), findsOneWidget);
    });

    testWidgets('Global update should trigger all registered builders',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultipleBuilderWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultipleBuilderWidget(key: testKey),
        ),
      );

      expect(find.text('Builder1: 1'), findsOneWidget);
      expect(find.text('Builder2: 1'), findsOneWidget);

      // Update without specifying tags for global update
      testKey.currentState?.doUpdate();
      await tester.pump();

      expect(find.text('Builder1: 2'), findsOneWidget);
      expect(find.text('Builder2: 2'), findsOneWidget);
    });

    testWidgets('Scoped update should only trigger matching builders',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestScopedBuilderWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestScopedBuilderWidget(key: testKey),
        ),
      );

      expect(find.text('Scope1: 1'), findsOneWidget);
      expect(find.text('Scope2: 1'), findsOneWidget);

      // Update specific scope
      testKey.currentState?.doUpdate();
      await tester.pump();

      expect(find.text('Scope1: 2'), findsOneWidget);
      expect(find.text('Scope2: 1'), findsOneWidget);
    });

    testWidgets('Should not receive updates after unregistration',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestUnregisterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestUnregisterWidget(key: testKey),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      // Update before unregistration
      testKey.currentState?.testTagUpdate();
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      // Unregister builder
      testKey.currentState!.unregisterBuilder();
      await tester.pump();

      // Update after unregistration
      testKey.currentState?.testTagUpdate();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('Filter should work correctly', (WidgetTester tester) async {
      final testKey = GlobalKey<TestFilterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestFilterWidget(key: testKey),
        ),
      );

      expect(find.text('Filter: 0'), findsOneWidget);

      // Update with matching filter condition
      testKey.currentState?.updateWithMatchingFilter();
      await tester.pump();

      expect(find.text('Filter: 1'), findsOneWidget);

      // Update with non-matching filter condition
      testKey.currentState?.updateWithNonMatchingFilter();
      await tester.pump();

      expect(find.text('Filter: 1'), findsOneWidget);
    });

    testWidgets('Empty data filter should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestEmptyFilterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestEmptyFilterWidget(key: testKey),
        ),
      );

      expect(find.text('Empty: Initial'), findsOneWidget);

      // Update with empty data filter
      testKey.currentState?.updateWithEmptyFilter();
      await tester.pump();

      expect(find.text('Empty: Updated'), findsOneWidget);
    });
  });
}

// Test Widgets
class TestFilterWidget extends StatefulWidget {
  const TestFilterWidget({super.key});

  @override
  State<TestFilterWidget> createState() => TestFilterWidgetState();
}

class TestFilterWidgetState extends State<TestFilterWidget>
    with TaggedBuildMixin {
  int _counter = 0;
  List<String> _updateTags = [];

  void updateWithMatchingFilter() {
    _counter++;
    _updateTags = ['matching_tag'];
    taggedBuildUpdates(ids: _updateTags);
  }

  void updateWithNonMatchingFilter() {
    _counter++;
    _updateTags = ['non_matching_tag'];
    taggedBuildUpdates(ids: _updateTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'filter_tag',
          data: () => _counter,
          filter: (info) => info.containsExtraTag('matching_tag'),
          builder: (context) => Text('Filter: ${context.data}'),
        ),
      ),
    );
  }
}

class TestEmptyFilterWidget extends StatefulWidget {
  const TestEmptyFilterWidget({super.key});

  @override
  State<TestEmptyFilterWidget> createState() => TestEmptyFilterWidgetState();
}

class TestEmptyFilterWidgetState extends State<TestEmptyFilterWidget>
    with TaggedBuildMixin {
  String? _data = 'Initial';

  void updateWithEmptyFilter() {
    setState(() {
      _data = 'Updated';
    });
    taggedBuildUpdate('empty_filter_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuildEmpty<String>(
          tag: 'empty_filter_tag',
          filter: (info) => true,
          builder: (context) => Text('Empty: $_data'),
        ),
      ),
    );
  }
}

class TestEmptyTagsWidget extends StatefulWidget {
  const TestEmptyTagsWidget({super.key});

  @override
  State<TestEmptyTagsWidget> createState() => TestEmptyTagsWidgetState();
}

class TestEmptyTagsWidgetState extends State<TestEmptyTagsWidget>
    with TaggedBuildMixin {
  final int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'test_tag',
          data: () => _counter,
          builder: (context) => Text('Count: ${context.data}'),
        ),
      ),
    );
  }
}

class TestMultipleBuilderWidget extends StatefulWidget {
  const TestMultipleBuilderWidget({super.key});

  @override
  State<TestMultipleBuilderWidget> createState() =>
      TestMultipleBuilderWidgetState();
}

class TestMultipleBuilderWidgetState extends State<TestMultipleBuilderWidget>
    with TaggedBuildMixin {
  int _counter1 = 0;
  int _counter2 = 0;

  void doUpdate() {
    taggedBuildUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          taggedBuild<String, int>(
            tag: 'tag1',
            data: () {
              _counter1++;
              return _counter1;
            },
            builder: (context) => Text('Builder1: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'tag2',
            data: () {
              _counter2++;
              return _counter2;
            },
            builder: (context) => Text('Builder2: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestScopedBuilderWidget extends StatefulWidget {
  const TestScopedBuilderWidget({super.key});

  @override
  State<TestScopedBuilderWidget> createState() =>
      TestScopedBuilderWidgetState();
}

class TestScopedBuilderWidgetState extends State<TestScopedBuilderWidget>
    with TaggedBuildMixin {
  int _counter1 = 0;
  int _counter2 = 0;

  void doUpdate() {
    taggedBuildUpdate('tag', scope: 'scope1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          taggedBuild<String, int>(
            tag: 'tag',
            scope: 'scope1',
            data: () {
              _counter1++;
              return _counter1;
            },
            builder: (context) => Text('Scope1: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'tag',
            scope: 'scope2',
            data: () {
              _counter2++;
              return _counter2;
            },
            builder: (context) => Text('Scope2: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestUnregisterWidget extends StatefulWidget {
  const TestUnregisterWidget({super.key});

  @override
  State<TestUnregisterWidget> createState() => TestUnregisterWidgetState();
}

class TestUnregisterWidgetState extends State<TestUnregisterWidget>
    with TaggedBuildMixin {
  int _counter = 0;
  final String _buildId = 'test build id';

  void unregisterBuilder() {
    taggedBuildUnregister(_buildId);
  }

  void testTagUpdate() {
    _counter++;
    taggedBuildUpdate('test_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'test_tag',
          data: () {
            return _counter;
          },
          builder: (context) => Text('Count: ${context.data}'),
          id: _buildId,
        ),
      ),
    );
  }
}
