# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在本仓库中工作时提供指导。

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI 协作规范

**重要：在此仓库中使用 AI 工具时，请遵循以下规则：**

1. **所有 AI 对话使用中文** - 与 Claude Code 或其他 AI 工具的所有交互必须使用中文
2. **代码提交不携带 AI 标识** - 提交代码时，commit message、代码注释、文档等不应包含任何 AI 相关的标识或提示信息

## 项目概述

`@unif/react-native-amap-search` 是一个 React Native 库，桥接高德地图（AMap）搜索 SDK 到 iOS 与 Android。提供 POI 搜索、地理/逆地理编码、行政区划查询等能力。

- Node 版本：见 `.nvmrc`（当前 16.18.1），`package.json` 要求 `>=16.0.0`
- iOS 最低版本：11.0
- Android 高德搜索 SDK：`com.amap.api:search:9.7.0`（POI 扩展信息需 9.4.0+）
- iOS 高德搜索：CocoaPods `AMapSearch`（POI `businessData` 同样需 9.4.0+）

## 开发命令

```bash
# 初始化（首次必跑）
yarn bootstrap          # 等价于：yarn example && yarn install && yarn example pods

# 调试示例应用（库源码通过 babel module-resolver 直链到 example，JS 改动免重建）
yarn example start                      # 启动 Metro
yarn example android                    # 运行 Android
yarn example ios                        # 运行 iOS

# 修改原生代码后需要重建：
cd ios && pod install                   # iOS 改了 .h/.m/.mm 后

# 质量检查
yarn typecheck                          # tsc --noEmit
yarn lint                               # ESLint（lefthook pre-commit 自动跑）
yarn lint --fix
yarn test                               # Jest（目前几乎为空，参考 src/__tests__/index.test.tsx）
yarn test <pattern>                     # 单文件 / 名称匹配

# 构建与发布
yarn prepack                            # bob build → lib/{commonjs,module,typescript}
yarn build:android                      # 构建示例 APK（debug, arm64-v8a）
yarn build:ios                          # 构建示例 iOS Debug 包（模拟器）
yarn release                            # release-it：自动 bump、changelog、tag、npm publish、GitHub release
yarn clean                              # 清除 android/ios 构建产物
```

## 架构设计

### 桥接结构

```
src/api/index.tsx          ← JS 层：参数默认值、调用 NativeModules.AmapSearch.*、Proxy 链接错误提示
src/types/{poi,common,index}.d.ts   ← 入参/出参 TypeScript 类型
ios/AmapSearch.{h,mm}      ← iOS RCT 模块（Objective-C++）
ios/AMapUtils.{h,m}        ← iOS 数据格式转换层（NSDictionary 化）
android/src/main/java/com/amapsearch/AmapSearchModule.java   ← Android 模块 + 内联格式转换
android/src/main/java/com/amapsearch/AmapSearchPackage.java  ← ReactPackage 注册
```

JS 调 `NativeModules.AmapSearch.<method>(...)`，原生侧通过 `RCT_EXPORT_METHOD`（iOS）/ `@ReactMethod`（Android）暴露方法，全部返回 Promise。

### ⚠️ 原生回调单例模式（重要陷阱）

**iOS 与 Android 的实现都把 JS Promise resolver/rejecter 存成模块的实例变量，并不维护请求队列。**

- iOS：`poiJsResolve` / `GeocodeJsResolve` / `districtJsResolve` / `jsReject` 是 `AmapSearch.mm` 的实例变量
- Android：`this.jsPromise` 是 `AmapSearchModule` 的字段
- 高德 SDK 通过 `AMapSearchDelegate` / `OnPoiSearchListener` 等回调接口返回结果，回调里直接 resolve 这些字段

**含义**：同一时间只能有一个搜索请求在飞。并发调用会让前一个 Promise 永远 pending（callback 被覆盖）。在 JS 侧需要串行（`await` 链），或在原生侧引入 request id / 队列再支持并发。

### 数据格式转换层

原生 SDK 返回的对象需转换为 React Native 可序列化结构：

- iOS：集中在 `ios/AMapUtils.m`，方法如 `poiSearchResponseFormatData:`、`regeocodeFormatData:`、`districtFormatData:`
- Android：写在 `AmapSearchModule.java` 内部，方法如 `formatDataPoiV2`、`formatDataLatLonPoint`、`districtFormatData`、`formatDataStreetNumber`

**新增/修改一个 POI 字段需要同步改三处**：iOS 转换函数 + Android 转换函数 + `src/types/poi.d.ts`。

### POI 数据结构（v0.4.0 BREAKING CHANGE）

POI 搜索返回结构已重组（与 SDK 9.4.0+ 的 `Business` / `businessData` 对齐）：

- 顶层：基础字段（`uid`、`name`、`type`、`typeCode`、`latLonPoint`、地址、行政区划等）
- `business`：所有商圈/营业类字段（`businessArea`、`openTime`、`openTimeToday`、`rating`、`cost`、`tel`、`tag`、`parkingType`、`alias`，iOS 多一个 `location`）
- `poiExtension`：仅包含 `photos: [{title, url}]`

