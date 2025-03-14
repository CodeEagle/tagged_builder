part of '../tagged_builder.dart';

/// A public interface for testing purposes
@visibleForTesting
class TaggedBuildBus {
  /// Returns the shared instance of the TaggedBuildBus
  static get shared => _TaggedBuildBus.shared;
}

/// Internal implementation of the TaggedBuildBus
/// Manages the registration, updates, and unregistration of tagged builders
class _TaggedBuildBus {
  /// Singleton instance of the TaggedBuildBus
  static final shared = _TaggedBuildBus._();

  /// Private constructor to enforce singleton pattern
  _TaggedBuildBus._();

  /// Stream controller for broadcasting build updates
  /// Uses sync mode to ensure immediate delivery of events
  final StreamController<_TaggedBuildUpdateInfo> buildStreamController =
      StreamController.broadcast(sync: true);

  /// Map to store registered builders by their IDs
  Map<String, _TaggedBuildInfo> buildIds = {};

  /// Updates registered builders based on tags and scope
  ///
  /// [tags] - List of tags to update. If null or empty, updates all registered builders
  /// [scope] - Optional scope to limit the update to specific builders
  void update<S>([List<dynamic>? tags, dynamic scope]) {
    var tagsToBuild = [];
    if (tags == null || tags.isEmpty) {
      tagsToBuild = buildIds.values.map((e) => e.tag).toList();
    } else {
      tagsToBuild = tags;
    }
    buildStreamController
        .add(_TaggedBuildUpdateInfo(tags: tagsToBuild, scope: scope));
  }

  /// Unregisters a builder by its ID
  ///
  /// [id] - The ID of the builder to unregister
  void unregister(String? id) {
    if (id != null) {
      buildIds.remove(id);
    }
  }

  /// Registers a new builder with the bus
  ///
  /// [info] - The build information containing tag, builder function, and other settings
  /// [id] - Optional custom ID for the builder. If not provided, generates a timestamp-based ID
  ///
  /// Returns a [_TaggedBuilderRegisterInfo] containing the ID and widget
  _TaggedBuilderRegisterInfo register<Tag, Data>(
      _TaggedBuildInfo<Tag, Data> info,
      {String? id}) {
    final now = DateTime.now();
    final targetId = id ?? "tb_id_${now.millisecondsSinceEpoch}";

    // Create a filtered stream for this builder
    final stream = buildStreamController.stream.where((scopeInfo) {
      final filter = info.filter;
      bool canBuild = (scopeInfo.tags?.contains(info.tag) == true) &&
          info.scope == scopeInfo.scope &&
          buildIds.keys.contains(targetId);
      if (filter != null) {
        final data = info.data?.call();
        dynamic filterInfo = data == null
            ? TaggedBuildEmptyFilterInfo(
                tag: info.tag, scope: info.scope, updateTags: scopeInfo.tags)
            : TaggedBuildFilterInfo(
                tag: info.tag,
                data: data,
                scope: info.scope,
                updateTags: scopeInfo.tags);
        canBuild = filter(filterInfo);
      }
      return canBuild;
    });

    // Create a StreamBuilder that rebuilds when the stream emits new values
    final child = StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          final data = info.data?.call();
          final buildContext = data == null
              ? TaggedBuildEmptyContext(
                  context: context, tag: info.tag, scope: info.scope)
              : TaggedBuildContext(
                  context: context,
                  tag: info.tag,
                  data: data,
                  scope: info.scope);
          return info.builder(buildContext as dynamic);
        });
    final result = _TaggedBuilderRegisterInfo(targetId, child);
    buildIds[result.id] = info;
    return result;
  }
}

/// Container class for builder registration information
class _TaggedBuilderRegisterInfo {
  /// Unique identifier for the registered builder
  final String id;

  /// The widget created by the builder
  final Widget widget;

  const _TaggedBuilderRegisterInfo(this.id, this.widget);
}
