import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuildContext Tests', () {
    late BuildContext testContext;

    setUpAll(() {
      testContext = MaterialApp(
        home: Builder(
          builder: (context) {
            testContext = context;
            return const Placeholder();
          },
        ),
      ).createElement();
    });

    test('TaggedBuildBaseContext should initialize correctly', () {
      final baseContext = TaggedBuildBaseContext(context: testContext);
      expect(baseContext.context, equals(testContext));
    });

    test(
        'TaggedBuildOptionalContext should initialize correctly and return null data',
        () {
      const tag = 'test_tag';
      const scope = 'test_scope';

      final optionalContext = TaggedBuildOptionalContext<String, int>(
        context: testContext,
        tag: tag,
        scope: scope,
      );

      expect(optionalContext.context, equals(testContext));
      expect(optionalContext.tag, equals(tag));
      expect(optionalContext.scope, equals(scope));
      expect(optionalContext.data, isNull);
    });

    test(
        'TaggedBuildEmptyContext should initialize correctly and return null data',
        () {
      const tag = 'test_tag';
      const scope = 'test_scope';

      final emptyContext = TaggedBuildEmptyContext<String>(
        context: testContext,
        tag: tag,
        scope: scope,
      );

      expect(emptyContext.context, equals(testContext));
      expect(emptyContext.tag, equals(tag));
      expect(emptyContext.scope, equals(scope));
      expect(emptyContext.data, isNull);
    });

    test('TaggedBuildContext should initialize correctly and return data', () {
      const tag = 'test_tag';
      const scope = 'test_scope';
      const data = 42;

      final buildContext = TaggedBuildContext<String, int>(
        context: testContext,
        tag: tag,
        data: data,
        scope: scope,
      );

      expect(buildContext.context, equals(testContext));
      expect(buildContext.tag, equals(tag));
      expect(buildContext.scope, equals(scope));
      expect(buildContext.data, equals(data));
    });
  });
}
