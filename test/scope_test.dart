import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('Scope Tests', () {
    testWidgets('Independent scopes should update separately',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestScopeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestScopeWidget(key: testKey),
        ),
      );

      expect(find.text('Default Scope: 0'), findsOneWidget);
      expect(find.text('Custom Scope: 0'), findsOneWidget);

      // Update Default Scope Only
      testKey.currentState?.updateDefaultScope();
      await tester.pump();

      expect(find.text('Default Scope: 1'), findsOneWidget);
      expect(find.text('Custom Scope: 0'), findsOneWidget);

      // Update Custom Scope Only
      testKey.currentState?.updateCustomScope();
      await tester.pump();

      expect(find.text('Default Scope: 1'), findsOneWidget);
      expect(find.text('Custom Scope: 1'), findsOneWidget);
    });

    testWidgets(
        'Components with the same tag but different scopes should be updated independently',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultiScopeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultiScopeWidget(key: testKey),
        ),
      );

      expect(find.text('Scope 1: 0'), findsOneWidget);
      expect(find.text('Scope 2: 0'), findsOneWidget);

      // Update scope 1 only
      testKey.currentState?.updateScope1();
      await tester.pump();

      expect(find.text('Scope 1: 1'), findsOneWidget);
      expect(find.text('Scope 2: 0'), findsOneWidget);

      // Update scope 2 only
      testKey.currentState?.updateScope2();
      await tester.pump();

      expect(find.text('Scope 1: 1'), findsOneWidget);
      expect(find.text('Scope 2: 1'), findsOneWidget);
    });

    testWidgets('Updating multiple scopes simultaneously should work fine',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultiScopeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultiScopeWidget(key: testKey),
        ),
      );

      expect(find.text('Scope 1: 0'), findsOneWidget);
      expect(find.text('Scope 2: 0'), findsOneWidget);

      // 同时更新两个作用域
      testKey.currentState!.updateBothScopes();
      await tester.pump();

      expect(find.text('Scope 1: 1'), findsOneWidget);
      expect(find.text('Scope 2: 1'), findsOneWidget);
    });

    testWidgets('Scopes in nested components should work fine',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestNestedScopeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestNestedScopeWidget(key: testKey),
        ),
      );

      expect(find.text('Parent Scope: 0'), findsOneWidget);
      expect(find.text('Child Scope: 0'), findsOneWidget);

      // Update parent scope only
      testKey.currentState?.updateParentScope();
      await tester.pump();

      expect(find.text('Parent Scope: 1'), findsOneWidget);
      expect(find.text('Child Scope: 0'), findsOneWidget);

      //call first to cache childscope
      await tester.tap(find.text('Child Scope Updated'));
      await tester.pump();

      expect(find.text('Parent Scope: 1'), findsOneWidget);
      expect(find.text('Child Scope: 1'), findsOneWidget);

      testKey.currentState?.updateDefaultScope();
      await tester.pump();

      expect(find.text('Parent Scope: 1'), findsOneWidget);
      expect(find.text('Child Scope: 2'), findsOneWidget);
    });

    testWidgets(
        'Components with different tags and scopes should update correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultiTagScopeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultiTagScopeWidget(key: testKey),
        ),
      );

      expect(find.text('Tag 1 Default Scope: 0'), findsOneWidget);
      expect(find.text('Tag 2 Custom Scope: 0'), findsOneWidget);

      // 只更新Tag 1 Default Scope
      testKey.currentState!.updateTag1InDefaultScope();
      await tester.pump();

      expect(find.text('Tag 1 Default Scope: 1'), findsOneWidget);
      expect(find.text('Tag 2 Custom Scope: 0'), findsOneWidget);

      // 只更新Tag 2 Custom Scope
      (testKey.currentState as TestMultiTagScopeWidgetState)
          .updateTag2InCustomScope();
      await tester.pump();

      expect(find.text('Tag 1 Default Scope: 1'), findsOneWidget);
      expect(find.text('Tag 2 Custom Scope: 1'), findsOneWidget);

      // 更新所有标签和作用域
      (testKey.currentState as TestMultiTagScopeWidgetState).updateAllTags();
      await tester.pump();

      expect(find.text('Tag 1 Default Scope: 2'), findsOneWidget);
      expect(find.text('Tag 2 Custom Scope: 2'), findsOneWidget);
    });
  });
}

class TestScopeWidget extends StatefulWidget {
  const TestScopeWidget({super.key});

  @override
  State<TestScopeWidget> createState() => TestScopeWidgetState();
}

