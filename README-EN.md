# TaggedBuilder

[README-CN](README.md)

## Elegant Tag-Based State Management

TaggedBuilder is a lightweight, flexible Flutter state management solution that uses tags to identify and track state changes, making your code clearer, more modular, and easier to maintain.

### 🌟 Key Features

- **Tag-Based State Management**: Use tags instead of context to identify and update state
- **Flexible Scope Control**: Precisely control the scope of state updates
- **Clean API**: Intuitive interface that reduces boilerplate code
- **High Performance**: Precise rebuilding mechanism, only relevant components update
- **No Dependencies**: Doesn't rely on other state management libraries, can coexist with existing solutions
- **Built-in Loading State Handling**: Elegantly handle loading, error, and success states

## 📦 Installation

```yaml
dependencies:
  tagged_builder: ^1.0.0
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:tagged_builder/tagged_builder.dart';

class MyWidget extends StatelessWidget with TaggedBuildMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Create a tag builder without data
        taggedBuildEmpty(
          tag: 'counter',
          builder: (context) => Text('Click the button to increase the count'),
        ),

        // Create a tag builder with data
        taggedBuild<String, int>(
          tag: 'counter',
          data: () => 0,  // Initial data
          builder: (context) => Text('Count: ${context.data}'),
        ),

        // Button to update the tag state
        ElevatedButton(
          onPressed: () => taggedBuildUpdate('counter'),
          child: Text('Increase'),
        ),
      ],
    );
  }
}
```

### Handling Loading States

```dart
taggedBuild<String, Future<List<User>>>(
  tag: 'users',
  data: () => fetchUsers(),
  builder: (context) {
    return ListView.builder(
      itemCount: context.data.length,
      itemBuilder: (context, index) => UserTile(user: context.data[index]),
    );
  },
);

// Or use the built-in loading state handler
taggedBuildLoadingContentBuilderData<String, List<User>>(
  tag: 'users',
  data: () => _users,
  onReload: _fetchUsers,
  loadingStatus: (data) => data == null
    ? TAGGED_LOAD_STATUS.LOADING
    : TAGGED_LOAD_STATUS.SUCCESS,
  builder: (context) {
    return ListView.builder(
      itemCount: context.data.length,
      itemBuilder: (context, index) => UserTile(user: context.data[index]),
    );
  },
);
```

## 🧩 Advanced Usage

### Filtering Updates

```dart
taggedBuild<String, UserData>(
  tag: 'user_profile',
  data: () => userData,
  filter: (info) => info.containsExtraTag('user_avatar'),
  builder: (context) => UserAvatar(url: context.data.avatarUrl),
);

// Only update the avatar
taggedBuildUpdate('user_avatar');
```

### Scope Control

```dart
// In the parent component
final chatScope = Object();

// In the child component
taggedBuild<String, Message>(
  tag: 'new_message',
  scope: chatScope,
  data: () => message,
  builder: (context) => MessageBubble(message: context.data),
);

// Only update components in the specific scope
taggedBuildUpdates(['new_message'], scope: chatScope);
```

## 📚 API Documentation

### Core Classes

- **TaggedBuilder**: Core component for building widgets that respond to tag changes
- **TaggedBuildMixin**: Mixin providing convenient methods, recommended for use in StatelessWidget
- **TaggedBuildContext**: Context provided to builder functions, containing tag and data

### Main Methods

- **taggedBuild**: Create a tag builder with data
- **taggedBuildEmpty**: Create a tag builder without data
- **taggedBuildUpdate**: Update a single tag
- **taggedBuildUpdates**: Update multiple tags
- **taggedBuildLoadingContentBuilderEmpty**: Create a loading state handler builder without data
- **taggedBuildLoadingContentBuilderData**: Create a loading state handler builder with data

## 🤔 Why Choose TaggedBuilder?

Compared to other state management solutions, TaggedBuilder provides a more flexible and intuitive way to handle UI updates. It doesn't require complex Provider trees or global state, but instead uses a simple tag system to identify components that need updating.

This approach is particularly suitable for:

- Scenarios requiring state changes to be passed between unrelated components
- Performance-sensitive applications that want to avoid excessive rebuilds
- Complex UIs that need precise control over the scope of state updates

## 📝 License

MIT License - See the [LICENSE](LICENSE) file for details

```

```
