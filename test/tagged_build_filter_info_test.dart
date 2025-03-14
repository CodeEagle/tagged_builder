import 'package:flutter_test/flutter_test.dart';
import 'package:tagged_builder/tagged_builder.dart';

void main() {
  group('TaggedBuildFilterInfo Tests', () {
    test(
        'TaggedBuildEmptyFilterInfo should initialize correctly and return null data',
        () {
      const info = TaggedBuildEmptyFilterInfo(
        tag: 'test_tag',
        scope: 'test_scope',
        updateTags: ['tag1', 'tag2'],
      );

      expect(info.tag, equals('test_tag'));
      expect(info.scope, equals('test_scope'));
      expect(info.updateTags, equals(['tag1', 'tag2']));
      expect(info.data, isNull);
    });

    test('TaggedBuildFilterInfo should initialize correctly and return data',
        () {
      const info = TaggedBuildFilterInfo(
        tag: 'test_tag',
        data: 42,
        scope: 'test_scope',
        updateTags: ['tag1', 'tag2'],
      );

      expect(info.tag, equals('test_tag'));
      expect(info.data, equals(42));
      expect(info.scope, equals('test_scope'));
      expect(info.updateTags, equals(['tag1', 'tag2']));
    });

    group('containsExtraTags tests', () {
      test('should return false when updateTags is null', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: null,
        );

        expect(info.containsExtraTags(['tag1', 'tag2']), isFalse);
      });

      test('should return false when no tags match', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: ['tag3', 'tag4'],
        );

        expect(info.containsExtraTags(['tag1', 'tag2']), isFalse);
      });

      test('should return true when there are matching tags', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: ['tag1', 'tag3'],
        );

        expect(info.containsExtraTags(['tag1', 'tag2']), isTrue);
      });

      test('should return true when own tag matches', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: ['test_tag'],
        );

        expect(info.containsExtraTags(['other_tag']), isTrue);
      });
    });

    group('containsExtraTag tests', () {
      test('should return false when updateTags is null', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: null,
        );

        expect(info.containsExtraTag('tag1'), isFalse);
      });

      test('should return false when tag does not match', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: ['tag2', 'tag3'],
        );

        expect(info.containsExtraTag('tag1'), isFalse);
      });

      test('should return true when tag matches', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: ['tag1', 'tag2'],
        );

        expect(info.containsExtraTag('tag1'), isTrue);
      });

      test('should return true when own tag matches', () {
        const info = TaggedBuildFilterInfo<String, int>(
          tag: 'test_tag',
          data: 42,
          updateTags: ['test_tag'],
        );

        expect(info.containsExtraTag('test_tag'), isTrue);
      });
    });
  });
}
