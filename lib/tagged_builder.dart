library tagged_builder;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

part 'parts/tagged_build_bus.dart';
part 'parts/tagged_build_context.dart';
part 'parts/tagged_build_filter_info.dart';
part 'parts/tagged_build_info.dart';
part 'parts/tagged_build_mixin.dart';
part 'parts/tagged_build_update_info.dart';

/// Main class that provides static methods for creating tagged builders
class TaggedBuilder<Tag, Data> extends StatefulWidget {
  /// The [tag] property is used to find the [TaggedValue] from the [TaggedProvider] in
  /// the widget tree.
  final Tag tag;

  /// The [builder] function will be called whenever the [Tagged] value changes. This
  /// is similar to [ValueListenableBuilder] and [StreamBuilder].
  final TaggedBuilderOptionalConstructor<Tag, Data> builder;

  /// The [data] property can be used to provide a value to the [builder] function instead
  /// of using the value from the [TaggedValue].
  final Data Function()? getData;

  /// The [filter] property can be used to filter the [data] value from the [TaggedValue]
  /// before it is passed to the [builder] function. This is useful if the [TaggedValue]
  /// contains more than one value.
  final TaggedBuildOptionalFilter<Tag, Data>? filter;

  /// The [scope] property can be used to limit the scope of the [TaggedProvider] that
  /// is searched for the [TaggedValue].
  final Object? scope;

  final String? id;

  const TaggedBuilder({
    super.key,
    required this.tag,
    required this.builder,
    this.filter,
    this.getData,
    this.scope,
    this.id,
  });

  @override
  State<StatefulWidget> createState() => _TaggedBuilderState<Tag, Data>();

  /// Creates a builder without data
  ///
  /// [tag] - The tag for this builder
  /// [builder] - The builder function
  /// [filter] - Optional filter for controlling updates
  /// [scope] - Optional scope for this builder
  /// [id] - Optional custom ID for this builder
  static Widget empty<Tag>({
    required Tag tag,
    required TaggedBuilderEmptyConstructor<Tag> builder,
    TaggedBuildEmptyFilter<Tag>? filter,
    Object? scope,
    String? id,
  }) =>
      TaggedBuilder<Tag, String>(
        tag: tag,
        builder: (p0) => builder(TaggedBuildEmptyContext(
            context: p0.context, tag: p0.tag, scope: p0.scope)),
        filter: filter == null
            ? null
            : (info) => filter(TaggedBuildEmptyFilterInfo(
                tag: info.tag, scope: info.scope, updateTags: info.updateTags)),
        scope: scope,
        id: id,
      );

  /// Creates a builder with data
  ///
  /// [tag] - The tag for this builder
  /// [builder] - The builder function
  /// [data] - Function that provides the data
  /// [filter] - Optional filter for controlling updates
  /// [scope] - Optional scope for this builder
  /// [id] - Optional custom ID for this builder
  static Widget data<Tag, Data>({
    required Tag tag,
    required Data Function() data,
    required TaggedBuilderConstructor<Tag, Data> builder,
    TaggedBuildFilter<Tag, Data>? filter,
    Object? scope,
    String? id,
  }) =>
      TaggedBuilder<Tag, Data>(
        tag: tag,
        getData: data,
        builder: (context) => builder(TaggedBuildContext(
          context: context.context,
          tag: context.tag,
          data: context.data ?? data(),
          scope: context.scope,
        )),
        filter: filter == null
            ? null
            : (info) => filter(TaggedBuildFilterInfo(
                tag: info.tag,
                data: info.data ?? data(),
                scope: info.scope,
                updateTags: info.updateTags)),
        scope: scope,
        id: id,
      );
}

class _TaggedBuilderState<Tag, Data> extends State<TaggedBuilder<Tag, Data>> {
  VoidCallback? _disposeAction;

  @override
  void dispose() {
    _disposeAction?.call();
    _disposeAction = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 考虑缓存这个实例，只在相关属性变化时重新创建
    final value = _TaggedBuildBus.shared.register<Tag, Data>(
      _TaggedBuildInfo<Tag, Data>(
        builder: widget.builder,
        filter: widget.filter,
        tag: widget.tag,
        data: widget.getData,
        scope: widget.scope,
      ),
      id: widget.id,
    );
    _disposeAction = () => _TaggedBuildBus.shared.unregister(value.id);
    return value.widget;
  }
}
