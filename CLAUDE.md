# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在本仓库中工作时提供指导。

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI 协作规范

**重要：在此仓库中使用 AI 工具时，请遵循以下规则：**

1. **所有 AI 对话使用中文** - 与 Claude Code 或其他 AI 工具的所有交互必须使用中文
2. **代码提交不携带 AI 标识** - 提交代码时，commit message、代码注释、文档等不应包含任何 AI 相关的标识或提示信息

## 项目概述

这是一个 React Native 库（`@unif/react-native-amap-search`），为 iOS 和 Android 提供高德地图搜索 SDK 的桥接。它支持 POI（兴趣点）搜索、地理编码、逆地理编码和行政区域查询。

## 开发命令

### 初始化设置
```bash
yarn                    # 安装依赖
yarn bootstrap          # 完整设置：安装依赖和 pods
cd ios && pod install   # iOS: 更新 CocoaPods（修改原生代码后需要执行）
```

### 开发调试
```bash
yarn example start      # 启动示例应用的 Metro bundler
yarn example android    # 在 Android 上运行示例应用
yarn example ios        # 在 iOS 上运行示例应用
```

### 测试和质量检查
```bash
yarn test              # 运行 Jest 测试
yarn test --watch      # 监听模式运行测试
yarn test <文件名>      # 运行单个测试文件
yarn typecheck         # TypeScript 类型检查
yarn lint              # ESLint 代码检查
yarn lint --fix        # 自动修复代码格式问题
```

### 构建
```bash
yarn prepack                    # 构建库（运行 bob build）
yarn build:android              # 构建 Android 示例 APK
yarn build:ios                  # 构建 iOS 示例应用
yarn release                    # 使用 release-it 发布新版本
```

**发布流程：**
- 使用 `yarn release` 自动化发布流程
- release-it 会自动：
  - 更新版本号
  - 生成 changelog（基于 conventional commits）
  - 创建 git tag (格式: `v${version}`)
  - 提交到 npm registry
  - 创建 GitHub release

### 清理
```bash
yarn clean             # 清除 android/ios 的构建产物
```

## 架构设计

### 模块结构

本库采用标准的 React Native 模块架构：

```
src/
├── index.tsx              # 主导出文件
├── api/index.tsx          # JavaScript API 层（导出所有公共函数）
└── types/
    ├── index.d.ts         # 类型导出
    ├── common.d.ts        # 原生模块类型定义
    └── poi.d.ts           # POI 搜索类型和结果类型

ios/
├── AmapSearch.h           # iOS 头文件
├── AmapSearch.mm          # iOS 实现（Objective-C++）
└── AMapUtils.h/m          # iOS 工具函数

android/src/main/java/com/amapsearch/
├── AmapSearchModule.java  # Android 原生模块实现
└── AmapSearchPackage.java # Android 包注册
```

### 桥接模式

本库使用 React Native 的 `NativeModules` 桥接：
- **JavaScript 层**（`src/api/index.tsx`）：提供用户友好的异步函数和 TypeScript 类型
- **原生层**（iOS/Android）：实现实际的高德地图 SDK 调用
- **类型安全**：`src/types/` 中有完整的 TypeScript 类型定义

所有导出的函数都是异步的并返回 Promise。原生模块处理平台特定的高德地图 SDK 调用。

### 核心 API

本库提供 10 个主要搜索功能：

1. **init()** - 使用 API key 初始化 SDK
2. **aMapPOIKeywordsSearch()** - 关键字搜索
3. **aMapPOIAroundSearch()** - 周边搜索
4. **aMapPOIPolygonSearch()** - 多边形范围搜索
5. **aMapRoutePOISearch()** - 沿途搜索
6. **aMapPOIInputTipsSearch()** - 搜索提示
7. **aMapPOIIDSearch()** - 根据 POI ID 搜索
8. **AMapReGeocodeSearch()** - 逆地理编码（坐标 → 地址）
9. **AMapGeocodeSearch()** - 地理编码（地址 → 坐标）
10. **AMapDistrictSearch()** - 行政区域搜索

