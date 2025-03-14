# TaggedBuilder

[README-EN](README-EN.md)

## 优雅的标签式状态管理

TaggedBuilder 是一个轻量级、灵活的 Flutter 状态管理解决方案，它使用标签（Tag）来标识和追踪状态变化，让您的代码更加清晰、模块化和易于维护。

### 🌟 主要特性

- **基于标签的状态管理**：使用标签而非上下文来识别和更新状态
- **灵活的作用域控制**：精确控制状态更新的范围
- **简洁的 API**：直观易用的接口，减少模板代码
- **高性能**：精确的重建机制，只有相关组件才会更新
- **无依赖**：不依赖其他状态管理库，可以与现有方案共存
- **内置加载状态处理**：优雅处理加载、错误和成功状态

## 📦 安装

```yaml
dependencies:
  tagged_builder: ^1.0.0
```

## 🚀 快速开始

### 基本用法

```dart
import 'package:flutter/material.dart';
import 'package:tagged_builder/tagged_builder.dart';

class MyWidget extends StatelessWidget with TaggedBuildMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 创建一个不带数据的标签构建器
        taggedBuildEmpty(
          tag: 'counter',
          builder: (context) => Text('点击按钮增加计数'),
        ),

        // 创建一个带数据的标签构建器
        taggedBuild<String, int>(
          tag: 'counter',
          data: () => 0,  // 初始数据
          builder: (context) => Text('计数: ${context.data}'),
        ),

        // 更新标签状态的按钮
        ElevatedButton(
          onPressed: () => taggedBuildUpdate('counter'),
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

### 处理加载状态

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

// 或使用内置的加载状态处理
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

## 🧩 高级用法

### 过滤更新

```dart
taggedBuild<String, UserData>(
  tag: 'user_profile',
  data: () => userData,
  filter: (info) => info.containsExtraTag('user_avatar'),
  builder: (context) => UserAvatar(url: context.data.avatarUrl),
);

// 只更新头像
taggedBuildUpdate('user_avatar');
```

### 作用域控制

```dart
// 在父组件中
final chatScope = Object();

// 在子组件中
taggedBuild<String, Message>(
  tag: 'new_message',
  scope: chatScope,
  data: () => message,
  builder: (context) => MessageBubble(message: context.data),
);

// 只更新特定作用域的组件
taggedBuildUpdates(['new_message'], scope: chatScope);
```

## 📚 API 文档

### 核心类

- **TaggedBuilder**：核心组件，用于构建响应标签变化的 Widget
- **TaggedBuildMixin**：提供便捷方法的 Mixin，推荐在 StatelessWidget 中使用
- **TaggedBuildContext**：提供给构建器函数的上下文，包含标签和数据

### 主要方法

- **taggedBuild**：创建带数据的标签构建器
- **taggedBuildEmpty**：创建不带数据的标签构建器
- **taggedBuildUpdate**：更新单个标签
- **taggedBuildUpdates**：更新多个标签
- **taggedBuildLoadingContentBuilderEmpty**：创建不带数据的加载状态处理构建器
- **taggedBuildLoadingContentBuilderData**：创建带数据的加载状态处理构建器

## 🤔 为什么选择 TaggedBuilder？

与其他状态管理方案相比，TaggedBuilder 提供了一种更加灵活和直观的方式来处理 UI 更新。它不需要复杂的 Provider 树或全局状态，而是使用简单的标签系统来识别需要更新的组件。

这种方法特别适合：

- 需要在不相关组件之间传递状态变化的场景
- 希望避免过度重建的性能敏感应用
- 需要精确控制状态更新范围的复杂 UI

## 📝 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
