part of '../tagged_builder.dart';

/// Internal class that holds information about a build update event
class _TaggedBuildUpdateInfo {
  /// List of tags that triggered this update
  final List<Object?>? tags;

  /// The scope this update applies to
  final Object? scope;

  const _TaggedBuildUpdateInfo({
    required this.tags,
    this.scope,
  });
}
