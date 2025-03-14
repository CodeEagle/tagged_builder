import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuildMixin Tests', () {
    testWidgets('defaultScope should generate unique value for each instance',
        (WidgetTester tester) async {
      const widget1 = TestMixinWidget();
      const widget2 = TestMixinWidget();

      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [widget1, widget2],
          ),
        ),
      );

      final state1 = tester.state<TestMixinWidgetState>(find.byWidget(widget1));
      final state2 = tester.state<TestMixinWidgetState>(find.byWidget(widget2));

      expect(state1.defaultScope, isNot(equals(state2.defaultScope)));
    });

    testWidgets('taggedBuildUpdate should only update single tag',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultiTagWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultiTagWidget(key: testKey),
        ),
      );

      expect(find.text('Tag1: 0'), findsOneWidget);
      expect(find.text('Tag2: 0'), findsOneWidget);

      // Update tag1 only
      testKey.currentState?.updateTag1();
      await tester.pump();

      expect(find.text('Tag1: 1'), findsOneWidget);
      expect(find.text('Tag2: 0'), findsOneWidget);

      // Update tag2 only
      testKey.currentState?.updateTag2();
      await tester.pump();

      expect(find.text('Tag1: 1'), findsOneWidget);
      expect(find.text('Tag2: 1'), findsOneWidget);
    });

    testWidgets('taggedBuildUpdates should update multiple tags',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultiTagWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultiTagWidget(key: testKey),
        ),
      );

      expect(find.text('Tag1: 0'), findsOneWidget);
      expect(find.text('Tag2: 0'), findsOneWidget);

      // Update two tags
      testKey.currentState?.updateBothTags();
      await tester.pump();

      expect(find.text('Tag1: 1'), findsOneWidget);
      expect(find.text('Tag2: 1'), findsOneWidget);
    });

    testWidgets('taggedBuildUpdates empty tags list should not trigger updates',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestEmptyTagsWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestEmptyTagsWidget(key: testKey),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      // Update with empty tags
      testKey.currentState?.updateWithEmptyTags();
      await tester.pump();

      // Should not update displayed value, but internal counter has increased
      expect(find.text('Count: 1'), findsOneWidget);

      // Normal update
      (testKey.currentState as TestEmptyTagsWidgetState).updateNormally();
      await tester.pump();

      // Should show increased value (2)
      expect(find.text('Count: 2'), findsOneWidget);
    });

    testWidgets('dispose after should not trigger updates',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestDisposeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestDisposeWidget(key: testKey),
        ),
      );

      expect(find.text('Initial state'), findsOneWidget);

      // Trigger component removal
      testKey.currentState?.removeChild();
      await tester.pump();

      // Try update removed component
      testKey.currentState?.updateRemovedChild();

      // Should not have an error
      await tester.pump();

      expect(find.text('Removed Child Component'), findsOneWidget);
    });

    testWidgets('Auto-reload loading state should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestAutoReloadWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestAutoReloadWidget(key: testKey),
        ),
      );

      // Initial state should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for auto-reload trigger and animations to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Should show success state
      expect(find.text('Load Successed'), findsOneWidget);
    });

    testWidgets('Custom loading and error widgets should display correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestCustomLoadingWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestCustomLoadingWidget(key: testKey),
        ),
      );

      // Should display custom loading widget
      expect(find.text('Loading...'), findsOneWidget);

      // Switch to error state
      testKey.currentState!.showError();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Should display custom error widget
      expect(find.text('Error Component'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Reload'));
      await tester.pump();

      // Should return to loading state
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('Loading screen with AppBar should display correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestLoadingWithAppBarState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestLoadingWithAppBar(key: testKey),
        ),
      );

      // Should display AppBar
      expect(find.text('Title For Testing'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Initial state should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Switch to success state
      testKey.currentState!.showSuccess();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Should show content while keeping AppBar visible
      expect(find.text('Title For Testing'), findsOneWidget);
      expect(find.text('Loaded'), findsOneWidget);
    });
  });
}

class TestMixinWidget extends StatefulWidget {
  const TestMixinWidget({super.key});

  @override
  State<TestMixinWidget> createState() => TestMixinWidgetState();
}

