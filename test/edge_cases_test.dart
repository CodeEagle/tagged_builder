import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuilder Edge Cases Tests', () {
    testWidgets('Should handle null data correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestNullDataWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestNullDataWidget(
            key: testKey,
          ),
        ),
      );

      expect(find.text('Data is null'), findsOneWidget);

      // Update to non-null data
      testKey.currentState!.updateToNonNull();
      await tester.pump();

      expect(find.text('Data: Test Data'), findsOneWidget);

      // Update back to null
      testKey.currentState!.updateToNull();
      await tester.pump();

      expect(find.text('Data is null'), findsOneWidget);
    });

    testWidgets('Loading state transitions should be smooth',
        (WidgetTester tester) async {
      final testKey2 = GlobalKey<TestLoadingTransitionWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestLoadingTransitionWidget(key: testKey2),
        ),
      );

      // Initial state should be loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Quick state transition
      testKey2.currentState!.quickTransition();
      await tester.pump();

      // Should show error state
      expect(find.text('Load Failed'), findsOneWidget);

      // Quick transition again
      testKey2.currentState!.quickTransitionToSuccess();
      await tester.pump();

      // Should show success state
      expect(find.text('Load Success'), findsOneWidget);
    });

    testWidgets('Multiple filters should work correctly',
        (WidgetTester tester) async {
      final testKey = GlobalKey<TestMultipleFiltersWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: TestMultipleFiltersWidget(key: testKey),
        ),
      );

      expect(find.text('Multi Filter: 0'), findsOneWidget);

      // Update with conditions not meeting all filters
      testKey.currentState!.updateWithWrongTag();
      await tester.pump();

      // Should not update
      expect(find.text('Multi Filter: 0'), findsOneWidget);

      // Update with correct tag but not meeting value condition
      testKey.currentState!.updateWithCorrectTagButSmallValue();
      await tester.pump();

      // Should not update
      expect(find.text('Multi Filter: 0'), findsOneWidget);

      // Update with all conditions met
      testKey.currentState!.updateWithAllConditionsMet();
      await tester.pump();

      // Should update
      expect(find.text('Multi Filter: 10'), findsOneWidget);
    });
  });
}

// Null data test widget
class TestNullDataWidget extends StatefulWidget {
  const TestNullDataWidget({super.key});

  @override
  State<TestNullDataWidget> createState() => TestNullDataWidgetState();
}

class TestNullDataWidgetState extends State<TestNullDataWidget>
    with TaggedBuildMixin {
  String? _data;

  void updateToNonNull() {
    _data = 'Test Data';
    taggedBuildUpdate('null_tag');
  }

  void updateToNull() {
    _data = null;
    taggedBuildUpdate('null_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, String?>(
          tag: 'null_tag',
          data: () => _data,
          builder: (context) => Text(
            context.data == null ? 'Data is null' : 'Data: ${context.data}',
          ),
        ),
      ),
    );
  }
}

// Loading state transition test widget
class TestLoadingTransitionWidget extends StatefulWidget {
  const TestLoadingTransitionWidget({super.key});

  @override
  State<TestLoadingTransitionWidget> createState() =>
      TestLoadingTransitionWidgetState();
}

class TestLoadingTransitionWidgetState
    extends State<TestLoadingTransitionWidget> with TaggedBuildMixin {
  TAGGED_LOAD_STATUS _status = TAGGED_LOAD_STATUS.LOADING;
  String? _data;

  void quickTransition() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR;
    });
    taggedBuildUpdate('transition_tag');
  }

  void quickTransitionToSuccess() {
    setState(() {
      _status = TAGGED_LOAD_STATUS.SUCCESS;
      _data = 'Load Success';
    });
    taggedBuildUpdate('transition_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuildLoadingContentBuilderData<String, String>(
          tag: 'transition_tag',
          data: () => _data ?? '',
          onReload: () {
            setState(() {
              _status = TAGGED_LOAD_STATUS.LOADING;
            });
            taggedBuildUpdate('transition_tag');
          },
          loadingStatus: (data) => _status,
          errorWidgetBuilder: (context, onReload) => const Text('Load Failed'),
          builder: (context) => Text(context.data),
        ),
      ),
    );
  }
}

// Multiple filters test widget
class TestMultipleFiltersWidget extends StatefulWidget {
  const TestMultipleFiltersWidget({super.key});

  @override
  State<TestMultipleFiltersWidget> createState() =>
      TestMultipleFiltersWidgetState();
}

class TestMultipleFiltersWidgetState extends State<TestMultipleFiltersWidget>
    with TaggedBuildMixin {
  int _counter = 0;

  void updateWithWrongTag() {
    _counter = 10;
    taggedBuildUpdate('wrong_tag');
  }

  void updateWithCorrectTagButSmallValue() {
    _counter = 5;
    taggedBuildUpdate('multi_filter_tag');
  }

  void updateWithAllConditionsMet() {
    _counter = 10;
    taggedBuildUpdate('multi_filter_tag');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: taggedBuild<String, int>(
          tag: 'multi_filter_tag',
          data: () => _counter,
          filter: (info) =>
              info.containsExtraTag('multi_filter_tag') && info.data >= 10,
          builder: (context) => Text('Multi Filter: ${context.data}'),
        ),
      ),
    );
  }
}
