part of '../tagged_builder.dart';

/// Function type for filters that can handle optional data
typedef TaggedBuildOptionalFilter<Tag, Data> = bool Function(
    TaggedBuildOptionalFilterInfo<Tag, Data> info);

/// Function type for filters that don't require data
typedef TaggedBuildEmptyFilter<Tag> = bool Function(
    TaggedBuildEmptyFilterInfo<Tag> info);

/// Function type for filters that require data
typedef TaggedBuildFilter<Tag, Data> = bool Function(
    TaggedBuildFilterInfo<Tag, Data> info);

/// Base class for filter information
abstract class TaggedBuildOptionalFilterInfo<Tag, Data> {
  /// The tag associated with this filter
  final Tag tag;

  /// Optional data that may be null
  Data? get data;

  /// The scope this filter belongs to
  final dynamic scope;

  /// List of tags that triggered the update
  final List<dynamic>? updateTags;

  const TaggedBuildOptionalFilterInfo({
    required this.tag,
    this.scope,
    this.updateTags,
  });

  /// Checks if any of the provided tags match the update tags
  bool containsExtraTags(List<dynamic> tags) =>
      [...tags, tag].where((e) => updateTags?.contains(e) == true).isNotEmpty;

  /// Convenience method to check a single tag
  bool containsExtraTag(dynamic extraTag) => containsExtraTags([extraTag]);
}

/// Filter information for builders without data
class TaggedBuildEmptyFilterInfo<Tag>
    extends TaggedBuildOptionalFilterInfo<Tag, String> {
  /// Always returns null as empty filters have no data
  @override
  get data => null;

  const TaggedBuildEmptyFilterInfo({
    required super.tag,
    super.scope,
    super.updateTags,
  });
}

/// Filter information for builders with data
class TaggedBuildFilterInfo<Tag, Data>
    extends TaggedBuildOptionalFilterInfo<Tag, Data> {
  /// The actual data associated with this filter
  @override
  final Data data;

  const TaggedBuildFilterInfo({
    required super.tag,
    required this.data,
    super.scope,
    super.updateTags,
  });
}
