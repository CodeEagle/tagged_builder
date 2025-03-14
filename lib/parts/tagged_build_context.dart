part of '../tagged_builder.dart';

typedef TaggedBuilderOptionalConstructor<Tag, Data> = Widget Function(
    TaggedBuildOptionalContext<Tag, Data>);
typedef TaggedBuilderEmptyConstructor<Tag> = Widget Function(
    TaggedBuildEmptyContext<Tag>);
typedef TaggedBuilderConstructor<Tag, Data> = Widget Function(
    TaggedBuildContext<Tag, Data>);

class TaggedBuildBaseContext {
  final BuildContext context;
  const TaggedBuildBaseContext({required this.context});
}

class TaggedBuildOptionalContext<Tag, Data> extends TaggedBuildBaseContext {
  final Tag tag;
  Data? get data => null;
  final dynamic scope;
  const TaggedBuildOptionalContext({
    required super.context,
    required this.tag,
    this.scope,
  });
}

class TaggedBuildEmptyContext<Tag>
    extends TaggedBuildOptionalContext<Tag, String> {
  @override
  String? get data => null;

  const TaggedBuildEmptyContext({
    required super.context,
    required super.tag,
    super.scope,
  });
}

class TaggedBuildContext<Tag, Data>
    extends TaggedBuildOptionalContext<Tag, Data> {
  @override
  final Data data;
  const TaggedBuildContext({
    required super.context,
    required super.tag,
    required this.data,
    super.scope,
  });
}
