part of '../tagged_builder.dart';

/// Random number generator for generating unique scope IDs
final _taggedBuildRnd = Random();

/// Function type for determining loading status with optional data
typedef TaggedBuildLoadingStatusConstructor<Data> = TAGGED_LOAD_STATUS Function(
    Data?);

/// Function type for determining loading status with required data
typedef TaggedBuildLoadingStatusDataConstructor<Data> = TAGGED_LOAD_STATUS
    Function(Data);

/// Mixin that provides tagged building functionality
mixin TaggedBuildMixin {
  /// Default scope for this mixin instance
  /// Generated randomly to ensure uniqueness
  late final defaultScope = 'tb_scope_${_taggedBuildRnd.nextInt(100000000)}';

  /// Updates a single tag with optional scope
  ///
  /// [id] - The tag to update
  /// [scope] - Optional scope to limit the update
  void taggedBuildUpdate(dynamic id, {Object? scope}) =>
      taggedBuildUpdates(ids: [id], scope: scope);

  /// Unregisters a builder by its ID
  ///
  /// [id] - The ID of the builder to unregister
  void taggedBuildUnregister(String? id) =>
      _TaggedBuildBus.shared.unregister(id);

  /// Updates multiple tags with optional scope
  ///
  /// [ids] - List of tags to update. If null, updates all registered widgets
  /// [scope] - Optional scope to limit the update
  void taggedBuildUpdates({List<dynamic>? ids, Object? scope}) =>
      _TaggedBuildBus.shared.update(ids, scope ?? defaultScope);

  /// Creates a builder without data
  ///
  /// [tag] - The tag for this builder
  /// [filter] - Optional filter for controlling updates
  /// [builder] - The builder function
  /// [scope] - Optional scope for this builder
  /// [id] - Optional custom ID for this builder
  Widget taggedBuildEmpty<Tag>({
    required Tag tag,
    TaggedBuildEmptyFilter<Tag>? filter,
    required TaggedBuilderEmptyConstructor<Tag> builder,
    Object? scope,
    String? id,
  }) =>
      TaggedBuilder.empty<Tag>(
          tag: tag,
          builder: builder,
          filter: filter,
          scope: scope ?? defaultScope,
          id: id);

  /// Creates a builder with data
  ///
  /// [tag] - The tag for this builder
  /// [data] - Function that provides the data
  /// [builder] - The builder function
  /// [filter] - Optional filter for controlling updates
  /// [scope] - Optional scope for this builder
  /// [id] - Optional custom ID for this builder
  Widget taggedBuild<Tag, Data>({
    required Tag tag,
    required Data Function() data,
    required TaggedBuilderConstructor<Tag, Data> builder,
    TaggedBuildFilter<Tag, Data>? filter,
    Object? scope,
    String? id,
  }) =>
      TaggedBuilder.data(
          tag: tag,
          builder: builder,
          data: data,
          filter: filter,
          scope: scope ?? defaultScope,
          id: id);

  /// Creates a loading content builder without data
  ///
  /// [tag] - The tag for this builder
  /// [onReload] - Callback function when reload is triggered
  /// [loadingStatus] - Function to determine the current loading status
  /// [builder] - The builder function for content
  /// [triggerReloadOnBuildWhenInitiate] - Whether to automatically trigger reload on initial build
  /// [animationDuration] - Duration for state transition animations
  /// [autoInitDelay] - Delay before auto-triggering reload
  /// [loadingWidgetBuilder] - Custom loading widget builder
  /// [errorWidgetBuilder] - Custom error widget builder
  /// [appBar] - Optional app bar for the scaffold
  /// [scope] - Optional scope for this builder
  /// [id] - Optional custom ID for this builder
  Widget taggedBuildLoadingContentBuilderEmpty<Tag, Data>({
    required Tag tag,
    required VoidCallback onReload,
    required TaggedBuildLoadingStatusConstructor<Data> loadingStatus,
    required Widget Function(TaggedBuildEmptyContext<Tag>) builder,
    bool triggerReloadOnBuildWhenInitiate = false,
    animationDuration = const Duration(milliseconds: 150),
    Duration autoInitDelay = const Duration(milliseconds: 500),
    Widget Function(BuildContext context)? loadingWidgetBuilder,
    Widget Function(BuildContext context, VoidCallback onReload)?
        errorWidgetBuilder,
    AppBar? appBar,
    Object? scope,
    String? id,
  }) {
    return taggedBuildEmpty(
      tag: tag,
      scope: scope,
      id: id,
      builder: (context) {
        return _loadingContentBuilder(
          appBar: appBar,
          loadingStatus: loadingStatus,
          onReload: onReload,
          context: context.context,
          contentBuilder: () => builder(context),
          loadingWidgetBuilder: loadingWidgetBuilder,
          errorWidgetBuilder: errorWidgetBuilder,
          animationDuration: animationDuration,
          autoInitDelay: autoInitDelay,
          triggerReloadOnBuildWhenInitiate: triggerReloadOnBuildWhenInitiate,
        );
      },
    );
  }

  /// Creates a loading content builder with data
  ///
  /// [tag] - The tag for this builder
  /// [data] - Function that provides the data
  /// [onReload] - Callback function when reload is triggered
  /// [loadingStatus] - Function to determine the current loading status based on data
  /// [builder] - The builder function for content
  /// [triggerReloadOnBuildWhenInitiate] - Whether to automatically trigger reload on initial build
  /// [animationDuration] - Duration for state transition animations
  /// [autoInitDelay] - Delay before auto-triggering reload
  /// [loadingWidgetBuilder] - Custom loading widget builder
  /// [errorWidgetBuilder] - Custom error widget builder
  /// [appBar] - Optional app bar for the scaffold
  /// [scope] - Optional scope for this builder
  Widget taggedBuildLoadingContentBuilderData<Tag, Data>({
    required Tag tag,
    required Data Function() data,
    required VoidCallback onReload,
    required TaggedBuildLoadingStatusDataConstructor<Data> loadingStatus,
    required Widget Function(TaggedBuildContext<Tag, Data>) builder,
    bool triggerReloadOnBuildWhenInitiate = false,
    animationDuration = const Duration(milliseconds: 150),
    Duration autoInitDelay = const Duration(milliseconds: 500),
    Widget Function(BuildContext context)? loadingWidgetBuilder,
    Widget Function(BuildContext context, VoidCallback onReload)?
        errorWidgetBuilder,
    AppBar? appBar,
    Object? scope,
  }) {
    return taggedBuild<Tag, Data>(
      tag: tag,
      scope: scope,
      data: data,
      builder: (context) {
        final d = data();
        return _loadingContentBuilder(
          appBar: appBar,
          loadingStatus: ((data) => loadingStatus(d)),
          onReload: onReload,
          context: context.context,
          contentBuilder: () => builder(context),
          loadingWidgetBuilder: loadingWidgetBuilder,
          errorWidgetBuilder: errorWidgetBuilder,
          animationDuration: animationDuration,
          autoInitDelay: autoInitDelay,
          triggerReloadOnBuildWhenInitiate: triggerReloadOnBuildWhenInitiate,
          data: data(),
        );
      },
    );
  }

  /// Triggers a delayed reload based on the current loading status
  ///
  /// [status] - Current loading status
  /// [delay] - Duration to wait before triggering reload
  /// [onReload] - Callback function to execute after delay
  void delayTriggerReload(
      TAGGED_LOAD_STATUS status, Duration delay, VoidCallback onReload) async {
    if (status == TAGGED_LOAD_STATUS.INITIATE) {
      await Future.delayed(delay);
      onReload();
    }
  }

  /// Internal helper method to create a loading content builder with state management
  ///
  /// [loadingStatus] - Function to determine the current loading status
  /// [onReload] - Callback function when reload is triggered
  /// [context] - Build context for the widget
  /// [contentBuilder] - Builder function for the main content
  /// [triggerReloadOnBuildWhenInitiate] - Whether to automatically trigger reload on initial build
  /// [autoInitDelay] - Delay before auto-triggering reload
  /// [animationDuration] - Duration for state transition animations
  /// [loadingWidgetBuilder] - Custom loading widget builder
  /// [errorWidgetBuilder] - Custom error widget builder
  /// [data] - Optional data for the builder
  /// [appBar] - Optional app bar for the scaffold
  Widget _loadingContentBuilder<Tag, Data>({
    required TaggedBuildLoadingStatusConstructor<Data> loadingStatus,
    required VoidCallback onReload,
    required BuildContext context,
    required Widget Function() contentBuilder,
    bool triggerReloadOnBuildWhenInitiate = false,
    Duration autoInitDelay = const Duration(milliseconds: 500),
    animationDuration = const Duration(milliseconds: 150),
    Widget Function(BuildContext context)? loadingWidgetBuilder,
    Widget Function(BuildContext context, VoidCallback onReload)?
        errorWidgetBuilder,
    Data? data,
    AppBar? appBar,
  }) {
    final status = loadingStatus(data);
    if (triggerReloadOnBuildWhenInitiate) {
      delayTriggerReload(status, autoInitDelay, onReload);
    }
    final child = Stack(
      children: [
        AnimatedOpacity(
          opacity: status.index <= TAGGED_LOAD_STATUS.LOADING.index ? 1 : 0,
          duration: animationDuration,
          child: loadingWidgetBuilder?.call(context) ??
              const Center(
                child: CircularProgressIndicator(),
              ),
        ),
        IgnorePointer(
          ignoring: status != TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR,
          child: AnimatedOpacity(
            opacity: status == TAGGED_LOAD_STATUS.FINISHED_WITH_ERROR ? 1 : 0,
            duration: animationDuration,
            child: errorWidgetBuilder?.call(context, onReload) ??
                Center(
                  child: GestureDetector(
                      onTap: onReload, child: const Text('reload')),
                ),
          ),
        ),
        IgnorePointer(
          ignoring: status != TAGGED_LOAD_STATUS.SUCCESS,
          child: AnimatedOpacity(
            opacity: status == TAGGED_LOAD_STATUS.SUCCESS ? 1 : 0,
            duration: animationDuration,
            child: status == TAGGED_LOAD_STATUS.SUCCESS
                ? contentBuilder()
                : Container(),
          ),
        ),
      ],
    );
    if (appBar != null) {
      return Scaffold(appBar: appBar, body: child);
    }
    return child;
  }
}

/// Enum representing different loading states for tagged builders
///
/// [INITIATE] - Initial state before loading starts
/// [LOADING] - Currently loading data
/// [FINISHED_WITH_ERROR] - Loading completed with an error
/// [SUCCESS] - Loading completed successfully
enum TAGGED_LOAD_STATUS {
  INITIATE,
  LOADING,
  FINISHED_WITH_ERROR,
  SUCCESS,
}