## 重要开发说明

### API Key 配置

本库支持三种方式配置高德地图 API key：

1. **原生 iOS**（`ios/AppDelegate.m`）：
   ```objc
   #import <AMapFoundationKit/AMapFoundationKit.h>
   [AMapServices sharedServices].apiKey = @"your-key";
   ```

2. **原生 Android**（`android/app/src/main/AndroidManifest.xml`）：
   ```xml
   <meta-data android:name="com.amap.api.v2.apikey" android:value="your-key" />
   ```

3. **JavaScript**（会覆盖原生配置）：
   ```js
   init({ios: 'ios-key', android: 'android-key'});
   ```

### 平台特定代码

- iOS 使用 Objective-C++（`.mm` 扩展名）实现原生模块
- Android 使用高德地图搜索 SDK v9（基于 `PoiSearchV2`、`PoiItemV2` 等导入）
- JavaScript 层使用 `Platform.select()` 处理平台差异

### 原生模块开发

编辑原生代码时：
- **iOS**：使用 Xcode 打开 `example/ios/AmapSearchExample.xcworkspace`
  - 在 `Pods > Development Pods > react-native-amap-search` 下查找源文件
  - 修改后需要重新运行 `cd ios && pod install`
- **Android**：使用 Android Studio 打开 `example/android`
  - 在 `react-native-amap-search` 模块下查找源文件

修改原生代码后需要重新构建示例应用（JavaScript 修改支持热重载）。

**示例应用开发流程：**
1. 在库的根目录运行 `yarn bootstrap` 进行初始化设置
2. 修改 `src/` 下的 TypeScript 代码或 `ios/`、`android/` 下的原生代码
3. 运行 `yarn example start` 启动 Metro bundler
4. 在另一个终端运行 `yarn example android` 或 `yarn example ios` 启动应用
5. 示例应用通过 `babel-plugin-module-resolver` 直接链接到库的 `src/` 目录，无需构建即可测试

### 构建系统

- 使用 `react-native-builder-bob` 构建 CommonJS、ES Module 和 TypeScript 输出
- 构建配置在 `package.json` 的 `react-native-builder-bob` 字段中
- TypeScript 构建使用 `tsconfig.build.json`

### 提交规范

本项目使用约定式提交（通过 lefthook 的 pre-commit hooks 强制执行）：
- `feat:` - 新功能
- `fix:` - Bug 修复
- `refactor:` - 代码重构
- `docs:` - 文档变更
- `test:` - 测试添加/更新
- `chore:` - 工具/构建变更

Git hooks 配置：
- 使用 `@evilmartians/lefthook` 管理 Git hooks
- commit 前会自动运行 commitlint 检查提交信息格式
- 确保提交信息符合约定式提交规范

### 代码风格

- 使用 ESLint + Prettier（配置在 `package.json` 中）
- 单引号、2 空格缩进、ES5 尾逗号
- 通过 pre-commit hooks 强制执行代码检查

## 测试策略

- 单元测试使用 Jest 和 React Native preset
- 测试文件位于 `src/__tests__/`
- 模块路径忽略：`example/node_modules` 和 `lib/`
- 使用 `yarn test` 运行测试

## 常见模式

### 错误处理

本库使用 Proxy 在原生模块不可用时提供清晰的链接错误提示（参见 `src/api/index.tsx:22-31`）。

### 类型安全

所有搜索函数都接受类型化的参数并返回类型化的结果。类型定义区分了：
- 必填字段与可选字段（例如 `AMapLatLonMustType` vs `AMapLatLonType`）
- 不同的搜索结果类型（POI、地理编码、行政区域）
- 平台特定枚举（例如 `AMapReGeocodeSearchLatLonType`）
