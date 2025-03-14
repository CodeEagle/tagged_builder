import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuilder Basic Function Tests', () {
    testWidgets('taggedBuildEmpty should render correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestWidget(key: testKey),
        ),
      );

      expect(find.text('Initial Text'), findsOneWidget);

      // Trigger update
      testKey.currentState?.taggedBuildUpdate('test_tag');
      await tester.pump();

      expect(find.text('Initial Text'), findsOneWidget);
    });

    testWidgets('taggedBuild should render and update data correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestDataWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestDataWidget(key: testKey),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      // Trigger update and increase count
      testKey.currentState?.incrementAndUpdate();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('taggedBuild should render and update data correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestDataWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestDataWidget(key: testKey),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      // Trigger update and increase count
      testKey.currentState?.incrementAndUpdate();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('Scope control should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestScopeWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestScopeWidget(key: testKey),
        ),
      );

      expect(find.text('Default Scope: 0'), findsOneWidget);
      expect(find.text('Custom Scope: 0'), findsOneWidget);

      // Update default scope only
      (testKey.currentState as TestScopeWidgetState).updateDefaultScope();
      await tester.pump();

      expect(find.text('Default Scope: 1'), findsOneWidget);
      expect(find.text('Custom Scope: 0'), findsOneWidget);

      // Update custom scope only
      (testKey.currentState as TestScopeWidgetState).updateCustomScope();
      await tester.pump();

      expect(find.text('Default Scope: 1'), findsOneWidget);
      expect(find.text('Custom Scope: 1'), findsOneWidget);
    });

    testWidgets('Filter should correctly filter updates',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestFilterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestFilterWidget(key: testKey),
        ),
      );

      expect(find.text('No Filter: 0'), findsOneWidget);
      expect(find.text('With Filter: 0'), findsOneWidget);

      // Update with non-matching tag
      testKey.currentState?.updateWithWrongTag();
      await tester.pump();

      expect(find.text('No Filter: 0'), findsOneWidget);
      expect(find.text('With Filter: 0'), findsOneWidget);

      // Update with matching tag
      (testKey.currentState as TestFilterWidgetState).updateWithCorrectTag();
      await tester.pump();

      expect(find.text('No Filter: 1'), findsOneWidget);
      expect(find.text('With Filter: 1'), findsOneWidget);
    });

    testWidgets('Loading state handling should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestLoadingWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestLoadingWidget(key: testKey),
        ),
      );

      // Initial state should be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Data Loaded'), findsNothing);

      // Simulate loading completion
      testKey.currentState?.completeLoading();
      await tester.pump();
      await tester
          .pump(const Duration(milliseconds: 200)); // Wait for animation

      expect(find.text('Data Loaded'), findsOneWidget);

      // Simulate loading failure
      testKey.currentState?.failLoading();
      await tester.pump();
      await tester
          .pump(const Duration(milliseconds: 200)); // Wait for animation

      expect(find.text('reload'), findsOneWidget);
      expect(find.text('Data Loaded'), findsNothing);
    });
  });
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => TestWidgetState();
}

class TestWidgetState extends State<TestWidget> with TaggedBuildMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuildEmpty(
          tag: 'test_tag',
          builder: (context) => const Text('Initial Text'),
        ),
      ),
    );
  }
}

class TestDataWidget extends StatefulWidget {
  const TestDataWidget({super.key});

  @override
  State<TestDataWidget> createState() => TestDataWidgetState();
}

class TestDataWidgetState extends State<TestDataWidget> with TaggedBuildMixin {
  int _counter = 0;

  void incrementAndUpdate() {
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
    _customCounter++;
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
            data: () => _defaultCounter,
            builder: (context) => Text('Default Scope: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'counter_tag',
            scope: customScope,
            data: () => _customCounter,
            builder: (context) => Text('Custom Scope: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestFilterWidget extends StatefulWidget {
  const TestFilterWidget({super.key});

  @override
  State<TestFilterWidget> createState() => TestFilterWidgetState();
}

class TestFilterWidgetState extends State<TestFilterWidget>
    with TaggedBuildMixin {
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          taggedBuild<String, int>(
            tag: 'filter_tag',
            data: () => _counter,
            builder: (context) => Text('No Filter: ${context.data}'),
          ),
          taggedBuild<String, int>(
            tag: 'filter_tag',
            data: () => _counter,
            filter: (info) => info.containsExtraTag('filter_tag'),
            builder: (context) => Text('With Filter: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestLoadingWidget extends StatefulWidget {
  const TestLoadingWidget({super.key});

  @override
  State<TestLoadingWidget> createState() => TestLoadingWidgetState();
}

class TestLoadingWidgetState extends State<TestLoadingWidget>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.LOADING;
  String? _data;

  void completeLoading() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
      _data = "Data Loaded";
    });
    taggedBuildUpdate('loading_tag');
  }

  void failLoading() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR;
      _data = null;
    });
    taggedBuildUpdate('loading_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuildLoadingContentBuilderData<String, String>(
          tag: 'loading_tag',
          data: () => _data ?? "",
          onReload: () {
            setState(() {
              _status = TAGGED_LOAD_STATUS.LOADING;
            });
            taggedBuildUpdate('loading_tag');
          },
          loadingStatus: (data) => _status,
          builder: (context) => Text(context.data),
        ),
      ),
    );
  }
}