详见类型定义 `src/types/poi.d.ts` 中 `AMapPOISearchListItem`、`AMapBusinessType`、`AMapPoiExtensionType`。

iOS 实现里 `businessData`（9.4.0+）走主路径，旧版属性 / `extensionInfo` 是兜底（`ios/AMapUtils.m`）。Android 在 query 构造时设置 `setShowFields(ShowFields.ALL)`、iOS 在 request 上设置 `showFieldsType = AMapPOISearchShowFieldsTypeAll` 才能拿到完整字段；这是一个常见踩点。

### 公共 API

JS 层共暴露 1 个初始化 + 9 个搜索方法，全部位于 `src/api/index.tsx`：

| JS 函数 | 原生方法 | 说明 |
|--------|----------|------|
| `init({ios, android})` | `initSDK(key)` | 初始化 SDK + 隐私授权 |
| `aMapPOIKeywordsSearch` | `aMapPOIKeywordsSearch` | 关键字 POI 搜索 |
| `aMapPOIAroundSearch` | `aMapPOIAroundSearch` | 周边 POI 搜索 |
| `aMapPOIPolygonSearch` | `aMapPOIPolygonSearch` | 多边形 POI 搜索 |
| `aMapRoutePOISearch` | `aMapRoutePOISearch` | 沿途 POI 搜索 |
| `aMapPOIInputTipsSearch` | `aMapPOIInputTipsSearch` | 输入提示 |
| `aMapPOIIDSearch` | `aMapPOIIDSearch` | 按 POI ID 查询 |
| `AMapReGeocodeSearch` | `AMapReGeocodeSearch` | 逆地理编码 |
| `AMapGeocodeSearch` | `AMapGeocodeSearch` | 地理编码 |
| `AMapDistrictSearch` | `aMapDistrictSearch` | 行政区划 |

**真实调用样例见 `example/src/App.tsx`**（最权威的用法参考，比 README 详细）。

### 隐私合规

`initSDK` 在两端都自动调用了高德 SDK 的隐私接口（iOS `AMapSearchAPI updatePrivacyShow/Agree`、Android `ServiceSettings.updatePrivacyShow/Agree`）。这是 2023 年起中国应用商店的合规要求，集成方无需再调用一次。

### 新架构（Fabric / TurboModules）

两端都有条件编译开关，但默认仍在旧架构上：

- iOS：`AmapSearch.h` 使用 `#ifdef RCT_NEW_ARCH_ENABLED` 选择 `NativeAmapSearchSpec` 或 `RCTBridgeModule`
- Android：`android/build.gradle` 检查 `newArchEnabled`，开启后会启用 `com.facebook.react` 插件

修改原生模块签名时需要同步考虑这两条路径（旧架构是测试主路径）。

### API Key 配置

支持三种方式（优先级：JS init > 原生预置）：

1. iOS `AppDelegate.m`：`[AMapServices sharedServices].apiKey = @"...";`（先 `#import <AMapFoundationKit/AMapFoundationKit.h>`）
2. Android `AndroidManifest.xml`：`<meta-data android:name="com.amap.api.v2.apikey" android:value="..." />`
3. JS `init({ios, android})`：会覆盖原生预置

## 原生模块开发流程

- iOS：用 Xcode 打开 `example/ios/AmapSearchExample.xcworkspace`，在 `Pods > Development Pods > react-native-amap-search` 下找源文件；改了 `.h/.m/.mm` 后跑 `cd ios && pod install` 并重建
- Android：用 Android Studio 打开 `example/android`，在 `react-native-amap-search` 模块下找源文件；改了 Java 后重建即可
- 调试链路：库源码通过 `example/babel.config.js` 的 `module-resolver` 直接指向 `src/`，JS 改动 Metro 热更新即可

## 构建系统

- `react-native-builder-bob` 构建 CommonJS / ES Module / TypeScript 三个目标，配置在 `package.json` 的 `react-native-builder-bob` 字段
- TS 构建走 `tsconfig.build.json`
- `release-it`（angular preset）从 conventional commits 自动生成 changelog、打 tag（`v${version}`）、发 npm + GitHub release

## 提交规范

约定式提交（commitlint 通过 lefthook pre-commit / commit-msg 强制）：`feat` / `fix` / `refactor` / `docs` / `test` / `chore`。

代码风格：ESLint + Prettier（单引号、2 空格、ES5 尾逗号），配置在 `package.json` 中。

## 测试策略

- Jest 单测目前是占位（`src/__tests__/index.test.tsx` 只有 `it.todo`）；新增逻辑时再补
- 真实集成测试 = 跑示例应用并使用 `example/src/App.tsx` 中的按钮触发各搜索

## 参考资源

仓库内文档（涉及 POI 数据结构 / SDK 字段时优先查阅）：

- `CHANGELOG.md` — v0.4.0 BREAKING 改动详情、字段映射
- `API_VERIFICATION_REPORT_FINAL.md` — 高德 SDK 各字段的可用性 / 版本要求验证
- `POI_TESTING_GUIDE.md` — POI 扩展信息测试建议（哪些 POI 类型有完整数据）
- `example/src/App.tsx` — 各 API 的真实调用示例
