part of '../tagged_builder.dart';

/// Internal class that holds information for a tagged builder
class _TaggedBuildInfo<Tag, Data> {
  /// The tag used to identify this builder
  final Tag tag;

  /// The scope this builder belongs to
  final Object? scope;

  /// Optional filter function to control when the builder should update
  final TaggedBuildOptionalFilter<Tag, Data>? filter;

  /// The builder function that creates the widget
  final TaggedBuilderOptionalConstructor<Tag, Data> builder;

  /// Function that provides the data for this builder
  final Data Function()? data;

  const _TaggedBuildInfo({
    required this.tag,
    required this.builder,
    this.filter,
    this.scope,
    this.data,
  });
}