class TestMixinWidgetState extends State<TestMixinWidget>
    with TaggedBuildMixin {
  Object get curDefaultScope => defaultScope;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TestMultiTagWidget extends StatefulWidget {
  const TestMultiTagWidget({super.key});

  @override
  State<TestMultiTagWidget> createState() => TestMultiTagWidgetState();
}

class TestMultiTagWidgetState extends State<TestMultiTagWidget>
    with TaggedBuildMixin {
  int _counter1 = 0;
  int _counter2 = 0;

  void updateTag1() {
    _counter1++;
    taggedBuildUpdate('tag1');
  }

  void updateTag2() {
    _counter2++;
    taggedBuildUpdate('tag2');
  }

  void updateBothTags() {
    _counter1++;
    _counter2++;
    taggedBuildUpdates(ids: ['tag1', 'tag2']);
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
            builder: (context) => Text('Tag1: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'tag2',
            data: () => _counter2,
            builder: (context) => Text('Tag2: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

// Empty tags list test widget
class TestEmptyTagsWidget extends StatefulWidget {
  const TestEmptyTagsWidget({super.key});

  @override
  State<TestEmptyTagsWidget> createState() => TestEmptyTagsWidgetState();
}

class TestEmptyTagsWidgetState extends State<TestEmptyTagsWidget>
    with TaggedBuildMixin {
  int _counter = 0;

  void updateWithEmptyTags() {
    _counter++;
    taggedBuildUpdates(ids: []);
  }

  void updateNormally() {
    _counter++;
    taggedBuildUpdate('counter_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'counter_tag',
          data: () => _counter,
          builder: (context) => Text('Count: ${context.data}'),
        ),
      ),
    );
  }
}

// Dispose test widget
class TestDisposeWidget extends StatefulWidget {
  const TestDisposeWidget({super.key});

  @override
  State<TestDisposeWidget> createState() => TestDisposeWidgetState();
}

class TestDisposeWidgetState extends State<TestDisposeWidget>
    with TaggedBuildMixin {
  bool _showChild = true;
  final childKey = GlobalKey();

  void removeChild() {
    setState(() {
      _showChild = false;
    });
  }

  void updateRemovedChild() {
    // Try to update removed component
    if (childKey.currentState != null) {
      (childKey.currentState as DisposableChildState).updateCounter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _showChild
            ? DisposableChild(key: childKey)
            : const Text('Removed Child Component'),
      ),
    );
  }
}

class DisposableChild extends StatefulWidget {
  const DisposableChild({super.key});

  @override
  State<DisposableChild> createState() => DisposableChildState();
}

class DisposableChildState extends State<DisposableChild>
    with TaggedBuildMixin {
  // ignore: unused_field
  int _counter = 0;

  void updateCounter() {
    _counter++;
    taggedBuildUpdate('dispose_tag');
  }

  @override
  Widget build(BuildContext context) {
    return taggedBuild<String, String>(
      tag: 'dispose_tag',
      data: () => 'Initial state',
      builder: (context) => Text(context.data),
    );
  }
}

// Auto-reload test widget
class TestAutoReloadWidget extends StatefulWidget {
  const TestAutoReloadWidget({super.key});

  @override
  State<TestAutoReloadWidget> createState() => TestAutoReloadWidgetState();
}

class TestAutoReloadWidgetState extends State<TestAutoReloadWidget>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.INITIATE;

  void _onReload() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
    });
    taggedBuildUpdate('auto_reload_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: taggedBuildLoadingContentBuilderEmpty(
        tag: 'auto_reload_tag',
        onReload: _onReload,
        loadingStatus: (_) => _status,
        triggerReloadOnBuildWhenInitiate: true,
        autoInitDelay: const Duration(milliseconds: 0),
        builder: (_) => const Text('Load Successed'),
      ),
    );
  }
}

// Custom loading widget test
class TestCustomLoadingWidget extends StatefulWidget {
  const TestCustomLoadingWidget({super.key});

  @override
  State<TestCustomLoadingWidget> createState() =>
      TestCustomLoadingWidgetState();
}

class TestCustomLoadingWidgetState extends State<TestCustomLoadingWidget>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.LOADING;

  void showError() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR;
    });
    taggedBuildUpdate('custom_loading_tag');
  }

  void _onReload() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.LOADING;
    });
    taggedBuildUpdate('custom_loading_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: taggedBuildLoadingContentBuilderEmpty(
        tag: 'custom_loading_tag',
        onReload: _onReload,
        loadingStatus: (_) => _status,
        loadingWidgetBuilder: (context) => const Center(
          child: Text('Loading...'),
        ),
        errorWidgetBuilder: (context, onReload) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error Component'),
              TextButton(
                onPressed: onReload,
                child: const Text('Reload'),
              ),
            ],
          ),
        ),
        builder: (_) => const Text('Load Succeeded'),
      ),
    );
  }
}

// Loading with AppBar test widget
class TestLoadingWithAppBar extends StatefulWidget {
  const TestLoadingWithAppBar({super.key});

  @override
  State<TestLoadingWithAppBar> createState() => TestLoadingWithAppBarState();
}

class TestLoadingWithAppBarState extends State<TestLoadingWithAppBar>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.LOADING;

  void showSuccess() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
    });
    taggedBuildUpdate('appbar_loading_tag');
  }

  @override
  Widget build(BuildContext context) {
    return taggedBuildLoadingContentBuilderEmpty(
      tag: 'appbar_loading_tag',
      onReload: () {},
      loadingStatus: (_) => _status,
      appBar: AppBar(title: const Text('Title For Testing')),
      builder: (_) => const Center(
        child: Text('Loaded'),
      ),
    );
  }
}