class TestScopeWidgetState extends State<TestScopeWidget>
    with TaggedBuildMixin {
  int _defaultCounter = 0;
  int _customCounter = 0;
  final customScope = Object();

  void updateDefaultScope() {
    _defaultCounter++;
    taggedBuildUpdate('counter_tag');
  }

  void updateCustomScope() {
    _customCounter += 1;
    taggedBuildUpdate('counter_tag', scope: customScope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          taggedBuild<String, int>(
            tag: 'counter_tag',
            scope: customScope,
            data: () => _customCounter,
            builder: (context) => Text('Custom Scope: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'counter_tag',
            data: () => _defaultCounter,
            builder: (context) => Text('Default Scope: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestMultiScopeWidget extends StatefulWidget {
  const TestMultiScopeWidget({super.key});

  @override
  State<TestMultiScopeWidget> createState() => TestMultiScopeWidgetState();
}

class TestMultiScopeWidgetState extends State<TestMultiScopeWidget>
    with TaggedBuildMixin {
  int _counter1 = 0;
  int _counter2 = 0;
  final scope1 = Object();
  final scope2 = Object();

  void updateScope1() {
    _counter1++;
    taggedBuildUpdate('multi_tag', scope: scope1);
  }

  void updateScope2() {
    _counter2++;
    taggedBuildUpdate('multi_tag', scope: scope2);
  }

  void updateBothScopes() {
    _counter1++;
    _counter2++;
    taggedBuildUpdates(ids: ['multi_tag'], scope: scope1);
    taggedBuildUpdates(ids: ['multi_tag'], scope: scope2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          taggedBuild<String, int>(
            tag: 'multi_tag',
            scope: scope1,
            data: () => _counter1,
            builder: (context) => Text('Scope 1: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'multi_tag',
            scope: scope2,
            data: () => _counter2,
            builder: (context) => Text('Scope 2: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestNestedScopeWidget extends StatefulWidget {
  const TestNestedScopeWidget({super.key});

  @override
  State<TestNestedScopeWidget> createState() => TestNestedScopeWidgetState();
}

class TestNestedScopeWidgetState extends State<TestNestedScopeWidget>
    with TaggedBuildMixin {
  int _parentCounter = 0;
  int _childCounter = 0;
  final parentScope = Object();
  Object? childScope;

  void updateParentScope() {
    _parentCounter++;
    taggedBuildUpdate('nested_tag', scope: parentScope);
  }

  void updateDefaultScope() {
    _childCounter++;
    taggedBuildUpdate('nested_tag', scope: childScope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          taggedBuild<String, int>(
            tag: 'nested_tag',
            scope: parentScope,
            data: () => _parentCounter,
            builder: (context) => Text('Parent Scope: ${context.data}'),
          ),
          ChildScopeWidget(
            counter: () => _childCounter,
            onUpdate: (scope) {
              childScope = scope;
              updateDefaultScope();
            },
          ),
        ],
      ),
    );
  }
}

class ChildScopeWidget extends StatelessWidget with TaggedBuildMixin {
  final int Function() counter;
  final void Function(Object) onUpdate;

  ChildScopeWidget({
    super.key,
    required this.counter,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return taggedBuild<String, int>(
      tag: 'nested_tag',
      data: counter,
      builder: (context) => Column(
        children: [
          Text('Child Scope: ${context.data}'),
          ElevatedButton(
            onPressed: () => onUpdate(context.scope),
            child: const Text('Child Scope Updated'),
          ),
        ],
      ),
    );
  }
}

class TestMultiTagScopeWidget extends StatefulWidget {
  const TestMultiTagScopeWidget({super.key});

  @override
  State<TestMultiTagScopeWidget> createState() =>
      TestMultiTagScopeWidgetState();
}

class TestMultiTagScopeWidgetState extends State<TestMultiTagScopeWidget>
    with TaggedBuildMixin {
  int _counter1 = 0;
  int _counter2 = 0;
  final customScope = Object();

  void updateTag1InDefaultScope() {
    _counter1++;
    taggedBuildUpdate('tag1');
  }

  void updateTag2InCustomScope() {
    _counter2++;
    taggedBuildUpdate('tag2', scope: customScope);
  }

  void updateAllTags() {
    _counter1++;
    _counter2++;
    taggedBuildUpdates(ids: ['tag1', 'tag2']);
    taggedBuildUpdates(ids: ['tag1', 'tag2'], scope: customScope);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          taggedBuild<String, int>(
            tag: 'tag1',
            data: () => _counter1,
            builder: (context) => Text('Tag 1 Default Scope: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'tag2',
            scope: customScope,
            data: () => _counter2,
            builder: (context) => Text('Tag 2 Custom Scope: ${context.data}'),
          ),
        ],
      ),
    );
  }
}