class TestEmptyLoadingWidget extends StatefulWidget {
  final GlobalKey testKey;

  const TestEmptyLoadingWidget({super.key, required this.testKey});

  @override
  State<TestEmptyLoadingWidget> createState() => TestEmptyLoadingWidgetState();
}

class TestEmptyLoadingWidgetState extends State<TestEmptyLoadingWidget>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.LOADING;

  void completeLoading() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
    });
    taggedBuildUpdate('empty_loading_tag');
  }

  void failLoading() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR;
    });
    taggedBuildUpdate('empty_loading_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.testKey,
      body: Center(
        child: taggedBuildLoadingContentBuilderEmpty<String, String>(
          tag: 'empty_loading_tag',
          onReload: () {
            setState(() {
              _status = TAGGED_LOAD_STATUS.LOADING;
            });
            taggedBuildUpdate('empty_loading_tag');
          },
          loadingStatus: (_) => _status,
          builder: (_) => const Text('Empty Data Loaded'),
        ),
      ),
    );
  }
}

class TestMultiTagsWidget extends StatefulWidget {
  final GlobalKey testKey;

  const TestMultiTagsWidget({super.key, required this.testKey});

  @override
  State<TestMultiTagsWidget> createState() => TestMultiTagsWidgetState();
}

class TestMultiTagsWidgetState extends State<TestMultiTagsWidget>
    with TaggedBuildMixin {
  int _counter1 = 0;
  int _counter2 = 0;
  int _counter3 = 0;

  void updateAllTags() {
    _counter1++;
    _counter2++;
    _counter3++;
    taggedBuildUpdates(ids: ['tag1', 'tag2', 'tag3']);
  }

  void updateEmptyTags() {
    _counter1++;
    _counter2++;
    _counter3++;
    taggedBuildUpdates(ids: []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.testKey,
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
          taggedBuild<String, int>(
            tag: 'tag3',
            data: () => _counter3,
            builder: (context) => Text('Tag3: ${context.data}'),
          ),
        ],
      ),
    );
  }
}

class TestAutoInitWidget extends StatefulWidget {
  final GlobalKey testKey;

  const TestAutoInitWidget({super.key, required this.testKey});

  @override
  State<TestAutoInitWidget> createState() => TestAutoInitWidgetState();
}

class TestAutoInitWidgetState extends State<TestAutoInitWidget>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.INITIATE;
  String? _data;
  bool _reloadCalled = false;

  bool get reloadCalled => _reloadCalled;

  void setData(String data) {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
      _data = data;
    });
    taggedBuildUpdate('auto_init_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.testKey,
      body: Center(
        child: taggedBuildLoadingContentBuilderData<String, String>(
          tag: 'auto_init_tag',
          data: () => _data ?? "",
          onReload: () {
            _reloadCalled = true;
            setState(() {
              _status = TAGGED_LOAD_STATUS.LOADING;
            });
            Future.delayed(const Duration(milliseconds: 100), () {
              setData("Auto Loaded Data");
            });
          },
          triggerReloadOnBuildWhenInitiate: true,
          autoInitDelay: const Duration(milliseconds: 50),
          loadingStatus: (data) => _status,
          builder: (context) => Text(context.data),
        ),
      ),
    );
  }
}

class TestCustomLoadingWidget extends StatefulWidget {
  final GlobalKey testKey;

  const TestCustomLoadingWidget({super.key, required this.testKey});

  @override
  State<TestCustomLoadingWidget> createState() =>
      TestCustomLoadingWidgetState();
}

class TestCustomLoadingWidgetState extends State<TestCustomLoadingWidget>
    with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.LOADING;
  String? _data;

  void completeLoading() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
      _data = "Data Loaded";
    });
    taggedBuildUpdate('custom_loading_tag');
  }

  void failLoading() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR;
      _data = null;
    });
    taggedBuildUpdate('custom_loading_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.testKey,
      body: Center(
        child: taggedBuildLoadingContentBuilderData<String, String>(
          tag: 'custom_loading_tag',
          data: () => _data ?? "",
          onReload: () {
            setState(() {
              _status = TAGGED_LOAD_STATUS.LOADING;
            });
            taggedBuildUpdate('custom_loading_tag');
          },
          loadingStatus: (data) => _status,
          loadingWidgetBuilder: (context) => const Text('Loading...'),
          errorWidgetBuilder: (context, onReload) => TextButton(
            onPressed: onReload,
            child: const Text('Retry'),
          ),
          builder: (context) => Text(context.data),
        ),
      ),
    );
  }
}
